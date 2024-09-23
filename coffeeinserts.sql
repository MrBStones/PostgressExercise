--
-- Current Database: W01
--

insert into Coffees (name, manufacturer) values ('Slop', 'Braga');
insert into Coffees (name, manufacturer) values ('Squapfe', 'Braga');
insert into Coffees (name, manufacturer) values ('Squapfe2', 'Braga');
insert into Coffees (name, manufacturer) values ('Black', 'Blackboy');

insert into Coffeehouses (name, address, license) values ('Joe starbuck', 'negra arroyo lane', 'good');
insert into Coffeehouses (name, address, license) values ('JohnsCof', 'negra arroyo lane', 'okay');

insert into Sells (coffeehouse, coffee, price) values ('Joe starbuck', 'Slop', 10);
insert into Sells (coffeehouse, coffee, price) values ('Joe starbuck', 'Squapfe', 420);
insert into Sells (coffeehouse, coffee, price) values ('JohnsCof', 'Squapfe', 1919);
insert into Sells (coffeehouse, coffee, price) values ('JohnsCof', 'Squapfe2', 419);
insert into Sells (coffeehouse, coffee, price) values ('JohnsCof', 'Black', 5);