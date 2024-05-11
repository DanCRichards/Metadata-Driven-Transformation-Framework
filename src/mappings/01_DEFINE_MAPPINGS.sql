CREATE SCHEMA IF NOT EXISTS mtf; -- meta transformation framework
SET SEARCH_PATH = mtf;

-- Drop existing tables and types if they exist
DROP TABLE IF EXISTS join_mappings;
DROP TABLE IF EXISTS input_mapping;
DROP TABLE IF EXISTS target_mapping;
DROP TABLE IF EXISTS transformations;
DROP TABLE IF EXISTS function_inputs;
DROP TABLE IF EXISTS functions CASCADE;
DROP TYPE IF EXISTS join_type CASCADE;

-- Recreate enum for join types
CREATE TYPE join_type AS ENUM ('INNER', 'LEFT', 'RIGHT', 'FULL JOIN');

-- Functions table
CREATE TABLE functions
(
    function_name function_name PRIMARY KEY,
    function_definition TEXT  -- Stores the SQL or pseudo code defining the function
);

-- Function Inputs table, maintains use of a SERIAL primary key for input uniqueness
CREATE TABLE function_inputs
(
    input_id SERIAL PRIMARY KEY,
    function_name function_name REFERENCES functions(function_name),
    input_order INT,
    input_data_type TEXT
);

-- Transformations table using natural keys
CREATE TABLE transformations
(
    source_table_name TEXT,
    target_table_name TEXT,
    description TEXT,
    PRIMARY KEY (source_table_name, target_table_name)
);

-- Target Mapping table using natural keys
CREATE TABLE target_mapping
(
    target_table_name TEXT,
    target_column_name TEXT,
    function_name function_name REFERENCES functions(function_name),
    source_table_name TEXT,
    PRIMARY KEY (target_table_name, target_column_name),
    FOREIGN KEY (source_table_name, target_table_name) REFERENCES transformations(source_table_name, target_table_name) ON DELETE CASCADE
);

-- Input Mapping table using references to target mapping natural keys
CREATE TABLE input_mapping
(
    target_table_name TEXT,
    target_column_name TEXT,
    source_table_name TEXT,
    source_column_name TEXT,
    input_order INT,
    in_group_by BOOLEAN DEFAULT FALSE, -- Indicates if this input is part of a GROUP BY
    PRIMARY KEY (target_table_name, target_column_name, source_table_name, source_column_name, input_order),
    FOREIGN KEY (target_table_name, target_column_name) REFERENCES target_mapping(target_table_name, target_column_name) ON DELETE CASCADE
);

-- Join Mappings table using transformation natural keys
CREATE TABLE join_mappings
(
    source_table_name TEXT,
    target_table_name TEXT,
    join_type join_type,
    join_condition TEXT,
    FOREIGN KEY (source_table_name, target_table_name) REFERENCES transformations(source_table_name, target_table_name) ON DELETE CASCADE,
    PRIMARY KEY (source_table_name, target_table_name, join_condition)
);