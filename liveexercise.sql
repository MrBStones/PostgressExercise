--
-- Current Database: W01
--

DROP TABLE IF EXISTS Sells;
DROP TABLE IF EXISTS Coffees;
DROP TABLE IF EXISTS Coffeehouses;

CREATE TABLE Coffees (
    name varchar(20) NOT NULL,
    manufacturer varchar(20) NOT NULL,
    PRIMARY KEY (name)
);

insert into Coffees (name, manufacturer) values ('Fortnite', 'Ottolina');
insert into Coffees (name, manufacturer) values ('Maracaibo', 'Ottolina');

SELECT * FROM Coffees;
SELECT 42 AS query FROM Coffees;
SELECT 42 AS query;