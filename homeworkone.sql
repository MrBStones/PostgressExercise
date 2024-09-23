-- (1) The person relation contains 284 entries with a registered death date after ‘2010-02- 01’. 
-- How many entries do not have a registered death date?
select count(*)
from person
where deathdate is NULL
;

-- (2) In the database, there are 46 movies in the French language for which the average height of 
-- all the people involved is greater than 185 centimeters (ignoring people with unregistered height). 
-- What is the number of movies in the Portuguese language for which the average height of all people 
-- involved is greater than 175 centimeters?
select count(*)
from (
	select m.id
	from movie m
	join involved i
	on i.movieId = m.id
	join person p
	on p.id = i.personId
	where m.language = 'Portuguese'
	group by m.id
	having avg(p.height) > 175
);


-- (3) The movie genre relation does not have a primary key, which can lead to a movie having more than 
-- one entry with the same genre. As a result, there are 14 movies in movie genre that have the genre 
-- ‘Action’ assigned to them more than once. How many movies in movie genre have the genre ‘Thriller’ 
-- assigned to them more than once?
select count(*)
from (
	select mg.movieId
	from movie_genre mg
	join genre g
	on g.genre = mg.genre
	where mg.genre = 'Thriller'
	group by movieId
	having count(mg.movieId) > 1
);

-- (4) According to the information in the database, 52 different people acted in movies directed by 
-- ‘Ingmar Bergman’. How many different people acted in movies directed by ‘Akira Kurosawa’?
select count(distinct i.personId)
from involved i
join (
	select i.movieId
	from involved i
	join person p
	on p.id = i.personId
	where p.name = 'Akira Kurosawa'
) mvid
on i.movieId = mvid.movieId
where i.role = 'actor'
;

-- (5) Of all the movies produced in 2007, there are 15 that have two directors involved in them. 
-- How many movies produced in 2010 have two directors involved in them?
select count(*)
from (
	select m.id
	from movie m
	join involved i
	on m.id = i.movieId
	where m.year = '2010'
	group by m.id, i.role
	having i.role = 'director' and count(i.role) = 2
);

-- (6) There are 406 unique pairs of actors who have appeared together in exactly 10 movies released 
-- between 2000 and 2010. How many unique pairs of actors have appeared together in exactly 20 movies 
-- released between 2000 and 2010?
select count(*) 
from (
	select distinct i1.personId, i2.personId
	from involved i1
	join involved i2
	on i1.movieId = i2.movieId and i1.personId < i2.personId
	join movie m 
	on i1.movieId = m.id
	where m.year between 2000 and 2010 and i1.role = 'actor' and i2.role = 'actor'
	group by i1.personId, i2.personId
	having count(*) = 20
);

-- (7) Of all the movies produced between 2000 and 2002, there are 782 that have entries registered in 
-- involved for all roles defined in the roles relation. How many movies produced between 2002 and 2004 
-- have entries registered in involved for all roles defined in the roles relation? Note: This is a 
-- relational division query that must work for any instance; Do not use any ‘magic numbers’.
select count(*)
from (
	select i.movieId
	from involved i
	join movie m
	on m.id = i.movieId
	where m.year between 2000 and 2004
	group by i.movieId
	having count(distinct i.role) = (select count(*) from role)
);

-- (8) The number of people who have played a role in movies of all genres in the category ‘Newsworthy’ is 156. 
-- How many people have played a role in movies of all genres in the category ‘Newsworthy’ but have not played 
-- any role in movies that cover all genres in the category ‘Popular’?
select count(*)
from (
	select i.personId
	from involved i
	join movie m
	on m.id = i.movieId
	join movie_genre mg
	on m.id = mg.movieId
	join genre g
	on mg.genre = g.genre
	where g.category = 'Newsworthy'
	group by i.personId
	having count(distinct g.genre) = (select count(genre) from genre where category = 'Newsworthy') 
	except
	select i.personId
	from involved i
	join movie m
	on m.id = i.movieId
	join movie_genre mg
	on m.id = mg.movieId
	join genre g
	on mg.genre = g.genre
	where g.category = 'Popular'
	group by i.personId
);


