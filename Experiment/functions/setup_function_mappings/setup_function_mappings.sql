 --Function to safely convert string to timestamp

SET SEARCH_PATH=mtf;
TRUNCATE TABLE functions CASCADE;
TRUNCATE TABLE function_inputs


/*
 SAFE TO TIMESTAMP
 */
INSERT INTO functions (function_name, function_definition)
VALUES ('safe_to_timestamp', 'CAST (to_timestamp($1, ''YYYY-MM-DD HH24:MI:SS'') AS timestamp)');

-- Function to return a fixed boolean value
INSERT INTO functions (function_name, function_definition)
VALUES ('return_boolean', 'SELECT $1::boolean');

-- Function to return a fixed enum type
INSERT INTO functions (function_name, function_definition)
VALUES ('return_enum', 'SELECT $1::dbo.questionnaire_response_notes_notetype_enum');