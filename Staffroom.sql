-- Active: 1728740067802@@127.0.0.1@3306
CREATE DATABASE Staffroom;

USE Staffroom;

CREATE TABLE Courses(
    Code INT,
    Name VARCHAR(45),
    Years INT,
    Sem INT,
    CourseYear INT
);

ALTER TABLE Courses
ADD COLUMN Program VARCHAR(15);

INSERT INTO Courses
VALUES(01,'Computer Science',3,2,1,'Discrete Math'),
      (02,'Data Science',3,2,1,'Web Application'),
      (03,'Information Technology',3,2,1,'Discrete Math'),
      (04,'Data Science',3,1,1,'Fundamentals');
    
SELECT*FROM Courses;
CREATE VIEW Student_view_c
AS
SELECT Name,Years,Sem,Program FROM Courses
WHERE Name= 'Data Science';

SELECT*FROM Student_view_c;

CREATE VIEW HOD_View
AS
SELECT *fROM Courses
WHERE Name IN('Computer Science','Data Science');
DROP VIEW HOD_View;
CREATE VIEW HODView
AS
SELECT *fROM Courses
WHERE Name IN('Computer Science','Data Science');

SELECT *FROM HODView

INSERT INTO HODView VALUES(05,'Computer Science',3,1,2,'Discrete Math');
SELECT*FROM HODView;
UPDATE HODView SET Program='Probability'
WHERE Name='Computer Science' AND Sem=2;
SELECT*FROM HODView;




