-- Test that safe_to_timestamp correctly converts a valid timestamp string
DO $$
DECLARE
    result timestamp;
BEGIN
    result := safe_to_timestamp('2022-12-31 23:59:59', 'YYYY-MM-DD HH24:MI:SS');
    IF result::text != '2022-12-31 23:59:59' THEN
        RAISE EXCEPTION 'Test failed: expected 2022-12-31 23:59:59, got %', result;
    END IF;
END $$;

-- Test that safe_to_timestamp returns NULL for an invalid timestamp string
DO $$
DECLARE
    result timestamp;
BEGIN
    result := safe_to_timestamp('not a timestamp', 'YYYY-MM-DD HH24:MI:SS');
    IF result IS NOT NULL THEN
        RAISE EXCEPTION 'Test failed: expected NULL, got %', result;
    END IF;
END $$;

-- Test that safe_to_timestamp returns NULL for a valid timestamp string with wrong format
DO $$
DECLARE
    result timestamp;
BEGIN
    result := safe_to_timestamp('2022-13-31 23:59:59', 'YYYY-MM-DD');
    IF result IS NOT NULL THEN
        RAISE EXCEPTION 'Test failed: expected NULL, got %', result;
    END IF;
END $$;