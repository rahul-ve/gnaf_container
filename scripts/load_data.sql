DO $$

DECLARE

    -- Download the GNAF dump files from data.gov.au and extract it to a location that is accessible from the PostgreSQL server
    -- Declare the path to CSV files. Probably need to put this in PostgreSQL file path to avoid permission issues.

    file_path_prefix TEXT := '/gnaf_data/g-naf_may22_allstates_gda2020_psv_106/G-NAF/G-NAF MAY 2022/';

    data_folder_in_container TEXT := '/gnaf_data/';

    -- Path where authority code CSV files are
    ac_file_path TEXT := file_path_prefix || 'Authority Code/';

    -- Path where standard CSV files are
    std_file_path TEXT := file_path_prefix || 'Standard/';

    fn TEXT;              -- Variable to hold name of current CSV file being inserted
    tn TEXT;              -- Variable to hold table name matching the CSV file

BEGIN

    -- AUTHORITY CODE TABLE

    CREATE TABLE ac_files (
        fileName TEXT,
        tableName TEXT
    );

    --ac_tables_file :=  ac_file_path || 'ac_tables.csv';
    --COPY ac_files FROM ac_tables_file CSV DELIMITER ',';
    EXECUTE 'COPY ac_files FROM ''' || data_folder_in_container || 'ac_tables.csv'' CSV DELIMITER '',''';
    ALTER TABLE ac_files add column processed int default 0;


    LOOP
        select fileName, tableName INTO fn, tn from ac_files where processed = 0 limit 1; -- Pick the first file
        raise notice 'fn: %', fn;
        EXECUTE 'COPY ' || tn || ' from ''' || ac_file_path ||  fn || ''' with DELIMITER ''|'' csv header';
        update ac_files set processed = 1 where fileName = fn and tableName = tn;
        EXIT  WHEN (SELECT COUNT(*) FROM ac_files where processed = 0) = 0;
    END LOOP;


    -- STD TABLE

    CREATE TABLE std_files (
        fileName TEXT,
        tableName TEXT
    );

    --std_tables_file := std_file_path || 'std_tables.csv';
    EXECUTE 'COPY std_files FROM ''' || data_folder_in_container || 'std_tables.csv'' CSV DELIMITER '',''';
    ALTER TABLE std_files add column processed int default 0;

    LOOP
        select fileName, tableName INTO fn, tn from std_files where processed = 0 limit 1; -- Pick the first file
        raise notice 'fn: %', fn;
        EXECUTE 'COPY ' || tn || ' from ''' || std_file_path ||  fn || ''' with DELIMITER ''|'' csv header';
        update std_files set processed = 1 where fileName = fn and tableName = tn;
        EXIT  WHEN (SELECT COUNT(*) FROM std_files where processed = 0) = 0;
    END LOOP;

    --DROP TABLE IF EXISTS ac_files;
    --DROP TABLE IF EXISTS std_files;

END $$;
