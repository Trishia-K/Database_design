CREATE DATABASE BusesCompany;
USE BusesCompany;
CREATE TABLE Passenger(
    Passenger_ID INT PRIMARY KEY NOT NULL UNIQUE,
    First_Name VARCHAR(45) NOT NULL,
    Last_Name VARCHAR(45) NOT NULL,
    Gender VARCHAR(45) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Phone_Number INT NOT NULL,
    CHECK (LENGTH(Phone_Number)=10), 
    Email VARCHAR(45) NOT NULL,
    Ticket_ID VARCHAR(4),  
    Route_ID INT NOT NULL
); 
-- Alter the 'Phone_Number' column to ensure it is a VARCHAR with a length of 15 characters
ALTER TABLE Passenger
MODIFY Phone_Number VARCHAR(15) NOT NULL;
-- Add a check constraint to ensure the phone number has exactly 10 digits (no longer than 10 characters)
ALTER TABLE Passenger
ADD CONSTRAINT chk_phone_length CHECK (CHAR_LENGTH(Phone_Number) = 10);

INSERT INTO Passenger
VALUES  (1,'Aturinda','Beinembabazi','F','1999-03-02','0752344567','atubeine@gmail.com','T010',1101),
        (2,'Andrew','Mukidi','M','1964-05-17','0781231237','andrewkidi3@gmail.com','T011',1102),
        (3,'Trishia','Kobumanzi','F','1998-12-29','0768765432','kobu2rsha@gmail.com','T012',1102),
        (4,'Catherine','Ndagire','F','2003-11-20','0701234567','cathytronie@gmail.com','C012',1103),
        (5,'Angel','Magola','F','2003-09-04','0706545431','angeloola@gmail.com','T013',1103),
        (6,'Humble','Ssemambo','M','1937-05-16','0767874312','humblemambo2@gmail.com','T014',1103);


CREATE TABLE Ticket(
    Ticket_ID VARCHAR(4) PRIMARY KEY NOT NULL UNIQUE,
    CHECK(LENGTH(Ticket_ID)=4),
    Travel_Date DATE NOT NULL, 
    Departure_Time TIME NOT NULL,
    Arrival_Time TIME NOT NULL,
    Ticket_Payment INT NOT NULL,
    CHECK(Ticket_Payment>30000),
    Ticket_Type VARCHAR(45) NOT NULL,
    Payment_Date DATE NOT NULL,
    Route_ID INT NOT NULL UNIQUE
);
ALTER TABLE Ticket
DROP INDEX Route_ID;
INSERT INTO Ticket
VALUES('T010','2023-12-12','10:00','18:00','35000','Passenger','2023-12-10',1101),
      ('T011','2023-12-11','14:00','21:00','50000','Passenger','2023-12-09',1102),
      ('T012','2023-12-13','14:00','21:00','50000','Passenger','2023-12-11',1102),
      ('C012','2023-12-12','15:00','20:00','35000','Cargo','2023-12-08',1103),
      ('T013','2023-12-13','15:00','20:00','35000','Passenger','2023-12-10',1103),
      ('T014','2023-12-11','15:00','20:00','35000','Passenger','2023-12-09',1103);
CREATE TABLE Staff(
    Staff_ID INT PRIMARY KEY NOT NULL UNIQUE,
    F_Name VARCHAR(45) NOT NULL,
    L_Name VARCHAR(45) NOT NULL,
    Contact INT NOT NULL,
    Staff_Role VARCHAR(45) NOT NULL,
    Route_ID INT NOT NULL UNIQUE
);
ALTER TABLE Staff
DROP INDEX Route_ID;
INSERT INTO Staff
VALUES(11,'Tumwesigye','Johnson',0703462641,'Driver',1101),
      (12,'Lukaya','Mustafa',0772504183,'Conductor',1101),
      (13,'karugaba','Peter',0752345672,'Driver',1102);
CREATE TABLE Routes(
    Route_ID INT PRIMARY KEY NOT NULL,
    Route_Name VARCHAR(45) NOT NULL,
    CHECK (Route_Name IN('Kampala','Masindi','Kasese','Hoima','Fortportal','Bundibugyo','Bwera','Kasio','Kagadi')),
    Departure_Station VARCHAR(45) NOT NULL,
    Arrival_Station VARCHAR(45) NOT NULL,
    Cargo_ID INT NOT NULL UNIQUE,
    Staff_ID INT NOT NULL UNIQUE, 
    Passenger_ID INT NOT NULL UNIQUE
);
--Inserting data into routes table
INSERT INTO Routes
VALUES(1101,'Kampala','Station A','Station B',101,13,1),
      (1102,'Masindi','Station A','Station C',102,12,2),
      (1103,'Kasese','Station A','Station D',104,11,3);

--Creating Cargo table
CREATE TABLE Cargo(
    Cargo_ID INT PRIMARY KEY NOT NULL UNIQUE,
    Cargo_Weight DECIMAL(10,2) NOT NULL,
    CHECK (Cargo_Weight<=20),
    Cargo_Type VARCHAR(45) NOT NULL,
    Cargo_Payment VARCHAR(45) NOT NULL,
    Passenger_ID INT NOT NULL UNIQUE,
    Route_ID INT NOT NULL 
);
ALTER TABLE Cargo
DROP INDEX Passenger_ID;
-- Inserting data into the 'Cargo' table
INSERT INTO Cargo
VALUES(101,12.5,'fragile','shs.10000',1,1101),
      (102,11,'perishable','shs.10000',2,1102),
      (103,13,'fragile','shs.10000',3,1102),
      (104,12,'non-perishable','shs.20000',4,1103),
      (105,15,'non-perishable','shs.10000',5,1103),
      (106,10,'fragile','shs.10000',5,1103);

-- Creating the 'Bus' table 
CREATE TABLE Bus(
    Number_Plate VARCHAR(45) PRIMARY KEY NOT NULL UNIQUE,
    Route_ID INT NOT NULL UNIQUE
);
-- Inserting data into the 'Bus' table
INSERT INTO Bus
VALUES('UBE 234T',1101),
      ('UBH 123R',1102),
      ('UBK 456Y',1103);
--Creating view for Passengers
CREATE VIEW Passengers_View
AS
SELECT  Passenger.Passenger_ID,Passenger.First_Name,Passenger.Last_Name,Passenger.Gender,Passenger.DateOfBirth,Passenger.Phone_Number,Passenger.Email,
        Ticket.Ticket_ID,Ticket.Travel_Date ,Ticket.Departure_Time ,Ticket.Arrival_Time,Ticket.Ticket_Payment,
        Routes.Route_ID,Cargo.Cargo_ID,Bus.Number_Plate
FROM Passenger,Ticket,Routes,Cargo,Bus
WHERE Ticket.Ticket_ID IS NOT NULL;
--Creating view for Drivers and Conductors
CREATE VIEW DC_Staff_View
AS
SELECT Staff.Staff_ID,Staff.F_Name,Staff.L_Name,Staff.Contact,Staff.Staff_Role,
       Bus.Number_Plate,Routes.Route_ID,Routes.Route_Name,Routes.Departure_Station,Routes.Arrival_Station,
       Passenger.First_Name,Passenger.Last_Name,Ticket.Ticket_ID
FROM Staff,Bus,Routes,Passenger,Ticket
WHERE Staff_Role='Driver' OR 'Conductor';


ALTER TABLE passenger 
ADD CONSTRAINT fk_Ticket_ID
FOREIGN KEY(Ticket_ID) REFERENCES ticket(Ticket_ID);
 
ALTER TABLE passenger 
ADD CONSTRAINT fk_Route_ID 
FOREIGN KEY(Route_ID) REFERENCES Routes(Route_ID);

-- Add a foreign key constraint to ensure that Route_ID in 'Ticket' table corresponds to Route_ID in 'Routes' table
ALTER TABLE ticket 
ADD CONSTRAINT fk_Route_ID_1
FOREIGN KEY(Route_ID) REFERENCES Routes(Route_ID);

-- Adding a foreign key constraint to ensure that Route_ID in 'Staff' table corresponds to Route_ID in 'Routes' table
ALTER TABLE staff 
ADD CONSTRAINT fk_Route_ID_2
FOREIGN KEY(Route_ID) REFERENCES Routes(Route_ID);

ALTER TABLE routes 
ADD CONSTRAINT fk_Cargo_ID
FOREIGN KEY(Cargo_ID) REFERENCES Cargo(Cargo_ID);

ALTER TABLE routes 
ADD CONSTRAINT fk_Staff_ID
FOREIGN KEY(Staff_ID) REFERENCES Staff(Staff_ID);

ALTER TABLE routes 
ADD CONSTRAINT fk_Passenger_ID
FOREIGN KEY(Passenger_ID) REFERENCES passenger(Passenger_ID);

-- Adding foreign key constraint on Passenger_ID in 'Cargo' table to link with the 'Passenger' table
ALTER TABLE cargo 
ADD CONSTRAINT fk_Passenger_ID_1
FOREIGN KEY(Passenger_ID) REFERENCES Passenger(Passenger_ID);

-- Adding foreign key constraint on Route_ID in 'Cargo' table to link with the 'Routes' table
ALTER TABLE cargo 
ADD CONSTRAINT fk_Route_ID_3
FOREIGN KEY(Route_ID) REFERENCES routes(Route_ID);


ALTER TABLE bus 
ADD CONSTRAINT fk_Route_ID_4
FOREIGN KEY(Route_ID) REFERENCES routes(Route_ID);


