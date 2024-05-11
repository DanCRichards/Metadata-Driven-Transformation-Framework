## Functions


All the functions defined. 


## Folder Directory
- generic - functions that can be used anywhere 
- table_based - Table specific functions 
  - notes....


## Creating a new function
1. Create the function code in the appropriate folder as per above. 
2. Write the test cases for the function in a file that ends with .test.sql 
3. Add the name of the function to the function_name enum within index.sql file 
3. Add the function mapping to the functions_mapping table within the index.sql file 


## How Function Referencing Works 

> There is a enum which references all the different types of functions that are available. This is used to reference the function in the functions_mapping table.

The function_name enum is used to reference the function in the functions_mapping table. 


## TODO: 
- Split all the functions out into different folders
- Write tests for all the functions