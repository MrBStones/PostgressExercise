-- a)

-- 4
select count(*)
from empires E
where E.Empire = 'Great Britain';

-- 3
select count(*)
from empires E
where E.Empire = 'Iberian';



-- b)

-- 4
select count(*)
from (
	select CC.CountryCode
	from countries_continents CC 
	group by CC.CountryCode
	having count(*) > 1
) X;

-- 4
select count(*)
from (
	select CC.CountryCode
	from countries_continents CC 
		join countries_continents C2 on CC.CountryCode = C2.CountryCode
	where C2.Continent = 'Asia'
	group by CC.CountryCode
	having count(*) > 1
) X;

-- 4
-- simplest one :)
select count(*)
from countries_continents
where percentage < 100 and continent = 'Asia';

-- 4
select count(*)
from (
	select countrycode
	from countries_continents
	where continent = 'Asia'
	intersect
	select countrycode
	from countries_continents
	where continent <> 'Asia'
) X;

-- c)

-- 111946176
select sum(SpanishSpeaking)
from (
	select CO.Code, CO.Population * CL.Percentage / 100.0 as SpanishSpeaking
	from countries CO
		join countries_continents CC on CO.Code = CC.CountryCode
		join countries_languages CL on CO.Code = CL.CountryCode
	where CO.Population > 80000000
		and CC.Continent = 'North America'
		and CL.Language = 'Spanish'
) X;

-- 236902.8
select sum(SpanishSpeaking)
from (
	select CO.Code, CO.Population * CL.Percentage / 100.0 as SpanishSpeaking
	from countries CO
		join countries_continents CC on CO.Code = CC.CountryCode
		join countries_languages CL on CO.Code = CL.CountryCode
	where CO.Population > 50000000
		and CC.Continent = 'Europe'
		and CL.Language = 'Spanish'
) X;

-- d)

-- 2
select count(*)
from (
	select CL.language
	from empires E
		join countries_languages CL on E.CountryCode = CL.CountryCode
	where E.Empire = 'Benelux'
	group by CL.language
	having count(E.CountryCode) = (
		select count(*)
		from empires E
		where E.Empire = 'Benelux'
	)
) X;

-- 1
select count(*)
from (
	select CL.language
	from empires E
		join countries_languages CL on E.CountryCode = CL.CountryCode
	where E.Empire = 'Danish Empire' 
	group by CL.language
	having count(E.CountryCode) = (
		select count(*)
		from empires E
		where E.Empire = 'Danish Empire'
	)
) X;

-- 1
select count(*)
from (
select distinct(L.language)
from countries_languages L
where not exists (
	select * 
	from empires E2
	where E2.empire = 'Danish Empire' 
	  and not exists (
	  	select *
		from countries_languages CL
		where E2.countrycode = CL.countrycode
		  and CL.language = L.language
	)
)
) X;