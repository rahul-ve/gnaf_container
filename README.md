## GNAF - Geocoded National Address File Database

Below information provides instructions on how to build the GNAF database in a Docker container making use of the provided scripts that are packaged along with the GNAF data. Data is loaded via the PostgreSQL COPY command. 
Tested on Windows10/WSL2 and Ubuntu.

###  Prerequisites
- GNAF data files from [data.gov.au](https://data.gov.au/dataset/ds-dga-19432f89-dc3a-4ef3-b943-5326ef1dbecc/details?q=gnaf)

### GNAF data files
```
nov20_gnaf_pipeseparatedvalue_gda2020
├── Contents.txt
├── Counts.csv
└── G-NAF
    ├── Documents
    │   ├── G-NAF Product Description.pdf
    │   └── G-NAF Release Report November 2020.pdf
    ├── Extras
    │   ├── GNAF_TableCreation_Scripts
    │   └── GNAF_View_Scripts
    └── G-NAF NOVEMBER 2020
        ├── Authority Code
        ├── Standard
```
### Instructions

- Extract the GNAF data to the "data" folder
- Update settings in gnaf_docker_compose.yaml file if needed **(e.g. Database name, Username, Password, Schema name..)**
    - **Some of the environment variables are used in entrypoint scripts, be careful modifying them!**
- run
    -  ```$ docker-compose -f ./gnaf_docker_compose.yaml up -d ```

- connect via psql
    - ```$ psql -h localhost -d geo -U guser```

### Remarks

- First run takes some time (varies depending on the system resources, takes advantage of multi-core CPU) to build the database. Uses a Docker named volume **(geo_db_volume)** to store database data. On subsequent runs, this volume is used so any changes made are persisted. The entrypoint scripts are skipped if this named volume is present. 

- To rebuild the database, delete the named volume!
- To add or modify initialization steps, either modify the entrypoint script **(90_gnaf_db_setup.sh)** or add additional scripts to **/docker-entrypoint-initdb.d/** directory. These can be shell or sql scripts and are executed in sorted name order
- Any user scripts can be saved to "scripts" folder and accessed from within the container
- On Linux (Debian based) host systems make sure to change the "group_add" key in the compose file to the id of the group (with write permissions) on the host system for **./data** folder, this will avoid the permissions issue with the bind mounts. OR change the permissions on the host system to allow writes from the container. This should not be an issue on Windows!


### Docker Build Context Structure
```
├── README.md
├── data
│   └── nov20_gnaf_pipeseparatedvalue_gda2020
├── gnaf_docker_compose.yaml
├── entrypoint_scripts
│   └── 99_gnaf_db_setup.sh
├── gnaf_dockerfile
└── scripts
    ├── load_data.sql
    └── test_script.sql
```
