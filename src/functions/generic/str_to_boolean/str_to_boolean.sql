SET search_path TO mtf;
CREATE OR REPLACE FUNCTION str_to_boolean(input_text TEXT) RETURNS BOOLEAN AS $$
BEGIN
    -- Normalize the input text to lower case for case-insensitive comparison
    input_text := LOWER(input_text);

    -- Return true for 'true', 'yes', '1' representations
    IF input_text IN ('true', 'yes', '1') THEN
        RETURN TRUE;
    -- Return false for 'false', 'no', '0' representations
    ELSIF input_text IN ('false', 'no', '0') THEN
        RETURN FALSE;
    END IF;

    -- Optionally handle invalid input
    -- Raise an exception if the input is not recognized
    RAISE EXCEPTION 'Invalid input for boolean conversion: %', input_text;
    RETURN NULL; -- This line is never reached, but function must have a RETURN
END;
$$ LANGUAGE plpgsql STRICT;
