-- 1) In this part, consider ONLY the ER diagram above. Choose the correct statements.
-- (a) All foxes have a weight. [✅]
-- (b) A hunter can kill a fox without the assistance of a dog [❌]
-- (c) A dog can kill a bird [❌]
-- (d) Hunters are animals [❌]
-- (e) All animals are dead [❌]
-- (f) A hunter can kill a fox with the assistance of at least one dog [✅]
-- (g) All foxes are dead [❌]
-- (h) A bird can be killed by many hunters [❌]
-- (i) All birds are dead [❌]
-- (j) Given a hunter, it is possible to find the total weight of the animals he/she has killed [✅]
-- (k) A bird can be a dog [✅]


-- 3) Answer each of the following questions using a single SQL query on the homework
-- database. Enter the numerical answer of each query into the LearnIT quiz. Finally, upload
-- a script with your queries. Queries should still adhere to the detailed guidelines given in
-- Homework 1.

-- a) The empire ‘Great Britain’ consists of 4 countries. How many countries does the
-- empire ‘Iberian’ consist of?
select count(*) as "question a"
from (
    select c.code
    from countries c
    join empires e
    on e.countrycode = c.code
    where e.empire = 'Iberian'
    group by c.code
); -- answer = 3

-- (b) There are 4 countries that are present on more than one continent. How many of
-- these countries are partially in Asia?
select count(*) as "question b"
from (
    select cc.continent, cc.countrycode
    from countries_continents cc
    join (
        select c.code
        from countries c
        join countries_continents cc
        on cc.countrycode = c.code
        group by c.code
        having count(cc.continent) > 1
    ) cf
    on cc.countrycode = cf.code
    where cc.continent = 'Asia'
); -- answer = 4

-- (c) In the countries of North America that have more than 80 million inhabitants, there
-- are a total of 111,946,176 people who speak Spanish, according to the statistics in
-- the database. How many people who speak Spanish exist in the countries of Europe
-- that have more than 50 million inhabitants?
select sum((cl.Percentage * 0.01) * c.population) as "question c"
from countries_languages cl
join countries_continents cc
on cc.countrycode = cl.countrycode
join countries c
on cc.countrycode = c.code
where cc.continent = 'Europe' and cl.language = 'Spanish' and c.population > 50000000
; -- answer = 236902 or 236902.8

-- (d) According to the database, two languages are spoken in all countries of ‘Benelux’.
-- How many languages are spoken in all countries of ‘Danish Empire’ ?
-- Note: This is a division query; points will only be awarded if division is attempted.
select count(*) as "question d"
from (
    select l.language
    from empires e
    join countries_languages l
    on e.countrycode = l.countrycode
    where empire = 'Danish Empire'
    group by l.language
    having count(l.language) = (
        select count(countrycode)
        from empires
        where empire = 'Danish Empire'
    )
); -- answer = 1


-- 4) Choose the correct statements
-- (a) A row-level AFTER trigger on INSERT can modify the newly inserted row. [❌]
-- (b) In PostgreSQL, a trigger needs to be associated with a function.[✅]
-- (c) A function can only be executed using a SELECT statement.[❌]
-- (d) If a function fails, its changes will be reverted. [✅]


-- 5) Assume conn is a connection object from psycopg. Choose the correct statements
-- (a) A cursor can only execute one query. [❌]
-- (b) If you perform conn.execute(query ).fetchmany(4) twice you get the first 8 rows of the query. [❌]
-- (b) If you perform conn.execute(query ).fetchmany(4) twice you get the first 8 rows [❌]
-- (c) Prepared Statements can only be used for an SQL query’s variables. [✅]
-- (d) If autocommit=False, then changes from cursors will only take effect if conn.commit() is called. [✅]
