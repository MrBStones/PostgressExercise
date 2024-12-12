-- 1) SQL DDL
-- Write SQL DDL commands to create the hiking database of Homework 2. Your script must
-- implement the official solution ER diagram posted on LearnIT, run in PostgreSQL as a
-- whole, and use the methodology in the textbook and lectures. The relations must include
-- all relevant primary key, candidate key, foreign key, and NOT NULL constraints. If these
-- standard constraints cannot enforce certain restrictions, you can omit them (but if you are
-- having fun, feel free to implement queries to detect violations or triggers to prevent them).
-- Please keep in mind that your SQL DDL script should address any additional requirements
-- from Homework 2 that couldn’t be represented in the ER diagram but can be implemented
-- in the DDL (e.g., additional keys). Select reasonable types for attributes.

-- ----------------------------------------------------------------------------------------------------------------
-- Clean up first

-- Drop tables with foreign key dependencies
DROP TABLE IF EXISTS rates CASCADE;
DROP TABLE IF EXISTS guides CASCADE;
DROP TABLE IF EXISTS participates CASCADE;
DROP TABLE IF EXISTS contains CASCADE;
DROP TABLE IF EXISTS works_for CASCADE;
DROP TABLE IF EXISTS represents CASCADE;
DROP TABLE IF EXISTS is_member_of CASCADE;

-- Drop main tables
DROP TABLE IF EXISTS trip CASCADE;
DROP TABLE IF EXISTS package CASCADE;
DROP TABLE IF EXISTS destination CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS company CASCADE;
DROP TABLE IF EXISTS certification CASCADE;
DROP TABLE IF EXISTS guide CASCADE;
DROP TABLE IF EXISTS brand CASCADE;
DROP TABLE IF EXISTS club CASCADE;
DROP TABLE IF EXISTS hiker CASCADE;
DROP TABLE IF EXISTS representative CASCADE;
DROP TABLE IF EXISTS person CASCADE;

-- Drop composite types
DROP TYPE IF EXISTS name_composite CASCADE;


-- ----------------------------------------------------------------------------------------------------------------
-- Create the tables

CREATE TYPE name_composite AS (
    first_name varchar(50),
    last_name varchar(50)
);

CREATE TABLE person (
    ID integer PRIMARY KEY,
    Name name_composite NOT NULL, 
    Address varchar(100) NOT NULL,
    SSN integer NOT NULL,
    Phone integer UNIQUE NOT NULL
);

CREATE TABLE representative (
    ID integer PRIMARY KEY
);

CREATE TABLE hiker (
    Highest_peak varchar(100) NULL,
    RepresentativeID integer NULL REFERENCES representative(ID),
    UNIQUE (ID)
) INHERITS (person);

CREATE TABLE club (
    ID integer PRIMARY KEY,
    Name varchar(100) NOT NULL,
    Est_date date NOT NULL,
    RepresentativeID integer NULL REFERENCES representative(ID)
);

CREATE TABLE brand (
    ID integer PRIMARY KEY,
    Name varchar(100) NOT NULL
);

CREATE TABLE guide (
    Specialization varchar(100) NOT NULL,
    UNIQUE (ID)
) INHERITS (person);

CREATE TABLE certification (
    GuideID integer NOT NULL,
    Name varchar(50) NOT NULL,
    Issue_date date NOT NULL,
    Academy varchar(100) NOT NULL,
    Grade char NOT NULL CHECK (Grade ~ '^[A-F]$'),

    PRIMARY KEY (GuideID, Name),
    FOREIGN KEY (GuideID) REFERENCES guide(ID) ON DELETE CASCADE
);

CREATE TABLE company (
    ID integer PRIMARY KEY,
    Name varchar(100) NOT NULL
);

CREATE TABLE product ( 
    ID integer PRIMARY KEY,
    Price decimal NOT NULL,
    Sold_by integer NOT NULL REFERENCES company(ID)
);

CREATE TABLE destination (
    Name varchar(100) NOT NULL,
    Trackname varchar(100) NOT NULL,
    Distance decimal NOT NULL,
    Difficulty integer NOT NULL,
    Elevation integer NOT NULL,
    Prerequisites integer REFERENCES destination(ID),
    UNIQUE (ID)
) INHERITS (product);

CREATE TABLE package (
    Name varchar(100) NOT NULL,
    Difficulty integer NOT NULL,
    UNIQUE (ID)
) INHERITS (product);

CREATE TABLE trip (
    ID integer PRIMARY KEY,
    Start_date date NOT NULL,
    Has integer NOT NULL REFERENCES destination(ID)
);



-- ----------------------------------------------------------------------------------------------------------------
-- Create extra links

CREATE TABLE is_member_of (
    HikerID integer NOT NULL REFERENCES hiker(ID),
    ClubID integer NOT NULL REFERENCES club(ID),
    PRIMARY KEY (HikerID, ClubID)
);

CREATE TABLE represents ( 
    RepresentativeID integer UNIQUE NOT NULL REFERENCES representative(ID),
    BrandID integer NOT NULL REFERENCES brand(ID),
    Payment decimal NOT NULL,
    PRIMARY KEY (RepresentativeID)
);

CREATE TABLE works_for (
    GuideID integer NOT NULL REFERENCES guide(ID),
    CompanyID integer NOT NULL REFERENCES company(ID),
    Start_date date NOT NULL,
    End_date date,
    PRIMARY KEY (GuideID, Start_date)
);

CREATE TABLE contains (
    PackageID integer NOT NULL REFERENCES package(ID),
    DestinationID integer NOT NULL REFERENCES destination(ID),
    PRIMARY KEY (PackageID, DestinationID)
);

CREATE TABLE participates (
    ID integer PRIMARY KEY,
    HikerID integer NOT NULL REFERENCES hiker(ID),
    TripID integer NOT NULL REFERENCES trip(ID),
    UNIQUE (HikerID, TripID)
);

CREATE TABLE guides (
    ID integer PRIMARY KEY,
    GuideID integer NOT NULL REFERENCES guide(ID),
    TripID integer NOT NULL REFERENCES trip(ID),
    UNIQUE (GuideID, TripID)
);

CREATE TABLE rates (
    ParitcipatesID integer REFERENCES participates(ID),
    GuidesID integer REFERENCES guides(ID),
    Date date NOT NULL,
    Rating varchar(256) NOT NULL,
    PRIMARY KEY (ParitcipatesID, GuidesID)
);



-- 2) Practical Normalization
-- In the homework quiz on LearnIT, you will find a script to create and populate five in-
-- dependent relations, each having seven columns and a primary key with a few thousand
-- rows. For this project, use only the Rentals relation!
-- Each relation models a potential real-life database design situation, with some design flaws
-- that must be addressed. In short, each of the relations has embedded a set of functional
-- dependencies, which are not stated explicitly. You must a) find these dependencies and b)
-- use them to guide the decomposition of the relations to 3NF/BCNF normal forms, using
-- the methodology covered in class.
-- Note: In the homework quiz on LearnIT, you can find some additional material (slides,
-- code, and video) to help you get started with this exercise.

-- 2.1) Steps
-- More specifically, for the Rental relation, take the following steps:
-- (a) Find all the important FDs in the relations, given the constraints and simplifying
-- assumptions that are listed in detail below.

-- PID --> PN | MAY HOLD

-- HID --> HS | MAY HOLD

-- HID --> HZ | MAY HOLD

-- HID --> HC | MAY HOLD

-- HZ --> HC | MAY HOLD

-- -- Old table
-- PID A
-- HID B

-- PN C
-- S D
-- HS E
-- HZ F
-- HC G
-- PRIMARY KEY (PID, HID)

-- Note: We strongly recommend using your favorite programming language to generate
-- an SQL script with all the FD detection queries, using the SQL query template covered
-- in slide 44 of the provided slides for this quiz. The program could take as input a list
-- of column names, and output all the required SQL queries into a text file. You can
-- then run the text file using psql. Figure 1 shows example Python code to get you
-- started.

-- (b) Decompose the relation until each sub-relation is in 3NF/BCNF, while preserving
-- all non-redundant FDs. Write down the resulting schema description in a simple
-- Relation(columns) format.

-- A --> C | MAY HOLD

-- B --> E | MAY HOLD

-- B --> F | MAY HOLD

-- B --> G | MAY HOLD

-- F --> G | MAY HOLD

-- -- keys
-- A INT NOT NULL,
-- B INT NOT NULL, 

-- -- Others 
-- C VARCHAR(50) NOT NULL, 
-- D INT NOT NULL, 
-- E VARCHAR(50) NOT NULL,
-- F INT NOT NULL, 
-- G VARCHAR(50) NOT NULL,
-- PRIMARY KEY (PID, HID)

-- -- new table
-- PID
-- PN 
-- PRIMARY KEY (PID)

-- -- new table
-- HID
-- HS
-- HZ
-- PRIMARY KEY (HID)

-- -- new table
-- HZ 
-- HC 
-- PRIMARY KEY (HZ)

-- -- Old table
-- PID
-- HID
-- S
-- PRIMARY KEY (PID, HID)

-- (c) Write the detailed SQL commands to create the resulting tables (with primary and
-- foreign keys) and populate them, by extracting the relevant data from the original
-- relations.

DROP TABLE IF EXISTS NewRentals;
DROP TABLE IF EXISTS NewRentalsA;
DROP TABLE IF EXISTS NewRentalsB;
DROP TABLE IF EXISTS NewRentalsC;


CREATE TABLE NewRentals (
       PID INT NOT NULL,
       HID INT NOT NULL, 
       S INT NOT NULL, 
       PRIMARY KEY (PID, HID)
);

CREATE TABLE NewRentalsA (
       PID INT NOT NULL,
       PN VARCHAR(50) NOT NULL, 
       PRIMARY KEY (PID)
);

CREATE TABLE NewRentalsC (
       HZ INT NOT NULL, 
       HC VARCHAR(50) NOT NULL,
       PRIMARY KEY (HZ)
);

CREATE TABLE NewRentalsB (
       HID INT NOT NULL, 
       HS VARCHAR(50) NOT NULL,
       HZ INT NOT NULL REFERENCES NewRentalsC(HZ), 
       PRIMARY KEY (HID)
);

INSERT INTO NewRentals SELECT PID, HID, S FROM Rentals;
INSERT INTO NewRentalsA SELECT DISTINCT PID, PN FROM Rentals;
INSERT INTO NewRentalsC SELECT DISTINCT HZ, HC FROM Rentals;
INSERT INTO NewRentalsB SELECT DISTINCT HID, HS, HZ FROM Rentals;



-- Note: In this homework, use the “homework” version of commands to create the new
-- relations (see slide 9 of the provided slides for this quiz), so that you can compare the
-- result of the decomposition with the original relation. Specifically, you should not run
-- any ALTER TABLE commands.

-- (d) Select the correct normal form for the decomposed schema.

-- Note: You can find a video from a past edition of the course explaining the process on
-- LearnIT.
-- ---------------------------------------------------------------------------
-- def PrintSQL(Att1, Att2)
-- print ("Here make the SQL query to check %s --> %s" % (Att1, Att2));
-- print ("Use the query in slide 44 of the homework slides on LearnIT");
-- R = [’A’, ’B’, ’C’]
-- for i in range(len(R)):
-- for j in range(len(R)):
-- if (i != j):
-- PrintSQL(R[i], R[j])
-- ---------------------------------------------------------------------------
-- Figur 1: Python skeleton for code to check all FDs for a relation R(A, B, C) with three
-- attributes in step (a).

-- 2.2 Simplifying Assumptions = Reality
-- In this project, assume that the following simplifying assumptions hold for each of the
-- relations (this is the “reality” against which you check them):

-- • The relations must each be considered in isolation. The columns have short names
-- that hint at their meaning, but you should not count on implicit FDs derived from
-- the expected meaning of the columns. In short, the column names may be misleading.

-- • Assume that all functional dependencies in each relation (aside from primary key
-- dependencies and dependencies derived from that) can be found by checking only
-- FDs with one column on each side, such as A → B.
-- Note: You can detect potential FDs using SQL queruies. Using the assumptions above,
-- it is indeed relatively simple to create a program to output queries for all possible
-- checks for FDs, which you can then run with psql, thus automating the detection
-- process.

-- • If you find a functional dependency that holds for the given instance, you can assume
-- that it will hold for all instances of the relation.
-- Exception: When an ID column and a corresponding string column both determine
-- each other, consider that only the ID column determines the string column, not vice
-- versa. For example, if both CID → CN and CN → CID are found to potentially
-- hold, then consider that only CID → CN is valid.

-- • The only dependencies you need to consider for decomposition are a) the dependencies
-- that can be extracted from the data based on the assumptions above, and b) the given
-- key constraints. As covered in the lecture, you can ignore trivial, unavoidable, and
-- redundant functional dependencies.








-- 3 Index Selection [20 points]
-- Consider the following relation with information on university courses:
-- Course (course_id, course_name, teacher_id, semester, ECTS, ...)
-- You are given a set of unclustered B+-tree indexes for the Course relation. For each
-- query, identify the index (or indexes) that a good query optimizer is most likely to use. If a
-- full table scan would yield better performance than any available index, select “no index”.

-- 3.1 Available Indexes
-- The available indexes are:
-- (a) Course(course_id)
-- (b) Course(course_name)
-- (c) Course(teacher_id)
-- (d) Course(semester)
-- (e) Course(ECTS)
-- (f) Course(teacher_id, semester)
-- (g) Course(semester, ECTS)
-- (h) No index

-- 3.2 Queries
-- The queries are:
-- Query 1: select course_id
-- from Course
-- where teacher_id = 101;
-- Query 2: select course_id, ECTS
-- from Course
-- where semester = ’Fall 2024’;
-- Query 3: select course_id, course_name
-- from Course
-- where ECTS > 7;
-- Query 4: select course_id
-- from Course
-- where teacher_id = 101 and semester = (select max(semester) from Course);
-- Query 5: select course_id, course_name
-- from Course;







-- 4 ER Diagram [5 points]
-- See multiple choice questions on the LearnIT quiz.