select MAX(a) FROM (
    SELECT count(b.pid) as a
    from buys b
    join person p on b.pid = p.pid
    where p.birthyear < b.year
    GROUP by b.pid
);