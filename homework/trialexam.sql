select count(*) as a
from (
    select p.pid
    from person p
    where p.birthyear < 1980
    UNION
    SELECT pl.pid
    from plays pl
    join game g on pl.gid = g.gid
    where g.did = 5
) X;

select count(*) as b
from (
    select p.pid
    from person p
    where p.birthyear < 1980
    EXCEPT
    SELECT pl.pid
    from plays pl
    join game g on pl.gid = g.gid
    where g.did = 5
) X;

select count(*) as c
from person p
where p.birthyear < 1980
or p.pid in (
    SELECT pl.pid
    from plays pl
    join game g on pl.gid = g.gid
    where g.did = 5
);

select count(*) as d
from (
    select p.pid
    from person p
    where p.birthyear < 1980
    INTERSECT
    SELECT pl.pid
    from plays pl
    join game g on pl.gid = g.gid
    where g.did = 5
) X;