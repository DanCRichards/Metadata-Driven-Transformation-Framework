/*
 SETUP UP
 */

CREATE SCHEMA IF NOT EXISTS landing;
CREATE TABLE IF NOT EXISTS landing.notes
(
    note_id       integer,
    personal_id   integer,
    details       text,
    "userCreated" integer,
    "dateCreated" text
);

CREATE SCHEMA IF NOT EXISTS dbo;
/* Please uncomment
-- create table IF NOT EXISTS dbo.questionnaire_response
(
    "PersonalId"                      integer
);
 */


CREATE SCHEMA IF NOT EXISTS staging;
CREATE TABLE IF NOT EXISTS staging.users
(
    "UserAuth0Id"           text,
    "Email"                 text,
    "CreatedTimeStamp"      timestamp with time zone,
    "LastLoggedInTimeStamp" text,
    "FirstName"             text,
    "LastName"              text,
    "Title"                 text,
    "Credentials"           text,
    "JobTitle"              text,
    "Country"               text,
    "SoftDeleted"           boolean,
    "Phone"                 text,
    "BubbleGateuserId"      integer
);





INSERT INTO landing.notes (note_id, personal_id, details, "userCreated", "dateCreated")
VALUES
    (1, 100, 'Note details 1', 1, '2022-01-01'),
    (2, 101, 'Note details 2', 2, '2022-01-02'),
    (3, 102, 'Note details 3', 3, '2022-01-03'),
    (4, 103, 'Note details 4', 4, '2022-01-04'),
    (5, 104, 'Note details 5', 5, '2022-01-05');

-- Insert data into dbo.questionnaire_response
INSERT INTO dbo.questionnaire_response ("PersonalId")
VALUES
    (100),
    (101),
    (102),
    (103),
    (104);

