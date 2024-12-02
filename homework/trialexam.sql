SELECT count(P.pid) as a
from person p
where p.name like 'Eva%';

SELECT count(*) as b
from person p
where p.name like 'Eva%';

SELECT count(*) as c
from person p
where p.name like 'Eva_';

SELECT count(*) as d
from person p
where p.name = 'Eva';