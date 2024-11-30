CREATE DATABASE Uganda;
USE Uganda;
CREATE TABLE CITIZEN(
    NIN INT,
    Fname VARCHAR(3),
    Lname VARCHAR(15),
    Gender VARCHAR(10),
    DistrictCode VARCHAR(10)
);

CREATE TABLE DISTRICT(
    DistrictCode VARCHAR(10),
    Name VARCHAR(15),
    Region VARCHAR(15)
);
ALTER TABLE CITIZEN
ADD CONSTRAINT Con1
PRIMARY KEY (NIN);
ALTER TABLE DISTRICT
ADD CONSTRAINT Con2
PRIMARY KEY (DistrictCode);
ALTER TABLE CITIZEN
ADD CONSTRAINT Con3
CHECK (LENGTH(NIN)>=11);
ALTER TABLE DISTRICT
ADD COLUMN Population INT;
INSERT INTO CITIZEN
VALUES('123456789001','Trishia','Kobumanzi','Female','M1'),
      ('098765432111','Victor','Ssemanda','Male','K2');
INSERT INTO DISTRICT
VALUES('M1','Mbarara','Western',3000),
      ('K2','Kabale','Western',5000);
CREATE VIEW DistrictView
AS
SELECT COUNT(DistrictCode) AS NumberofDistricts FROM DISTRICT;
SELECT*FROM districtview;
CREATE VIEW FullnameView
AS
SELECT Fname,Lname FROM CITIZEN;
CREATE VIEW NorthernView
AS
SELECT*FROM citizen 
WHERE Region='Northern';
CREATE VIEW DistrictA_View
AS
SELECT Name FROM district
WHERE Name='A%';

CREATE VIEW TotalView
AS
SELECT SUM(Population) AS TotalPopulation FROM district;

CREATE VIEW HighestView
AS
SELECT MAX(Population) FROM district;
SELECT*FROM highestview;
ALTER TABLE DISTRICT
ADD CONSTRAINT Con4
UNIQUE(Name);

ALTER TABLE citizen
MODIFY NIN INT NOT NULL;
ALTER TABLE citizen
MODIFY Fname VARCHAR(3) NOT NULL;
ALTER TABLE citizen
MODIFY Lname VARCHAR(15) NOT NULL;
ALTER TABLE citizen
MODIFY Gender VARCHAR(10) NOT NULL;
ALTER TABLE citizen
MODIFY DistrictCode VARCHAR(10) NOT NULL;

ALTER TABLE district
MODIFY DistrictCode VARCHAR(10) NOT NULL;
ALTER TABLE district
MODIFY Name VARCHAR(15) NOT NULL;
ALTER TABLE district
MODIFY Region VARCHAR(15) NOT NULL;

ALTER TABLE citizen
MODIFY Fname VARCHAR(15) NOT NULL;



