## GNAF - Geocoded National Address File Database

Below information provides instructions on how to build the GNAF database in a Docker container making use of the provided scripts that are packaged along with the GNAF data. Data is loaded via the PostgreSQL COPY command.
Tested on Windows10/WSL2 and Ubuntu.

###  Prerequisites
- GNAF data files from [data.gov.au](https://data.gov.au/dataset/ds-dga-19432f89-dc3a-4ef3-b943-5326ef1dbecc/details?q=gnaf)

### Instructions

- Extract the GNAF data to the "data" folder, refer to the example folder structure below
- Make sure `data` folder has `775` permissions on `*nix` systems: `chmod 755 ./data`  (this is on the host system)
- Update settings in gnaf_docker_compose.yaml file if needed **(e.g. Database name, Username, Password, Schema name..)**
    - **Some of the environment variables are used in entrypoint scripts, be careful modifying them!**
- Values of below parameters in `entrypoint_scripts/90_gnaf_db_setup.sh` depend on the folder names and structure of the extracted GNAF data. Refer to the logic in the script if there are any issues.

    ```
    GNAF_DATA_FOLDER
    GNAF_MAIN_DATA_FILES_FOLDER
    ```
- run
    -  `$ docker-compose -f ./gnaf_docker_compose.yaml up -d`

- connect via psql
    - `$ psql -h localhost -d <DATABASE NAME> -U <POSTGRES USER>`

### Remarks

- First run takes some time (varies depending on the system resources, takes advantage of multi-core CPU) to build the database. Uses a Docker named volume `geo_db_volume` to store database data. On subsequent runs, this volume is used so any changes made are persisted. The entrypoint scripts are skipped if this named volume is present.
    - Ignore errors like `ERROR:  canceling autovacuum task`, DB build is still happening in the background.
    - Some stages take a fair amount of time  (upwards of 30mins) and will not output any logs in-between, be patient, wait for `GNAF DB setup complete` log entry.
    - Connections to the database might not succeed prior to finishing the database build.
    - Tail docker contianer logs to get exact status - `docker logs -f <CONTAINER NAME OR ID>`
- To rebuild the database, delete the named volume!
- To add or modify initialization steps, either modify the entrypoint script `entrypoint_scripts/90_gnaf_db_setup.sh` or add additional scripts to `entrypoint_scripts/` directory. These can be shell or sql scripts and are executed in sorted name order
- Any user scripts can be saved to "scripts" folder and accessed from within the container
- On Linux host systems make sure to change the "group_add" key in the compose file to the id of the group (with write permissions) on the host system for `./data` folder, this will avoid the permissions issue with the bind mounts. OR change the permissions on the host system to allow writes from the container. This should not be an issue on Windows!
- `Authority Code` and `Standard` table names are matched to the `psv` files using an awk script that relies on the naming scheme/pattern used for the `psv` files. Please look at the code in `entrypoint_scripts/99_gnaf_db_setup.sh`.

### GNAF data files
```
g-naf_xxx_gda2020_psv               ## this is the extracted zip folder, name changes often!
├── Contents.txt
├── Counts.csv
└── G-NAF                           ## This is the main folder with all the contents needed to rebuilt the db, name seems to not change!
    ├── Documents
    │   ├── G-NAF Product Description.pdf
    │   └── G-NAF Release Report November 2020.pdf
    ├── Extras
    │   ├── GNAF_TableCreation_Scripts
    │   └── GNAF_View_Scripts
    └── G-NAF NOVEMBER 2020          ## This is the main folder with the data, name changes, has month and year in name!
        ├── Authority Code
        ├── Standard
```
### Docker Build Context Structure
```
├── README.md
├── data
│   └── g-naf_xxx_gda2020_psv               ## this is the extracted zip folder, name changes often!
├── gnaf_docker_compose.yaml
├── entrypoint_scripts
│   └── 99_gnaf_db_setup.sh
├── gnaf_dockerfile
└── scripts
    ├── load_data.sql
    └── test_script.sql
```
