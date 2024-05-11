CREATE OR REPLACE PROCEDURE process_notes_transformation()
LANGUAGE plpgsql
AS $$
DECLARE
    sql_text TEXT := '';
    target_list TEXT := '';
    source_list TEXT := '';
    joins TEXT := '';
    record RECORD;
BEGIN
    -- Verify and create staging schema if it does not exist
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_namespace WHERE nspname = 'mtf_staging') THEN
        EXECUTE 'CREATE SCHEMA mtf_staging';
    END IF;

    -- Initialize SQL for insert
    SELECT 'INSERT INTO ' || target_table_name INTO sql_text
    FROM transformations
    WHERE source_table_name = 'landing.notes' AND target_table_name = 'mtf_staging.notes';

    sql_text := sql_text || ' (';

    -- Loop through target mappings to build target column list and source value list
    FOR record IN SELECT tm.target_table_name, tm.target_column_name, tm.function_name, im.source_table_name, im.source_column_name, jm.join_type, jm.join_condition
                  FROM target_mapping tm
                  LEFT JOIN input_mapping im ON tm.target_table_name = im.target_table_name AND tm.target_column_name = im.target_column_name
                  LEFT JOIN join_mappings jm ON jm.source_table_name = im.source_table_name AND jm.target_table_name = tm.target_table_name
                  WHERE tm.target_table_name = 'mtf_staging.notes'
    LOOP
        -- Add columns to the insert list
        IF record.target_column_name IS NOT NULL THEN
            target_list := target_list || quote_ident(record.target_column_name) || ', ';
        END IF;

        -- Build source list using function if applicable
        IF record.function_name IS NOT NULL AND record.source_table_name IS NOT NULL AND record.source_column_name IS NOT NULL THEN
            source_list := source_list || ' ' || record.function_name || '(' || record.source_table_name || '.' || quote_ident(record.source_column_name) || ')' || ' AS ' || quote_ident(record.target_column_name) || ', ';
        ELSIF record.source_table_name IS NOT NULL THEN
            source_list := source_list || ' ' || record.source_table_name || '.' || quote_ident(record.source_column_name) || ' AS ' || quote_ident(record.target_column_name) || ', ';
        ELSIF record.source_column_name IS NOT NULL THEN
            source_list := source_list || ' ' || record.source_column_name || ' AS ' || quote_ident(record.target_column_name) || ', ';
        END IF;

        -- Add joins if applicable
        IF record.join_type IS NOT NULL AND record.join_condition IS NOT NULL AND record.source_table_name IS NOT NULL THEN
            joins := joins || ' ' || record.join_type || ' JOIN ' || record.source_table_name || ' ON ' || record.join_condition || ' ';
        END IF;
    END LOOP;

    -- Remove trailing commas and finalize the SQL statement
    target_list := TRIM(TRAILING ', ' FROM target_list);
    source_list := TRIM(TRAILING ', ' FROM source_list);
    sql_text := sql_text || target_list || ') SELECT ' || source_list || ' FROM landing.notes ' || joins || ';';

    -- Debug print the SQL statement
    RAISE NOTICE 'Executing SQL: %', sql_text;

    -- Execute the dynamic SQL
    EXECUTE sql_text;
END;
$$;
