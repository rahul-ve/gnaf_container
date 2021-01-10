BEGIN;
SET search_path TO gnaf202011,public;
SELECT address_detail_pid, locality_pid, building_name, lot_number_prefix, lot_number, lot_number_suffix, 
flat_type, flat_number_prefix, flat_number, flat_number_suffix, level_type, level_number_prefix, level_number, level_number_suffix, 
number_first_prefix, number_first, number_first_suffix, number_last_prefix, number_last, number_last_suffix, 
street_name, street_class_code, street_class_type, street_type_code, street_suffix_code, street_suffix_type, 
locality_name, 
state_abbreviation, 
postcode, 
latitude, longitude, 
ST_SetSRID(ST_MakePoint(longitude, latitude), 7844)  AS pt,
geocode_type, 
confidence, 
alias_principal, primary_secondary, 
legal_parcel_id, 
date_created
FROM gnaf202011.address_view
WHERE 
building_name ILIKE '%town%'
AND postcode = '2000'
limit 100;
COMMIT;