-- Lecture 4: SQL Programming and Python

-- Slide 4: Wake Up Tasks (Bills DB)
-- How many accounts have never been used before?
SELECT *
  FROM Accounts a 
  LEFT JOIN AccountRecords ar ON ar.aid = a.aid
 WHERE ar.rid IS NULL;

-- How many accounts have a negative account balance
-- and also have bills due?
SELECT COUNT(*)
  FROM (
    SELECT *
      FROM Accounts a
      JOIN Bills b ON a.pid = b.pid
     WHERE a.aBalance < 0
       AND b.bIsPaid IS FALSE
  ) AS T;


--Slide 9: SQL - Create a new Person
INSERT INTO People (name, gender, height)
VALUES ('Terry', 'M', 1.77);

SELECT * FROM People WHERE name = 'Terry';
DELETE FROM People WHERE name = 'Terry';

-- Slide 10: Function - Create a new Person
DROP FUNCTION IF EXISTS NewPerson;

-- Create the funciton NewPerson
CREATE FUNCTION NewPerson (
	IN pname VARCHAR(50),
	IN pgender CHAR(1),
	IN pheight FLOAT
)
RETURNS INTEGER
AS $$
BEGIN
  INSERT INTO 
  People (name, gender, height)
  VALUES (pname, pgender, pheight);
  RETURN lastval();
END;
$$ LANGUAGE plpgsql;


-- Slide 11:
SELECT nextval();
-- Ways to call the function NewPerson
SELECT lastval(); -- This is a Postgres function that returns the last assigned ID to a table through INSERT.
SELECT NewPerson ('Terry', 'M', 1.77);

SELECT * FROM NewPerson ('Terry', 'M', 1.77);

DO $$
    BEGIN
        PERFORM NewPerson ('Terry', 'M', 1.77);
    END
$$;

SELECT * FROM People WHERE name = 'Terry';
DELETE FROM People WHERE name = 'Terry';


-- Slide 13
-- Function: BiggestRecordJump
-- Input: ID of sport
-- Output: The largest increase of that sport
DROP FUNCTION IF EXISTS BiggestRecordJump;

CREATE FUNCTION BiggestRecordJump (
  IN sid INT
)
RETURNS FLOAT
AS $$
DECLARE r FLOAT;
BEGIN
  SELECT MAX (newrecord - oldrecord) INTO r
    FROM RecordLog
   WHERE sportID = sid;
  RETURN r;
END;
$$ LANGUAGE plpgsql;

SELECT BiggestRecordJump(1);


-- Slide 16:
-- Importance of IDENTITY column
-- If we use the schema script from last week or this weeks 04-sports-schema.sql
-- adding a new person in the way we did will not work as we do not assign an ID.
-- 04-sports-schema-fixed.sql Fixes the ID column of the tables to auto increment on INSERT
-- If you do forget to make a column an IDENTITY column you can alter the table.
ALTER TABLE People
  ALTER id SET NOT NULL,
  ALTER id ADD GENERATED ALWAYS AS IDENTITY;
SELECT setval(pg_get_serial_sequence('People', 'id'), 
              (SELECT MAX(id) FROM People));


-- If a column has a sequence you can retrieve it as follows:
-- Get the name of the sequence
SELECT pg_get_serial_sequence('People', 'id');
-- Check the sequence next value
SELECT nextval('public.people_id_seq');
-- Does it match with the current maximum id?
SELECT MAX(id) FROM People;
-- Fix the out of sync ID sequence of People
SELECT setval(
pg_get_serial_sequence('People', 'id'),
(SELECT MAX(id) FROM People));



-- Slide 21
-- Trigger to check result prior to INSERT or UPDATE
DROP TRIGGER IF EXISTS CheckResult ON Results;
DROP FUNCTION IF EXISTS CheckResult;

CREATE FUNCTION CheckResult()
RETURNS TRIGGER
AS $$ BEGIN
  IF (NEW.result < 0.0) THEN
    RAISE EXCEPTION 
    'CheckResult: Result must be a positive'
    USING ERRCODE = '45000';
  END IF;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER CheckResult
BEFORE INSERT OR UPDATE
ON Results
FOR EACH ROW EXECUTE PROCEDURE CheckResult();

-- Test trigger
INSERT INTO Results VALUES (1, 1, 1, -1.0);

-- Slide 22
-- Trigger to not allow any changes to rows
DROP TRIGGER IF EXISTS BanChanges ON Results;
DROP FUNCTION IF EXISTS BanChanges;

CREATE FUNCTION BanChanges()
RETURNS TRIGGER
AS $$ 
BEGIN
  RAISE EXCEPTION 
    'BanChanges: Cannot change results!'
    USING ERRCODE = '45000';
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER BanChanges
BEFORE UPDATE OR DELETE
ON Results
FOR EACH ROW EXECUTE PROCEDURE BanChanges();

-- Test trigger
DELETE FROM Results WHERE sportID = 3;


-- Slide 23
-- Trigger to update record in sport after a new result 
DROP TRIGGER IF EXISTS UpdateRecord ON Results;
DROP FUNCTION IF EXISTS UpdateRecord;

CREATE FUNCTION UpdateRecord()
RETURNS TRIGGER
AS $$ BEGIN
  IF NEW.result > (
    SELECT s.record
      FROM Sports s
     WHERE s.id = NEW.sportID
  ) THEN 
    UPDATE Sports s
       SET record = NEW.result
     WHERE s.id = NEW.sportID;
  END IF;
  RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER UpdateRecord
AFTER INSERT OR UPDATE
ON Results
FOR EACH ROW EXECUTE PROCEDURE UpdateRecord();

-- Test trigger
SELECT * FROM Sports WHERE ID = 1;
INSERT INTO Results VALUES (1, 1, 1, 100000.0);
SELECT * FROM Sports WHERE ID = 1;
-- Reset DB
UPDATE Sports SET record = 6.78 WHERE id = 1;
DELETE FROM Results WHERE result = 100000.0;


-- Slide 24
-- RecordLog Table
DROP TABLE IF EXISTS RecordLog;
CREATE TABLE RecordLog (
  peopleID INT,
  competitionID INT,
  sportID INT,
  oldrecord FLOAT,
  newrecord FLOAT,
  seton DATE,
  PRIMARY KEY (peopleID, competitionID, sportID),
  FOREIGN KEY (peopleID, competitionID, sportID)
  REFERENCES Results (peopleID, competitionID, sportID)
);
-- Trigger to update the RecordLog table
DROP TRIGGER IF EXISTS LogRecord ON Results;
DROP FUNCTION IF EXISTS LogRecord();

CREATE FUNCTION LogRecord()
RETURNS TRIGGER
AS $$ 
DECLARE oldRecord FLOAT;
BEGIN
  IF NEW.result > (
    SELECT s.record
      FROM Sports s
     WHERE s.id = NEW.sportID
  ) THEN
    SELECT s.record INTO oldRecord
      FROM Sports s
     WHERE s.id = NEW.sportID;
    INSERT INTO RecordLog
    VALUES (NEW.peopleID, 
            NEW.competitionID, NEW.sportID, oldRecord, NEW.result);
  END IF;
  RETURN NEW; 
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER LogRecord
AFTER INSERT ON Results
FOR EACH ROW EXECUTE PROCEDURE LogRecord();

-- Test trigger
INSERT INTO Results VALUES (1, 1, 3, 100000.0);
SELECT * FROM Results;
SELECT * FROM RecordLog;
SELECT * FROM Sports;


-- Slide 26
-- Trigger that combines functionality
DROP TRIGGER IF EXISTS MergedTrigger ON Results;
DROP FUNCTION IF EXISTS MergedTrigger;

CREATE FUNCTION MergedTrigger()
RETURNS TRIGGER
AS $$ BEGIN
  IF (TG_OP = 'DELETE' OR TG_OP = 'UPDATE') 
  THEN
    RAISE EXCEPTION 
    'MergedTrigger: Cannot change results!'
    USING ERRCODE = '45000';
  END IF;
  IF (NEW.result < 0.0) THEN
    RAISE EXCEPTION 
    'CheckResult: Result must be a positive!'
    USING ERRCODE = '45000';
  END IF;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER MergedTrigger
BEFORE INSERT OR UPDATE OR DELETE
ON Results
FOR EACH ROW EXECUTE PROCEDURE MergedTrigger();

INSERT INTO Results VALUES (1,1,3,-1.0);
DELETE FROM Results WHERE sportID = 3;


-- Slide 31
-- Database information
SELECT *
  FROM information_schema.tables
 WHERE table_schema = 'public';

SELECT current_database();
SELECT current_user;
SELECT lastval();


-- Change People to Athletes
ALTER TABLE People RENAME TO Athletes;
-- We also need to change the name of the sequence
DO
$$
DECLARE 
    seq VARCHAR(255);
BEGIN
    -- Get the name of the sequence
    SELECT pg_get_serial_sequence('Athletes', 'id') INTO seq;
    
    -- Have to run a dynamic SQL statement with string concatenation
    EXECUTE 'ALTER SEQUENCE ' || seq || ' RENAME TO athletes_id_seq';
END
$$;
