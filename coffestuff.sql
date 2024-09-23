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

CREATE TABLE Coffeehouses (
    name varchar(20) NOT NULL,
    address varchar(50) NOT NULL,
    license varchar(50) NOT NULL,
    PRIMARY KEY (name)
);

CREATE TABLE Sells (
    coffeehouse varchar(20) NOT NULL,
    coffee varchar(20) NOT NULL,
    price REAL NOT NULL,
    PRIMARY KEY (coffeehouse, coffee),
    FOREIGN KEY(coffee) REFERENCES Coffees(name),
    FOREIGN KEY(coffeehouse) REFERENCES Coffeehouses(name)
);

