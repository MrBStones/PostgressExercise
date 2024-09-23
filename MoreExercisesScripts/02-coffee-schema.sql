-- (c) Eleni Tzirita Zacharatou, 2023-2024
-- based on material from Bjorn Thor Jonsson, 2016-2022
-- Introduction to Database Systems @ ITU
-- Lecture 2: Examples from slides

-- NULL/NOT NULL intentionally ignored
-- Datatypes and sizes are not fixed, the assignment gave no details

-- Drop
DROP TABLE IF EXISTS Sells;
DROP TABLE IF EXISTS Likes;
DROP TABLE IF EXISTS Frequents;
DROP TABLE IF EXISTS Coffees;
DROP TABLE IF EXISTS Coffeehouses;
DROP TABLE IF EXISTS Drinkers;

-- Create
CREATE TABLE Coffees
(
	name VARCHAR PRIMARY KEY
	,manufacturer VARCHAR(20)
);
CREATE TABLE Coffeehouses
(
	name VARCHAR PRIMARY KEY
	,address VARCHAR
	,license VARCHAR
);
CREATE TABLE Drinkers
(
	name VARCHAR PRIMARY KEY
	,address VARCHAR
	,phone INTEGER
);
CREATE TABLE Likes
(
	drinker VARCHAR
	,coffee VARCHAR
   	,rating INTEGER
	,PRIMARY KEY(drinker, coffee)
	,FOREIGN KEY(drinker) REFERENCES Drinkers(name)
	,FOREIGN KEY(coffee) REFERENCES Coffees(name)
);
CREATE TABLE Frequents
(
	drinker VARCHAR 
	,coffeehouse VARCHAR
	,PRIMARY KEY(drinker, coffeehouse)
	,FOREIGN KEY(drinker) REFERENCES Drinkers(name)
	,FOREIGN KEY(coffeehouse) REFERENCES Coffeehouses(name)
);
CREATE TABLE Sells
(
	coffeehouse VARCHAR 
	,coffee VARCHAR
	,price REAL
	,PRIMARY KEY(coffeehouse, coffee)
	,FOREIGN KEY(coffeehouse) REFERENCES Coffeehouses(name)
	,FOREIGN KEY(coffee) REFERENCES Coffees(name)
);

-- Insert data
-- #1: entity tables
INSERT INTO Coffees( name, manufacturer) VALUES( 'Blue Mountain','Marley Coffee' );
INSERT INTO Coffees( name, manufacturer) VALUES( 'Kopi luwak','Kopi Luwak Direct' );

INSERT INTO Coffeehouses( name, address, license) VALUES( 'Analog', 'Rued Langgaardvej 7', 'Definitely' );
INSERT INTO Coffeehouses( name, address, license) VALUES( 'Mocha', 'Amager', 'Handwritten' );

INSERT INTO Drinkers( name, address, phone ) VALUES( 'Eleni','ITU', 12345678 );
INSERT INTO Drinkers( name, address, phone ) VALUES( 'Johan Sivertsen','ITU', 87654321 );

-- #2: relationship tables
INSERT INTO Likes( drinker, coffee, rating ) VALUES( 'Eleni', 'Blue Mountain', 10);
INSERT INTO Likes( drinker, coffee, rating ) VALUES( 'Johan Sivertsen', 'Blue Mountain',7);
INSERT INTO Likes( drinker, coffee, rating ) VALUES( 'Johan Sivertsen', 'Kopi luwak', 1);

INSERT INTO Frequents( drinker, coffeehouse ) VALUES( 'Eleni', 'Analog' );
INSERT INTO Frequents( drinker, coffeehouse ) VALUES( 'Johan Sivertsen', 'Analog' );

INSERT INTO Sells( coffeehouse, coffee, price ) VALUES( 'Analog', 'Blue Mountain', 17 );
INSERT INTO Sells( coffeehouse, coffee, price ) VALUES( 'Analog', 'Kopi luwak', 20 );
INSERT INTO Sells( coffeehouse, coffee, price ) VALUES( 'Mocha', 'Blue Mountain', 300 );


