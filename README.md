<div align="center">
  <picture>
    <img alt="The Rust Programming Language: A language empowering everyone to build reliable and efficient software"
         src="docs/assets/mtf_logo.png"
         width="25%">
  </picture>
</div>

# MTF - Metadata-Driven Transformation Framework 

## TL;DR
A Postgres program that enables users to create transformation logic using a data driven approach.
> Don't use code for your transformations. Use data.

## Introduction
Want to use a data driven approach to creating your transformation logic? This framework is for you.
This means you can define your transformation logic without writing huge  this means you can easily change your transformation logic without having to change your code.

### Benefits
- Define transformation logic using data
  - This makes your logic queryable & easily modifiable
- Extract the transformation logic from individual scripts for better testing
- Easily modify transformation logic 


## How to - My First MTF Pipeline 
> Ensure you understand the basic concepts of the framework before using it. See Transformation Core Concepts below.

1. Create the mapping tables 
    - src/mappings/01_DEFINE_MAPPINGS.sql
2. Create Functions
    - src/functions/* 
3. Create the Function Mappings & Enums 
    - src/functions/03_DEFINE_FUNCTION_MAPPINGS.sql
4. Create the Transformation 
    - src/procs/04_DEFINE_PROCS.sql
5. Use the examples 

## Transformation Core Concepts  

### Diagram 
![Diagram of Meta Data Driven Framework](docs/assets/mtfdiagram.png)

### Transformations 
This entity represents a transformation that is applied to a table. 
Consider this the table you ```INSERT INTO```

### Target Mapping 
This represents an output column, of which there can be many inputs to. A target mapping can have a function applied to it to transform the data.
Consider this the column you ```INSERT INTO```

### Function
The definition of a function that can be applied to a target mapping.
Consider this the function you apply to a column in a ```SELECT``` statement.

### Function Input 
The definitions of the inputs which can be inserted into a function.
Consider this the parameters you pass to a function in a ```SELECT``` statement.


### Join Mappings 
The definitions of tables to join to when performing a transformation.
Consider this the tables you ```JOIN``` to in a ```SELECT``` statement.

## Todo: 
- Build Auto Install script fot MTF 
- Build out a nice testing framework for MTF
- Build Docs 
- Build out the concept of stages.. I.E Staging -> Transformation -> Reporting
- Build out the concept of data dictionaries
- Build out the concept of data quality checks
- Build out the concept of data lineage
- Build out the concept of data versioning
- Build a UI for MTF