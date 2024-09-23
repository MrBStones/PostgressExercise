-- 
-- current database W02
-- 

-- The name and record of all sports sorted by name.
select name, record
from Sports
order by name;

-- The name of all sports with at least one result.
select name
from Sports
join Results
on Sports.ID = Results.sportID
group by name;

-- The number of athletes who have competed in at least one sport.
select count(distinct peopleID)
from Results;

-- The ID and name of athletes who have at least twenty results.
select p.ID, p.name
from People p
join Results r
on r.peopleID = p.ID
group by p.ID
having count(r.peopleID) >= 20;

-- The ID, name and gender description of all athletes that currently hold a record.
select p.ID, p.name, g.description
from People p
join Gender g on g.gender = p.gender
join Results r on p.ID = r.peopleID
join Sports s on s.ID = r.sportID
where s.record = r.result
group by p.ID, p.name, g.description;

--
-- For each sport, where some athlete holds the record, the name of the
-- sport and the number of athletes that hold a record in that sport; the last
-- column should be named “numathletes”.
--
select s.name, count(distinct r.peopleID) as numathletes
from Sports s
join Results r on s.ID = r.sportID
where s.record = r.result
group by s.name;

--
-- The ID and name of each athlete that has at least twenty results in the
-- triple jump, their best result, along with the difference between the
-- record and their best result. The second-to-last column should be named
-- “best” while the last column should be named “difference”. The last
-- column should always contain non-negative values and should preferably
-- be formatted to show at least one digit before the decimal point and
-- exactly two digits after the decimal point.
--


--
-- How many sports have the word jump in them?
--
select count(s.name) as jumpcount
from Sports s
where name like '%Jump%';

--
-- how many people have participated in more than 25 competetions
--
select count(distinct r.peopleID) as morethan25
from Results r
having count(r.sportID) > 25;


