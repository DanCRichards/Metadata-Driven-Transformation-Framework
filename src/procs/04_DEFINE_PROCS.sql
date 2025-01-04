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
    where_clause TEXT := '';  -- Initialize empty where clause
    record RECORD;
    input_clause TEXT;
    function_inputs RECORD;
    condition_record RECORD;
    first_condition BOOLEAN := TRUE; -- Flag to help format WHERE clause correctly
    input_source_table_name TEXT;
BEGIN
    -- Initalise input_source_table_name
    SELECT INTO input_source_table_name source_table_name
    FROM transformations
    WHERE transformation_key = input_transformation_key;

    -- Initialize the SQL INSERT statement with the target table name
    SELECT INTO sql_text 'INSERT INTO ' || target_table_name || ' ('
    FROM transformations
    WHERE transformation_key = input_transformation_key;

    -- Loop through target mappings to build target column list and source value list
    FOR record IN SELECT tm.target_table_name, tm.target_column_name, tm.function_name
                  FROM target_mapping tm
                  WHERE tm.transformation_key = input_transformation_key
    LOOP
        -- Add columns to the insert list
        target_list := target_list || quote_ident(record.target_column_name) || ', ';

        -- Collect all inputs for this function/target column
        FOR function_inputs IN SELECT im.source_table_name, im.source_column_name
                               FROM input_mapping im
                               WHERE im.transformation_key = input_transformation_key AND
                                     im.target_table_name = record.target_table_name AND
                                     im.target_column_name = record.target_column_name
        LOOP
            -- Construct input_clause based on presence of a source table
            input_clause := input_clause || function_inputs.source_table_name || '.' || quote_ident(function_inputs.source_column_name) || ', ';
        END LOOP;

        -- Remove the trailing comma and space from input_clause
        input_clause := RTRIM(input_clause, ', ');

        -- Build source list using function if applicable or directly use the column
        source_list := source_list || ' ' || record.function_name || '(' || input_clause || ')' || ' AS ' || quote_ident(record.target_column_name) || ', ';
    END LOOP;

    -- Remove the trailing commas
    target_list := RTRIM(target_list, ', ');
    source_list := RTRIM(source_list, ', ');
    sql_text := sql_text || target_list || ') SELECT ' || source_list || ' FROM ' || input_source_table_name;

    -- Build WHERE conditions from conditions table
    FOR condition_record IN SELECT c.condition_key, c.side_a_condition_function, c.side_b_condition_function, ci.source_table_name, ci.source_column_name
                            FROM conditions c
                            JOIN condition_inputs ci ON c.transformation_key = ci.transformation_key AND c.condition_key = ci.condition_key
                            WHERE c.transformation_key = input_transformation_key
    LOOP
        if not first_condition then
            where_clause := where_clause || ' AND ';
        end if;
        where_clause := where_clause || condition_record.source_table_name || '.' || quote_ident(condition_record.source_column_name) || ' ' || condition_record.side_a_condition_function || ' ' || condition_record.side_b_condition_function;
        first_condition := FALSE;
    END LOOP;

    -- Append the WHERE clause if conditions were added
    IF NOT first_condition THEN
        sql_text := sql_text || where_clause;
    END IF;

    -- Execute the dynamic SQL
    RAISE NOTICE 'Executing SQL: %', sql_text;
    EXECUTE sql_text;
END
$$;