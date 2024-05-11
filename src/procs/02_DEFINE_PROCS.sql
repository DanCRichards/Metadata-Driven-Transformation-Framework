CREATE SCHEMA IF NOT EXISTS mtf; -- Meta Transfer Framework

SET SEARCH_PATH=mtf;

CREATE OR REPLACE FUNCTION transfer_data(target_table_name TEXT)
RETURNS void AS $$
DECLARE
    mapping RECORD;
    target_mapping_record RECORD;
    sql_text TEXT := 'INSERT INTO ' || target_table_name || ' (';
    columns_text TEXT := '';
    values_text TEXT := '';
    function_sql TEXT;
    input_sql TEXT;
BEGIN
    SET SEARCH_PATH TO mtf;
    FOR mapping IN SELECT * FROM target_mapping WHERE target_table_name = target_table_name
    LOOP
        columns_text := columns_text || mapping.target_column_name || ', ';

        -- Prepare function call SQL
        function_sql := '(SELECT ' || (SELECT function_definition FROM functions WHERE function_id = mapping.function_id) || '(';
        input_sql := '';
        FOR target_mapping_record IN SELECT * FROM input_mapping WHERE target_mapping_id = mapping.target_mapping_id ORDER BY input_order
        LOOP
            input_sql := input_sql || target_mapping_record.source_table_name || '.' || target_mapping_record.source_column_name || ', ';
        END LOOP;
        input_sql := TRIM(TRAILING ', ' FROM input_sql) || '))';

        values_text := values_text || function_sql || ', ';
    END LOOP;

    -- Remove trailing commas and finalize the SQL statement
    columns_text := TRIM(TRAILING ', ' FROM columns_text);
    values_text := TRIM(TRAILING ', ' FROM values_text);
    sql_text := sql_text || columns_text || ') VALUES (' || values_text || ');';

    -- Execute the dynamic SQL
    EXECUTE sql_text;
END;
$$ LANGUAGE plpgsql;
