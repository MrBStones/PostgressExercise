select count(DISTINCT g.did)
from game g
join buys b on g.gid = b.gid
join person p  on b.pid = p.pid
where p.birthyear = 1990
;