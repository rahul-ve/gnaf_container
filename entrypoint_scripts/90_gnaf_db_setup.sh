#!/bin/bash

#####
: '
This script creates the GNAF DB.

STEPS:

1. Download the GNAF GDA2020 zip file from data.gov.au and extract the contents to a location that is accessible to the PostgreSQL server
2. Map the table names to file names  (Authority Code & Standard files), output from this step is used in STEP 5
3. Create the schema
4. Create the tables
5. Load the data from PSV files
6. Add FK constraints
7. Create the Address View

'
#####

set -Eeuxo pipefail

##
DB_="$POSTGRES_DB"
SCHEMA_="$GNAF_SCHEMA"
SEARCH_PATH_="$GNAF_SCHEMA,public"


## 
#GNAF_DATA_FOLDER="$(ls /gnaf_data | grep -i gda2020)"        # hacky!
GNAF_DATA_FOLDER="$(find /gnaf_data -type d -name 'G-NAF' | xargs dirname | xargs basename)"     # looking for G-NAF folder in parent dir
GNAF_MAIN_DATA_FILES_FOLDER="$(ls /gnaf_data/$GNAF_DATA_FOLDER/G-NAF | grep -Ee "G-NAF\s+[A-Z]+\s+20[0-9]{2}")"
DATA_FILES_PATH="/gnaf_data/$GNAF_DATA_FOLDER/G-NAF/$GNAF_MAIN_DATA_FILES_FOLDER"
PROVIDED_SCRIPTS_PATH="/gnaf_data/$GNAF_DATA_FOLDER/G-NAF/Extras"

## update load_data.sql with the right file path for data files
perl -i -pe "s|file_path_prefix TEXT := .*$|file_path_prefix TEXT := '$DATA_FILES_PATH/';|" "$USER_SCRIPTS/load_data.sql"


## STEP 2

## Authority Code tables
## Extract Authority Code table names from the psv file names
ls "$DATA_FILES_PATH/Authority Code/" | awk  'BEGIN{OFS=","} v_ = match($1, /(Authority_Code_)(.*)(_psv.psv)/, arr){print $1,arr[2]}' > "$DATA_FILES_PATH/ac_tables.csv"

## Standard tables
## Extract Standard table names from the psv file names
ls "$DATA_FILES_PATH/Standard/" | awk  'BEGIN{OFS=","} v_ = match($1, /([A-Z]+)_(.*)(_psv.psv)/, arr){print $1,arr[2]}' > "$DATA_FILES_PATH/std_tables.csv"


## STEP 3
psql -d "$DB_" --username "$POSTGRES_USER" -c "CREATE SCHEMA $SCHEMA_;"

## STEP 4
psql -d "$DB_" --username "$POSTGRES_USER" -c "SET search_path TO $SEARCH_PATH_;"  -f "$PROVIDED_SCRIPTS_PATH/GNAF_TableCreation_Scripts/create_tables_ansi.sql"

## STEP 5
psql -d "$DB_" --username "$POSTGRES_USER" -c "SET search_path TO $SEARCH_PATH_;"  -f "/$USER_SCRIPTS/load_data.sql"

## STEP 6
psql -d "$DB_" --username "$POSTGRES_USER" -c "SET search_path TO $SEARCH_PATH_;" -f "$PROVIDED_SCRIPTS_PATH/GNAF_TableCreation_Scripts/add_fk_constraints.sql"

## STEP 7
psql -d "$DB_" --username "$POSTGRES_USER" -c "SET search_path TO $SEARCH_PATH_;" -f "$PROVIDED_SCRIPTS_PATH/GNAF_View_Scripts/address_view.sql"

# END
echo "GNAF DB setup complete"