--
-- Current Database: W01
--

select *
from Sells
where coffeehouse like 'John%';

select *
from Sells
where coffee like 'Squapfe';

select count(*)
from Coffees;

select coffeehouse, avg(price)
from Sells
group by coffeehouse;