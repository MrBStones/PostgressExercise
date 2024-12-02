select count(*) from (
    select g.did
    from game g
    group by g.did
    HAVING count(DISTINCT g.genre) = (SELECT DISTINCT count(genre) from game)
);
