/*
 Defines the enum which is used on joins to refer to functions!

 When you add a function you simply add it to this enum so that there is a level of typing between the function names and there reference
 */

 SET SEARCH_PATH=mtf;

-- Inserting predefined functions into the functions table
TRUNCATE TABLE functions CASCADE;
INSERT INTO functions (function_name, function_definition)
VALUES
    ('', 'Directly assigns values without transformation'),
    ('safe_to_timestamp', 'Converts string to timestamp safely'),
    ('str_to_boolean', 'Returns a fixed boolean value'),
    ('return_enum', 'Returns a specified enum value');


