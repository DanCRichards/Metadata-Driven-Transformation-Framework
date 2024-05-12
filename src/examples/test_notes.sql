SET SEARCH_PATH = mtf;

-- Truncating tables to reset data
TRUNCATE TABLE transformations CASCADE;
TRUNCATE TABLE join_mappings CASCADE;
TRUNCATE TABLE target_mapping CASCADE;
TRUNCATE TABLE input_mapping CASCADE;

-- Inserting transformations
INSERT INTO transformations (transformation_key, source_table_name, target_table_name, description)
VALUES
    ('test_notes','landing.notes', 'staging.notes', 'Transforms notes from landing area to staging with enriched and formatted fields.');

-- Inserting join mappings with human-readable IDs
INSERT INTO join_mappings (transformation_key, join_mapping_key, join_table_name, join_type)
VALUES
    ('test_notes','NotesResponseJoin', 'dbo.questionnaire_response', 'INNER'),
    ('test_notes','NotesUserJoin', 'staging.users', 'LEFT');

-- Inserting join conditions using the new table structure
INSERT INTO join_conditions_mapping (join_mapping_key, lhs_column, rhs_column, operator)
VALUES
    ('NotesResponseJoin', 'landing.notes.personal_id', 'dbo.questionnaire_response."PersonalId"', '='),
    ('NotesUserJoin', 'landing.notes."userCreated"', 'staging.users."BubbleGateuserId"', '=');


-- Inserting target mappings
INSERT INTO target_mapping (target_table_name, target_column_name, function_name, source_table_name)
VALUES
    ('staging.notes', 'QuestionnaireResponseId', '', 'landing.notes'),
    ('staging.notes', 'Note', '', 'landing.notes'),
    ('staging.notes', 'CreatedTimeStamp', 'safe_to_timestamp', 'landing.notes'),
    ('staging.notes', 'SoftDeleted', 'str_to_boolean', 'landing.notes'),
    ('staging.notes', 'CreatedByUserAuth0Id', '', 'landing.notes'),
    ('staging.notes', 'userCreated', '', 'landing.notes'),
    ('staging.notes', 'NoteType', '', 'landing.notes');

-- Inserting input mappings, ensuring they reference the target mapping directly
INSERT INTO input_mapping (target_table_name, target_column_name, source_table_name, source_column_name, input_order, in_group_by)
VALUES
    ('staging.notes', 'QuestionnaireResponseId', 'dbo.questionnaire_response', 'QuestionnaireResponseId', 1, FALSE),
    ('staging.notes', 'Note', 'landing.notes', 'details', 1, FALSE),
    ('staging.notes', 'CreatedTimeStamp', 'landing.notes', 'dateCreated', 1, FALSE),
    ('staging.notes', 'CreatedTimeStamp', '', 'YYYY-MM-DD', 2, FALSE),
    ('staging.notes', 'SoftDeleted', '', 'false', 1, TRUE),  -- for constant values
    ('staging.notes', 'CreatedByUserAuth0Id', 'staging.users', 'UserAuth0Id', 1, FALSE),
    ('staging.notes', 'userCreated', 'landing.notes', 'userCreated', 1, FALSE),
    ('staging.notes', 'NoteType', '', 'Private', 1, TRUE);  -- Assuming 'Private' is a constant for enum


    call perform_transformation('test_notes');


    SELECT * FROM staging.notes

