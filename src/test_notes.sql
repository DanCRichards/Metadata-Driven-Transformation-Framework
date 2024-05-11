SET SEARCH_PATH=mtf;

TRUNCATE TABLE functions CASCADE;
-- Function to safely convert string to timestamp
INSERT INTO functions (function_name, function_definition)
VALUES ('safe_to_timestamp', 'CAST (to_timestamp($1, ''YYYY-MM-DD HH24:MI:SS'') AS timestamp)');

-- Function to return a fixed boolean value
INSERT INTO functions (function_name, function_definition)
VALUES ('return_boolean', 'SELECT $1::boolean');

-- Function to return a fixed enum type
INSERT INTO functions (function_name, function_definition)
VALUES ('return_enum', 'SELECT $1::dbo.questionnaire_response_notes_notetype_enum');


INSERT INTO transformations (source_table_name, target_table_name, description)
VALUES ('landing.notes', 'mtf_staging.notes', 'Transform landing notes to staging format with enrichment and cleansing.');



-- Assuming transformation_id from transformations table is 1
-- Join with questionnaire_response
INSERT INTO join_mappings (transformation_id, join_type, source_table_name, target_table_name, join_condition)
VALUES (1, 'INNER', 'landing.notes', 'dbo.questionnaire_response', 'landing.notes.personal_id = dbo.questionnaire_response.PersonalId');

-- Join with users table for Auth0Id
INSERT INTO join_mappings (transformation_id, join_type, source_table_name, target_table_name, join_condition)
VALUES (1, 'LEFT', 'landing.notes', 'staging.users', 'landing.notes.userCreated = staging.users.BubbleGateuserId');




-- Mapping for 'QuestionnaireResponseId'
INSERT INTO target_mapping (target_table_name, target_column_name, function_id)
VALUES ('mtf_staging.notes', 'QuestionnaireResponseId', 1); -- Assuming function_id for direct assignment

INSERT INTO input_mapping (target_mapping_id, source_table_name, source_column_name, input_order, in_group_by)
VALUES (1, 'dbo.questionnaire_response', 'QuestionnaireResponseId', 1, FALSE);

-- Mapping for 'Note'
INSERT INTO target_mapping (target_table_name, target_column_name, function_id)
VALUES ('mtf_staging.notes', 'Note', 1);

INSERT INTO input_mapping (target_mapping_id, source_table_name, source_column_name, input_order, in_group_by)
VALUES (2, 'landing.notes', 'details', 1, FALSE);

-- Mapping for 'CreatedTimeStamp'
INSERT INTO target_mapping (target_table_name, target_column_name, function_id)
VALUES ('mtf_staging.notes', 'CreatedTimeStamp', 2); -- function_id for safe_to_timestamp

INSERT INTO input_mapping (target_mapping_id, source_table_name, source_column_name, input_order, in_group_by)
VALUES (3, 'landing.notes', 'dateCreated', 1, FALSE);

-- Mapping for 'SoftDeleted'
INSERT INTO target_mapping (target_table_name, target_column_name, function_id)
VALUES ('mtf_staging.notes', 'SoftDeleted', 3);

INSERT INTO input_mapping (target_mapping_id, source_table_name, source_column_name, input_order, in_group_by)
VALUES (4, '', 'false', 1, TRUE); -- Using constant

-- Mapping for 'CreatedByUserAuth0Id'
INSERT INTO target_mapping (target_table_name, target_column_name, function_id)
VALUES ('mtf_staging.notes', 'CreatedByUserAuth0Id', 1);

INSERT INTO input_mapping (target_mapping_id, source_table_name, source_column_name, input_order, in_group_by)
VALUES (5, 'staging.users', 'UserAuth0Id', 1, FALSE);

-- Mapping for 'userCreated'
INSERT INTO target_mapping (target_table_name, target_column_name, function_id)
VALUES ('mtf_staging.notes', 'userCreated', 1);

INSERT INTO input_mapping (target_mapping_id, source_table_name, source_column_name, input_order, in_group_by)
VALUES (6, 'landing.notes', 'userCreated', 1, FALSE);

-- Mapping for 'NoteType'
INSERT INTO target_mapping (target_table_name, target_column_name, function_id)
VALUES ('mtf_staging.notes', 'NoteType', 4); --
