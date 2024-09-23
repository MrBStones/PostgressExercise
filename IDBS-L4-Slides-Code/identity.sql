DROP TABLE IF EXISTS A;
DROP TABLE IF EXISTS B;

CREATE TABLE A (
    id INT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    a INT
);
-- id does not have to be INT using IDENTITY, could also be either SMALLINT or BIGINT

CREATE TABLE B (
    id SERIAL PRIMARY KEY,
    b INT
);


INSERT INTO A (id, a) VALUES (1,1);

INSERT INTO A (a) VALUES (1);

INSERT INTO B (id, b) VALUES (1,1);

INSERT INTO B (b) VALUES (1); 
-- Sequence is still at 0 so id will be 1

-- Can still insert with id but you are in control
INSERT INTO A (id, a) OVERRIDING SYSTEM VALUE VALUES (2,1);

-- Regardless of the error the sequence increases,
-- so running again will succeed, but this is dangerous.

-- Update the sequence to avoid issues
SELECT setval(
pg_get_serial_sequence('A', 'id'),
(SELECT MAX(id) FROM A));
