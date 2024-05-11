CREATE SCHEMA IF NOT EXISTS mtf; -- meta transformation framework

SET SEARCH_PATH=mtf;

CREATE TABLE IF NOT EXISTS functions
(
    function_id SERIAL PRIMARY KEY,
    function_name TEXT,
    function_definition TEXT  -- Stores the SQL or pseudo code defining the function
);

CREATE TABLE IF NOT EXISTS function_inputs
(
    input_id SERIAL PRIMARY KEY,
    function_id INT REFERENCES functions(function_id),
    input_order INT,
    input_data_type TEXT
);


CREATE TABLE IF NOT EXISTS target_mapping
(
    target_mapping_id SERIAL PRIMARY KEY,
    target_table_name TEXT,
    target_column_name TEXT,
    function_id INT REFERENCES functions(function_id)
);


CREATE TABLE IF NOT EXISTS input_mapping
(
    input_mapping_id SERIAL PRIMARY KEY,
    target_mapping_id INT REFERENCES target_mapping(target_mapping_id),
    source_table_name TEXT,
    source_column_name TEXT,
    input_order INT,
    in_group_by BOOLEAN DEFAULT FALSE  -- Indicates if this input is part of a GROUP BY
);

CREATE TABLE IF NOT EXISTS transformations
(
    transformation_id SERIAL PRIMARY KEY,
    source_table_name TEXT,
    target_table_name TEXT,
    description TEXT
);

CREATE TYPE JOIN_TYPE AS ENUM
(
    'INNER',
    'LEFT',
    'RIGHT',
    'FULL JOIN'
);

CREATE TABLE IF NOT EXISTS join_mappings
(
    join_id SERIAL PRIMARY KEY,
    transformation_id INT REFERENCES transformations(transformation_id),
    join_type JOIN_TYPE,  -- Examples: 'INNER JOIN', 'LEFT JOIN', etc.
    source_table_name TEXT,
    target_table_name TEXT,  -- Optional, depending on the transformation logic
    join_condition TEXT
);