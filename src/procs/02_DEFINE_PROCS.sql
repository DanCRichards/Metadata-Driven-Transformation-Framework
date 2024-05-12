CREATE OR REPLACE PROCEDURE perform_transformation(
    input_transformation_key TEXT
)
LANGUAGE plpgsql
AS $$
DECLARE
    sql_text TEXT := '';
    target_list TEXT := '';
    source_list TEXT := '';
    joins TEXT := '';
    record RECORD;
    input_clause TEXT;
    function_inputs RECORD;
    condition_record RECORD;
    input_source_table_name TEXT;
    input_target_table_name TEXT;
BEGIN

    /* Declare the source and target table names */
    SELECT target_table_name, source_table_name INTO input_target_table_name, input_source_table_name
    FROM transformations
    WHERE transformation_key = input_transformation_key;

    /* Initialise the SQL statement with the target table name */
    SELECT 'INSERT INTO ' || target_table_name INTO sql_text
    FROM transformations
    WHERE source_table_name = input_source_table_name AND target_table_name = input_target_table_name;

    sql_text := sql_text || ' (';

    /* Loop through target mappings to build target column list and source value list */
    FOR record IN SELECT tm.target_table_name, tm.target_column_name, tm.function_name
                  FROM target_mapping tm
                  WHERE tm.target_table_name = input_target_table_name
    LOOP
        -- Add columns to the insert list
        IF record.target_column_name IS NOT NULL THEN
            target_list := target_list || quote_ident(record.target_column_name) || ', ';
        END IF;

        -- Reset input_clause for each column
        input_clause := '';

        -- Collect all inputs for this function/target column
        FOR function_inputs IN SELECT im.source_table_name, im.source_column_name
                               FROM input_mapping im
                               WHERE im.target_table_name = record.target_table_name
                                 AND im.target_column_name = record.target_column_name
                               ORDER BY im.input_order
        LOOP
            -- Construct input_clause based on presence of a source table
            IF function_inputs.source_table_name IS NOT NULL AND TRIM(function_inputs.source_table_name) <> '' THEN
                input_clause := input_clause || function_inputs.source_table_name || '.' || quote_ident(function_inputs.source_column_name) || ', ';
            ELSE
                input_clause := input_clause || '''' || function_inputs.source_column_name || '''' || ', ';
            END IF;
        END LOOP;

        -- Remove the trailing comma and space from input_clause
        input_clause := TRIM(TRAILING ', ' FROM input_clause);

        -- Build source list using function if applicable or directly use the column
        IF record.function_name IS NOT NULL AND input_clause <> '' THEN
            source_list := source_list || ' ' || record.function_name || '(' || input_clause || ')' || ' AS ' || quote_ident(record.target_column_name) || ', ';
        ELSE
            -- Directly use the input_clause as the source when no function is specified
            source_list := source_list || ' ' || input_clause || ' AS ' || quote_ident(record.target_column_name) || ', ';
        END IF;
    END LOOP;

    -- Build joins from join mappings and their conditions
    FOR record IN SELECT jm.join_mapping_key, jm.join_type, jm.join_table_name
                  FROM join_mappings jm
                  WHERE jm.transformation_key = 'test_notes'
    LOOP
        joins := joins || ' ' || record.join_type || ' JOIN ' || record.join_table_name || ' ON ';

        -- Append all conditions for this join
        FOR condition_record IN SELECT jcm.lhs_column, jcm.rhs_column, jcm.operator
                                FROM join_conditions_mapping jcm
                                WHERE jcm.join_mapping_key = record.join_mapping_key
        LOOP
            joins := joins || condition_record.lhs_column || ' ' || condition_record.operator || ' ' || condition_record.rhs_column || ' AND ';
        END LOOP;

        -- Remove the trailing ' AND '
        joins := RTRIM(joins, ' AND ');
    END LOOP;

    -- Remove trailing commas and finalize the SQL statement
    target_list := TRIM(TRAILING ', ' FROM target_list);
    source_list := TRIM(TRAILING ', ' FROM source_list);
    sql_text := sql_text || target_list || ') SELECT ' || source_list || ' FROM landing.notes ' || joins || ';';

    -- Debug print the SQL statement
    RAISE NOTICE 'Executing SQL: %', sql_text;

    -- Execute the dynamic SQL
    EXECUTE sql_text;
END
$$;