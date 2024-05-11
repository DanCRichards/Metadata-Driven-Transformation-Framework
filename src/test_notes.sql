SET SEARCH_PATH = mtf;

-- Truncating tables to reset data
TRUNCATE TABLE transformations CASCADE;
TRUNCATE TABLE join_mappings CASCADE;
TRUNCATE TABLE target_mapping CASCADE;
TRUNCATE TABLE input_mapping CASCADE;

-- Inserting transformations
INSERT INTO transformations (source_table_name, target_table_name, description)
VALUES
    ('landing.notes', 'staging.notes', 'Transforms notes from landing area to staging with enriched and formatted fields.');

-- Inserting join mappings using the natural key relationships
INSERT INTO join_mappings (source_table_name, target_table_name, join_type, join_condition)
VALUES
    ('landing.notes', 'staging.notes', 'INNER', 'landing.notes.personal_id = dbo.questionnaire_response.PersonalId'),
    ('landing.notes', 'staging.notes', 'LEFT', 'landing.notes.userCreated = staging.users.BubbleGateuserId');

-- Inserting target mappings
INSERT INTO target_mapping (target_table_name, target_column_name, function_name, source_table_name)
VALUES
    ('staging.notes', 'QuestionnaireResponseId', 'direct_assignment', 'landing.notes'),
    ('staging.notes', 'Note', 'direct_assignment', 'landing.notes'),
    ('staging.notes', 'CreatedTimeStamp', 'safe_to_timestamp', 'landing.notes'),
    ('staging.notes', 'SoftDeleted', 'str_to_boolean', 'landing.notes'),
    ('staging.notes', 'CreatedByUserAuth0Id', 'direct_assignment', 'landing.notes'),
    ('staging.notes', 'userCreated', 'direct_assignment', 'landing.notes'),
    ('staging.notes', 'NoteType', 'direct_assignment', 'landing.notes');

-- Inserting input mappings, ensuring they reference the target mapping directly
INSERT INTO input_mapping (target_table_name, target_column_name, source_table_name, source_column_name, input_order, in_group_by)
VALUES
    ('staging.notes', 'QuestionnaireResponseId', 'dbo.questionnaire_response', 'QuestionnaireResponseId', 1, FALSE),
    ('staging.notes', 'Note', 'landing.notes', 'details', 1, FALSE),
    ('staging.notes', 'CreatedTimeStamp', 'landing.notes', 'dateCreated', 1, FALSE),
    ('staging.notes', 'SoftDeleted', '', 'false', 1, TRUE),  -- for constant values
    ('staging.notes', 'CreatedByUserAuth0Id', 'staging.users', 'UserAuth0Id', 1, FALSE),
    ('staging.notes', 'userCreated', 'landing.notes', 'userCreated', 1, FALSE),
    ('staging.notes', 'NoteType', '', 'Private', 1, TRUE);  -- Assuming 'Private' is a constant for enum
