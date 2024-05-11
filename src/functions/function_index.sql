/*
 Defines the enum which is used on joins to refer to functions!

 When you add a function you simply add it to this enum so that there is a level of typing between the function names and there reference
 */

 SET SEARCH_PATH=mtf;

DROP TYPE IF EXISTS function_name CASCADE;  -- Drop existing enum type if it exists, cascading to dependent objects
 CREATE TYPE function_name AS ENUM (
    'direct_assignment',
    'safe_to_timestamp',
    'str_to_boolean',
    'return_enum'
);

-- Inserting predefined functions into the functions table
TRUNCATE TABLE functions CASCADE;
INSERT INTO functions (function_name, function_definition)
VALUES
    ('direct_assignment', 'Directly assigns values without transformation'),
    ('safe_to_timestamp', 'Converts string to timestamp safely'),
    ('str_to_boolean', 'Returns a fixed boolean value'),
    ('return_enum', 'Returns a specified enum value');

SELECT * FROM functions



CALL process_notes_transformation();



SET SEARCH_PATH =mtf_staging;
INSERT INTO staging.notes ("QuestionnaireResponseId", "Note", "Note", "CreatedTimeStamp", "CreatedTimeStamp",
                           "SoftDeleted", "CreatedByUserAuth0Id", "userCreated", "userCreated", "NoteType")
SELECT direct_assignment(dbo.questionnaire_response."QuestionnaireResponseId") AS "QuestionnaireResponseId",
       direct_assignment(landing.notes.details)                                AS "Note",
       direct_assignment(landing.notes.details)                                AS "Note",
       safe_to_timestamp(landing.notes."dateCreated")                          AS "CreatedTimeStamp",
       safe_to_timestamp(landing.notes."dateCreated")                          AS "CreatedTimeStamp",
       str_to_boolean('false')                                                 AS "SoftDeleted",
       direct_assignment(staging.users."UserAuth0Id")                          AS "CreatedByUserAuth0Id",
       direct_assignment(landing.notes."userCreated")                          AS "userCreated",
       direct_assignment(landing.notes."userCreated")                          AS "userCreated",
       direct_assignment('Private')                                            AS "NoteType"
FROM landing.notes
         INNER JOIN landing.notes ON landing.notes.personal_id = dbo.questionnaire_response.PersonalId
         INNER JOIN landing.notes ON landing.notes.personal_id = dbo.questionnaire_response.PersonalId
         LEFT JOIN landing.notes ON landing.notes.userCreated = staging.users.BubbleGateuserId
         LEFT JOIN landing.notes ON landing.notes.userCreated = staging.users.BubbleGateuserId
         INNER JOIN landing.notes ON landing.notes.personal_id = dbo.questionnaire_response.PersonalId
         INNER JOIN landing.notes ON landing.notes.personal_id = dbo.questionnaire_response.PersonalId
         LEFT JOIN landing.notes ON landing.notes.userCreated = staging.users.BubbleGateuserId
         LEFT JOIN landing.notes ON landing.notes.userCreated = staging.users.BubbleGateuserId
         INNER JOIN landing.notes ON landing.notes.personal_id = dbo.questionnaire_response.PersonalId
         INNER JOIN landing.notes ON landing.notes.personal_id = dbo.questionnaire_response.PersonalId
         LEFT JOIN landing.notes ON landing.notes.userCreated = staging.users.BubbleGateuserId
         LEFT JOIN landing.notes ON landing.notes.userCreated = staging.users.BubbleGateuserId;

SELECT tm.target_table_name, tm.target_column_name, tm.function_name, im.source_table_name,
       CASE WHEN (TRIM(tm.source_table_name) = '') IS NOT FALSE THEN
           'USE .'
           ELSE
           'USE '
               END as period_usage,
       im.source_column_name, jm.join_type, jm.join_condition
                  FROM target_mapping tm
                  LEFT JOIN input_mapping im ON tm.target_table_name = im.target_table_name AND tm.target_column_name = im.target_column_name
                  LEFT JOIN join_mappings jm ON jm.source_table_name = im.source_table_name AND jm.target_table_name = tm.target_table_name
                  WHERE tm.target_table_name = 'staging.notes'