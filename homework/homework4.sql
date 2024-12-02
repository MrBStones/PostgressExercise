-- 1 Hardware and Transactions [10 points]
-- Question 1.A Select the correct statements below:
-- [❌](a) NO STEAL is an optimal Buffer Management policy.
-- [❌](b) In a main memory system, it is not necessary to include the “old” values when logging changes made by transactions to secondary storage.
-- [✅](c) With 2-Phase Locking, no locks can be acquired once the shrinking phase has begun.
-- [❌](d) In a distributed system, it is possible to avoid network partitions and achieve consistency and availability.
-- Question 1.B Reflect upon why ACID transactions are rarely used in distributed systems.
-- While ACID principles may be useful in ensuring data integrity and consistency in a single database, they are not as effective in distributed systems. This is because distributed systems are more prone to network partitions, which can lead to inconsistencies in the data. In a distributed system, it is difficult to guarantee that all nodes have the same view of the data at all times, which can make it challenging to maintain the isolation and consistency properties of ACID transactions. Additionally, the performance overhead of enforcing ACID properties in a distributed system can be significant, as it requires coordination and communication between multiple nodes, which can impact the scalability and availability of the system.

-- 2 Data Systems for Analytics [10 points]
-- Question 2.A Select the correct statements below:
-- [✅](a) Graph databases always perform better than relational databases for graph-specific workloads.
-- [✅](b) MapReduce systems such as Apache Hadoop scale well horizontally by distributing data across multiple servers and performing computations in parallel on these servers.
-- [✅](c) The concept of “veracity” in big data refers to the accuracy and reliability of the data being analyzed.
-- [✅](d) It is easy to manage semi-structured data in relational database management systems.
-- [❌](e) Relational database systems and SQL are well-suited for machine learning applications that involve many loops.
-- [❌](f) Big data analytics applications can only be implemented on systems that support ACID transactions.
-- Question 2.B Consider a scenario where you have 100 PB of raw data files generated from a scientific experiment. Your goal is to make scientific discoveries by performing complex computations on this data and to plan future experiments accordingly. Provide compelling arguments for why you would choose to store this data in a data lake and use a data lakehouse for processing. Compare this to a scenario in which the data is stored on a file system in the research group’s local data center and additionally loaded into a document database installed on the cloud for more effective data analysis.
-- A data lake is a centralized repository that allows you to store all your structured and unstructured data at any scale. It provides a cost-effective solution for storing large volumes of data and enables you to perform complex computations and analytics on the data. In the scenario described, storing the 100 PB of raw data files in a data lake would make sense since the data is generated from a scientific experiment and is likely to be diverse and unstructured. Datalakes also have great ML support. If they were to hovever store the files in a document database they would have to assign keys and values to their data. A local filesystem would also be inefficient as it would be hard to sort the data in any meaningful way. 100 pb is a lot of data sheesh.

-- 3 Normalisation [20 points]
-- Consider the SQL script and the associated description in Part 2 of Homework 3. In Homework 3, you normalised the Rentals relation. Now, your task is to normalise the Projects relation. For that purpose, follow the steps outlined below:
-- 1. Find all the FDs in the relations, given the constraints and assumptions from Homework 3.
-- (in brackets means PRIMARY KEY)
-- [ID PID SID] SN PN MID MN

-- ID --> MID
-- ID --> MN
-- PID --> PN
-- SID --> SN
-- SN --> SID
-- MID --> MN
-- MN --> MID

-- 2. Decompose the relation until each subrelation is in BCNF/3NF, while preserving all non-redundant FDs. Write down the resulting schema description in a simple Relation(columns) format.
-- [ID PID SID]
-- [ID] MID
-- [PID] PN
-- [SID] SN
-- [MID] MN

-- 3. Write the detailed SQL commands to create the resulting tables (with primary keys and foreign keys) and populate them, by extracting the relevant data from the original relations.
DROP TABLE IF EXISTS NewProjects CASCADE;
DROP TABLE IF EXISTS NewProjectsA CASCADE;
DROP TABLE IF EXISTS NewProjectsB CASCADE;
DROP TABLE IF EXISTS NewProjectsC CASCADE;
DROP TABLE IF EXISTS NewProjectsD CASCADE;

CREATE TABLE NewProjectsD (
    MID INT NOT NULL,
    MN VARCHAR(255) NOT NULL,
    PRIMARY KEY (MID)
);

CREATE TABLE NewProjectsA (
    ID INT NOT NULL,
    MID INT NOT NULL,
    PRIMARY KEY (ID),
    FOREIGN KEY (MID) REFERENCES NewProjectsD(MID)
);

CREATE TABLE NewProjectsB (
    PID INT NOT NULL,
    PN VARCHAR(255) NOT NULL,
    PRIMARY KEY (PID)
);

CREATE TABLE NewProjectsC (
    SID INT NOT NULL,
    SN VARCHAR(255) NOT NULL,
    PRIMARY KEY (SID)
);

CREATE TABLE NewProjects (
    ID INT NOT NULL,
    PID INT NOT NULL,
    SID INT NOT NULL,
    PRIMARY KEY (ID, PID, SID),
    FOREIGN KEY (ID) REFERENCES NewProjectsA(ID),
    FOREIGN KEY (PID) REFERENCES NewProjectsB(PID),
    FOREIGN KEY (SID) REFERENCES NewProjectsC(SID)
);

INSERT INTO NewProjectsD SELECT DISTINCT MID, MN FROM Projects;
INSERT INTO NewProjectsA SELECT DISTINCT ID, MID FROM Projects;
INSERT INTO NewProjectsB SELECT DISTINCT PID, PN FROM Projects;
INSERT INTO NewProjectsC SELECT DISTINCT SID, SN FROM Projects;
INSERT INTO NewProjects SELECT ID, PID, SID FROM Projects;

-- 4. Select the correct normal form for the decomposed schema.
-- THIS IS 3NF

-- Please note that the details of these steps, as well as constraints of the relation, can be found in the description of Homework 3. Please refer to the description there for further guidance

-- 5 SQL [20 points]
-- In this part you will work with a music database. To start working with the database, import/run HW4.sql found in LearnIT using the PostgreSQL DBMS on your laptop. The database has the following relations:
-- Artists(ArtistId, Artist, ArtistImageUrl)
-- Songs(SongId, Title, ArtistId, Duration, IsExplicit, ImageUrl, ReleaseDate)
-- Genres(GenreId, Genre)
-- Albums(AlbumId, Album, AlbumImageUrl, AlbumReleaseDate)
-- AlbumArtists(AlbumId, ArtistId)
-- AlbumGenres(AlbumId, GenreId)
-- AlbumSongs(AlbumId, SongId)
-- SongGenres(SongId, GenreId)
-- Primary and foreign key attributes have names that end with Id. The meaning of other attributes should be self-explanatory. The first four relations have their first attribute as primary key. In the last four relations there is a composite primary key consisting of both attributes, and each attribute separately is a foreign key reference to one of the first four relations. Secondary indexes exist on AlbumArtists(ArtistId), AlbumGenres(GenreId), AlbumSongs(SongId), SongGenres(GenreId), and Songs(ArtistId).
-- You will need to work with the ReleaseDate and Duration attributes, which have the type date and time, respectively. The expression interval ’1 minute’ can be used to generate a duration value to compare to, the expression extract(year from ReleaseDate) can be used to get a year from a date, and extract(epoch from Duration) can be used to get the total number of seconds in an interval.
-- Answer each of the following questions using a single SQL query on the examination database. Enter the result of each query into the quiz on LearnIT. As before, queries should adhere to the detailed guidelines given in Homework 1.

-- (a) In the database, 353 songs have a duration of at least 10 minutes. What is the average duration of songs, in minutes, that have a duration between 5 and 25 minutes, inclusive? Round the number of minutes (ROUND(...)).

-- (b) What is the total duration in minutes of all explicit songs in the database? Round the number of minutes (ROUND(...)).

-- (c) The database contains just 5 songs released in 1953. What is the average number of songs released in a year? Round the number of songs (ROUND(...)). Note: This is a very simple query. Try also to answer which year had the largest number of songs. Observe how much harder this query is!

-- (d) The database contains multiple albums by the artist Queen. Each album has a different average song duration, with the maximum average song duration of an album by Queen being 354 seconds. What is the maximum average song duration (in seconds) of an album by Miles Davis? Note: The output of the maximum average song duration is rounded ROUND(...)

-- (e) There are 938 song titles that have been used for at least 2 songs, making up a total of 2072 songs with those titles. How many songs have a title that has been used for at least 4 songs?

-- (f) How many songs have been released after 2010 or belong to an album released in January.

-- (g) There are 1147 Albums with more than 1 song and none of them are Explicit. How many Albums consists of more than 1 song with all songs being Explicit?

-- (h) The highest number of genres covered within an Album is 5. In the database, there is only one Album that has this amount of genres. What is the name of this Album? 

-- Note: Write your query to be capable of finding all albums that have the highest number of genres. (No hardcoded values)