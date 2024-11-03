-- 1) SQL DDL
-- ----------------------------------------------------------------------------------------------------------------
-- Clean up first

DROP TABLE IF EXISTS brand;
DROP TABLE IF EXISTS representative;
DROP TABLE IF EXISTS person;
DROP TABLE IF EXISTS certification;

DROP TABLE IF EXISTS club;
DROP TABLE IF EXISTS hiker;
DROP TABLE IF EXISTS guide;
DROP TABLE IF EXISTS company;

DROP TABLE IF EXISTS product;

DROP TABLE IF EXISTS trip;

DROP TABLE IF EXISTS destination;
DROP TABLE IF EXISTS package;

-- ----------------------------------------------------------------------------------------------------------------
-- Create the tables

CREATE TYPE name_composite AS (
    first_name varchar(50),
    last_name varchar(50)
);

CREATE TABLE person (
    ID integer PRIMARY KEY,
    Name name_composite, 
    Address varchar(100),
    SSN integer,
    Phone integer
);