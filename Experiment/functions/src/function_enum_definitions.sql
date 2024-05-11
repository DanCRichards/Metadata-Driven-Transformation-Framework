/*
 Defines the enum which is used on joins to refer to functions!

 When you add a function you simply add it to this enum so that there is a level of typing between the function names and there reference
 */

 CREATE TYPE function_type AS ENUM (
    'direct_assignment',
    'safe_to_timestamp',
    'return_boolean',
    'return_enum'
);
