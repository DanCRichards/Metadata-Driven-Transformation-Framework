SET SEARCH_PATH=mtf;
INSERT INTO functions (function_name, function_definition)
VALUES ('return_boolean', 'SELECT $1::boolean');
