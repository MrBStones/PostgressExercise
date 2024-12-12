-- The database has the following schema:

-- Country(CID, name, population)
-- Developer(DID, name, since, CID)
-- Game(GID, name, genre, DID)
-- Person (PID, name, birthyear)
-- Buys (GID, PID, year)
-- Plays (GID, PID)

-- Following are some additional notes that are important for your queries:

-- The attribute since in the table Developer is the year the developer company was founded.
-- The column name is a candidate key (UNIQUE) in the tables Country, Developer, and Game, but not in the table Person.
-- The database is randomly created and may contain strange data and errors. In particular, Buys.year and Person.birthyear are very inconsistent.

-- There are 37 people who have bought some game from all developer companies that were founded in 1969. 
-- How many people have bought some game from all developer companies that were founded in 1960?


-- a)
SELECT COUNT(*) as a
FROM Buys b
join game g on b.gid = g.gid
where g.genre = 'Role-playing'
or b.year = 2001;

-- b)
select count (p.pid) as b
from Country c
join Developer d on c.cid = d.CID
join game g on d.did = g.did
join buys b on g.gid = b.gid
join person p on b.pid = p.pid
where b.year < d.since
and b.year > p.birthyear
and c.name = 'Denmark';

-- c)
select count (*) as c 
from game g
where g.name like '%Zelda%';

-- d)
select count (p.pid) as d
from person p
where p.birthyear > 1990
or p.pid in (
    select b.pid
    from buys b
    join plays pl on b.pid = pl.pid and b.gid = pl.gid
    where b.year = 2020
);

-- e)
SELECT COUNT(DISTINCT b.PID) AS e
FROM Buys b
LEFT JOIN Plays p ON b.GID = p.GID AND b.PID = p.PID
WHERE p.GID IS NULL;

-- f)
select count(*) as f from (
    select p.pid, count(p.gid) as plays_count
    from plays p
    group by p.pid
) X
join (
    select b.pid, count(b.gid) as buys_count
    from buys b
    group by b.pid
) Y
on X.PID = Y.PID
where x.plays_count > y.buys_count
;

-- g)
select count(DISTINCT b.pid) as g
from buys b
join game g on b.gid = g.gid
join developer d on g.did = d.did
join country c on d.cid = c.cid
where c.population > 30000000
;

-- h)
select count(*) as h from (
    select b.pid
    from buys b
    join game g on b.gid = g.gid
    join developer d on g.did = d.did
    where d.since = '1960'
    group by b.pid
    having count(DISTINCT d.did) = (select count(did) from developer where since = '1960')
);



-- CREATE OR REPLACE FUNCTION NoNegativePopulation() 
-- RETURNS TRIGGER
-- AS $Body$
-- BEGIN
--     IF TG_OP = 'INSERT'
--     THEN
--         RAISE EXCEPTION 'Operation not allowed!'
--         USING ERRCODE = '45000';
--     END IF;

--     IF NEW.population < 0
--     THEN
--         NEW.population = NULL;
--     END IF;

--     RETURN NEW;
-- END;
-- $Body$ LANGUAGE plpgsql;

-- CREATE OR REPLACE TRIGGER NoNegativePopulation
-- AFTER INSERT OR UPDATE ON Country
-- FOR EACH ROW EXECUTE PROCEDURE NoNegativePopulation();

-- BEGIN;
-- INSERT INTO Country (CID, name, population) VALUES (44, 'Morocco', 34924821);
-- ROLLBACK;
-- BEGIN;
-- UPDATE Country SET population = -2024 WHERE name = 'Denmark';
-- SELECT * from Country where name = 'Denmark';
-- ROLLBACK;


-- DROP TRIGGER IF EXISTS NoNegativePopulation ON Country;
-- DROP FUNCTION IF EXISTS NoNegativePopulation();



