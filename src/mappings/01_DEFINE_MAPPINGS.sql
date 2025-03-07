CREATE SCHEMA IF NOT EXISTS mtf; -- meta transformation framework
SET SEARCH_PATH = mtf;

-- Drop existing tables and types if they exist
DROP TABLE IF EXISTS join_mappings CASCADE ;
DROP TABLE IF EXISTS join_conditions_mapping CASCADE ;
DROP TABLE IF EXISTS input_mapping;
DROP TABLE IF EXISTS target_mapping;
DROP TABLE IF EXISTS transformations;
DROP TABLE IF EXISTS function_inputs;
DROP TABLE IF EXISTS functions CASCADE;
DROP TYPE IF EXISTS join_type CASCADE;

-- Recreate enum for join types
CREATE TYPE join_type AS ENUM ('INNER', 'LEFT', 'RIGHT', 'FULL JOIN');


DROP TYPE IF EXISTS function_name CASCADE;  -- Drop existing enum type if it exists, cascading to dependent objects
CREATE TYPE function_name AS ENUM (
    '',
    'safe_to_timestamp',
    'str_to_boolean',
    'return_enum'
    );


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

DROP TABLE IF EXISTS STAGES CASCADE;
CREATE TABLE STAGES
(
    stage_key TEXT PRIMARY KEY,
    stage_description TEXT
);


-- Transformations table using natural keys
CREATE TABLE transformations
(
    transformation_key TEXT,
    is_distinct BOOLEAN DEFAULT FALSE, -- Indicates if the transformation is a DISTINCT operation,
    source_table_name TEXT,
    target_table_name TEXT,
    description TEXT,
    step_index INT, -- Step index for ordering transformations
    stage_key TEXT REFERENCES STAGES(stage_key), -- Stage key for grouping transformations
    PRIMARY KEY (source_table_name, target_table_name, stage_key, step_index),
    UNIQUE (transformation_key)
);

-- Target Mapping table using natural keys
CREATE TABLE target_mapping
(
    transformation_key TEXT,
    target_table_name TEXT,
    target_column_name TEXT,
    function_name function_name REFERENCES functions(function_name),
    source_table_name TEXT,
    PRIMARY KEY (transformation_key, target_table_name, target_column_name),
    FOREIGN KEY (transformation_key) REFERENCES transformations(transformation_key) ON DELETE CASCADE
);

-- Input Mapping table using references to target mapping natural keys
CREATE TABLE input_mapping
(
    transformation_key TEXT,
    target_table_name TEXT,
    target_column_name TEXT,
    source_table_name TEXT,
    source_column_name TEXT,
    input_order INT,
    in_group_by BOOLEAN DEFAULT FALSE, -- Indicates if this input is part of a GROUP BY
    PRIMARY KEY (target_table_name, target_column_name, source_table_name, source_column_name, input_order),
    FOREIGN KEY (transformation_key,target_table_name, target_column_name) REFERENCES target_mapping(transformation_key,target_table_name, target_column_name) ON DELETE CASCADE
);

-- Join Mappings table using transformation natural keys
CREATE TABLE join_mappings
(
    transformation_key TEXT,
    join_mapping_key TEXT PRIMARY KEY,  -- Human-readable, string-based identifier
    join_table_name TEXT,
    join_type join_type, -- ENUM type for join methods such as 'INNER', 'LEFT', etc.
    FOREIGN KEY (transformation_key) REFERENCES transformations(transformation_key) ON DELETE CASCADE
);

CREATE TABLE join_conditions_mapping
(
    condition_id SERIAL PRIMARY KEY,
    join_mapping_key TEXT NOT NULL,
    lhs_column TEXT NOT NULL,  -- Left-hand side of the condition, typically a column name
    rhs_column TEXT NOT NULL,  -- Right-hand side of the condition, can be a column name or a literal value
    operator TEXT NOT NULL CHECK (operator IN ('=', '!=', '<', '>', '<=', '>=')), -- Comparison operator
    FOREIGN KEY (join_mapping_key) REFERENCES join_mappings(join_mapping_key) ON DELETE CASCADE
);


CREATE TABLE conditions
(
    transformation_key TEXT,
    condition_key TEXT,
    side_a_condition_function function_name,
    side_b_condition_function function_name,
    FOREIGN KEY (transformation_key) REFERENCES transformations(transformation_key) ON DELETE CASCADE,
    PRIMARY KEY (transformation_key, condition_key)
);

DROP TYPE IF EXISTS CONDITION_EXPRESSION_SIDE CASCADE; -- Drop existing enum type if it exists, cascading to dependent objects
CREATE TYPE CONDITION_EXPRESSION_SIDE as ENUM ('LEFT', 'RIGHT'); -- What side of the condition is the expression on
-- Not actually needed but helps with primary key tracking

CREATE TABLE condition_inputs
(
    condition_key TEXT,
    transformation_key TEXT,
    side CONDITION_EXPRESSION_SIDE, -- Side of the condition the input is on, LEFT or RIGHT
    source_table_name TEXT,
    source_column_name TEXT,
    FOREIGN KEY (condition_key, transformation_key) REFERENCES conditions(transformation_key, condition_key)  ON DELETE CASCADE,
    PRIMARY KEY (condition_key, transformation_key, side, source_table_name, source_column_name)
);