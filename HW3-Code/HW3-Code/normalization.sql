-- -------------------------------------------
-- Normalisation examples 
-- (c) 2023, Eleni Tzirita Zacharatou
-- -------------------------------------------

-- -------------------------------------------
-- Slide 6: Person relation

DROP TABLE IF EXISTS Person;
CREATE TABLE Person (
    ID INT PRIMARY KEY,
    Name CHARACTER VARYING NOT NULL,
    ZIP INT NOT NULL,
    City CHARACTER VARYING NOT NULL
);

INSERT INTO Person VALUES (1, 'Björn', 2100, 'København Ø');
INSERT INTO Person VALUES (2, 'Johan', 2300, 'København S');
INSERT INTO Person VALUES (3, 'Peter', 2100, 'København Ø');

SELECT *
FROM Person;

select distinct City from Person where ZIP = 2100;
select distinct City from Person where ZIP = 2300;
select ZIP from Person where City = 'København V';

-- Problem with insertion: Both København Ø and København V 
-- have the same ZIP code (2100). 
begin;
insert into Person values (4, 'New', 2100, 'København V');
select distinct City from Person where ZIP = 2100;
select ZIP from Person where City = 'København V';
abort;

-- Problem with update: Both København Ø and Ringsted
-- have the same ZIP code (2100). 
begin;
update Person set City = 'Ringsted' where ID = 1;
select distinct City from Person where ZIP = 2100;
abort;

-- Problem with deletion: We lose information about ZIP code 2300.
begin;
delete from Person where ID = 2;
select distinct City from Person where ZIP = 2300;
abort;

-- -------------------------------------------
-- Slide 8: Decompose the relation

DROP TABLE IF EXISTS ZIP;
CREATE TABLE ZIP (
    ZIP INT PRIMARY KEY,
    City CHARACTER VARYING NOT NULL
);

INSERT INTO ZIP
SELECT DISTINCT ZIP, City
FROM Person;

ALTER TABLE Person ADD FOREIGN KEY (ZIP) REFERENCES ZIP(ZIP);
ALTER TABLE Person DROP COLUMN City;

-- -------------------------------------------
-- Slide 7: Re-join the relation

SELECT *
FROM Person;

SELECT *
FROM ZIP;

SELECT P.ID, P.Name, P.ZIP, Z.City
FROM Person P JOIN ZIP Z ON P.ZIP = Z.ZIP;


--- -------------------------------------------
-- Slide 44: SQL method of detecting FDs

DROP TABLE IF EXISTS Person;
CREATE TABLE Person (
    ID INT PRIMARY KEY,
    Name CHARACTER VARYING NOT NULL,
    ZIP INT NOT NULL,
    City CHARACTER VARYING NOT NULL
);

INSERT INTO Person VALUES (1, 'Björn', 2100, 'København Ø');
INSERT INTO Person VALUES (2, 'Johan', 2300, 'København S');
INSERT INTO Person VALUES (3, 'Peter', 2100, 'København Ø');

SELECT 'Person: ZIP --> City' AS FD,
CASE WHEN COUNT(*)=0 THEN 'MAY HOLD'
ELSE 'does not hold' END AS VALIDITY
FROM (
	SELECT P.ZIP
	FROM Person P
	GROUP BY P.ZIP
	HAVING COUNT(DISTINCT P.City) > 1
) X;

SELECT 'Person: ZIP --> Name' AS FD,
CASE WHEN COUNT(*)=0 THEN 'MAY HOLD'
ELSE 'does not hold' END AS VALIDITY
FROM (
	SELECT P.ZIP
	FROM Person P
	GROUP BY P.ZIP
	HAVING COUNT(DISTINCT P.Name) > 1
) X;

SELECT 'Person: ID --> Name' AS FD,
CASE WHEN COUNT(*)=0 THEN 'MAY HOLD'
ELSE 'does not hold' END AS VALIDITY
FROM (
	SELECT P.ID
	FROM Person P
	GROUP BY P.ID
	HAVING COUNT(DISTINCT P.Name) > 1
) X;

SELECT 'Person: City --> ZIP' AS FD,
CASE WHEN COUNT(*)=0 THEN 'MAY HOLD'
ELSE 'does not hold' END AS VALIDITY
FROM (
	SELECT P.City
	FROM Person P
	GROUP BY P.City
	HAVING COUNT(DISTINCT P.ZIP) > 1
) X;

SELECT 'Person: Name, City --> ZIP' AS FD,
CASE WHEN COUNT(*)=0 THEN 'MAY HOLD'
ELSE 'does not hold' END AS VALIDITY
FROM (
	SELECT P.Name, P.City
	FROM Person P
	GROUP BY P.Name, P.City
	HAVING COUNT(DISTINCT P.ZIP) > 1
) X;

-- -------------------------------------------
