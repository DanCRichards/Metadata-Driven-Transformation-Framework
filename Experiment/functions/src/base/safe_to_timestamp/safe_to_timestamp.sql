CREATE OR REPLACE FUNCTION safe_to_timestamp(text, text)
RETURNS TIMESTAMP AS $$
BEGIN
    RETURN TO_TIMESTAMP($1, $2);
EXCEPTION WHEN others THEN
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

INSERT INTO functions (function_name, function_definition)
VALUES ('safe_to_timestamp', 'CAST (to_timestamp($1, ''YYYY-MM-DD HH24:MI:SS'') AS timestamp)');


-- Function to return a fixed enum type
INSERT INTO functions (function_name, function_definition)
VALUES ('return_enum', 'SELECT $1::dbo.questionnaire_response_notes_notetype_enum');