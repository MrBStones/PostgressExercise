select count(*) from (
    select b.pid 
    from buys b
    join game g on b.gid = g.gid
    join developer d on g.did = d.did
    join Country c on d.cid = c.cid
    where c.population < 400000
    GROUP by b.pid
    having count(DISTINCT c.cid) = (
        select count(c.cid)
        from Country c
        where c.population < 400000)
);


drop TABLE if EXISTS competes;

CREATE TABLE competes (
    e1id int,
    e2id int,
    attempt_date date,
    score float not null,
    PRIMARY KEY (e1id, e2id, attempt_date)
);