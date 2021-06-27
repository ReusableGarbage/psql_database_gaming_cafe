# psql_database_gaming_cafe
A database in PSQL representing a gaming cafe
It tracks:
*Staff
*Customers
*PCs
*PC logs
*Staff shifts

Please do check included conceptual model (konceptualni_model_cafe) and ER diagram (ER_model_cafe)

This database implements
*IsA relationship
*Exclusive relationship
*Weak entities
*custom data types

*triggers
*functions in PLPGSQL
*procedures in PLPSQL
*some sample queries

The database can be intiated using create.sql
Data integrity is ensured in both create.sql and triggery_funkce.sq

Triggers
*Ensure password encryption
*Ensure IsA and Exclusice relationship

Procedures
*Enable easy data inserts without tasking users with foreign keys and data integrity

Custom data types
This database implements custom data types for the following:
*Email - email_DOM
*National identification number - rc_DOM
*Telephone number - telefon_DOM
*PC status - stav_ENUM

National identification number checks for a czech format, aka "rodné číslo"
IMPORTANT: This datatype allows only logical values, range of months, gender specification
but it does not implement "divisibility" check. I would recommend to implement this with a trigger, if needed. 

PC status represents following states:
*ONLINE
*OFFLINE
*SERVICE

Extensions required to install
*CITEXT (for emails)
*PGCRYPTO (for pswd encryption)