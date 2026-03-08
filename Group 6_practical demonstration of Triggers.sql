/* GROUP 6 — On-Campus Student Accommodation Management System
   Demonstrating Triggers */

CREATE DATABASE student_accomodation_mgtsystem;
USE student_accomodation_mgtsystem;

/*Creating tables so as to be able to insert sample data 
to demonstrate triggers*/

CREATE TABLE Room (
  RoomNumber VARCHAR(10) PRIMARY KEY
);

CREATE TABLE Student (
  RegNo       VARCHAR(20)  PRIMARY KEY,
  StudentName VARCHAR(100) NOT NULL
);

CREATE TABLE Bed (
  RoomNumber VARCHAR(10) NOT NULL,
  BedNumber  INT         NOT NULL,
  BedStatus  ENUM('Available','Occupied') NOT NULL DEFAULT 'Available',
  PRIMARY KEY (RoomNumber, BedNumber),
  FOREIGN KEY (RoomNumber) REFERENCES Room(RoomNumber)
);

CREATE TABLE Payment (
  PaymentID          INT         PRIMARY KEY,
  RegNo              VARCHAR(20) NOT NULL,
  VerificationStatus ENUM('Pending','Verified') NOT NULL DEFAULT 'Pending',
  FOREIGN KEY (RegNo) REFERENCES Student(RegNo)
);

CREATE TABLE Booking (
  BookingID INT         PRIMARY KEY AUTO_INCREMENT,
  RegNo     VARCHAR(20) NOT NULL,
  RoomNumber VARCHAR(10) NOT NULL,
  BedNumber  INT        NOT NULL,
  PaymentID  INT        NOT NULL,
  Semester   VARCHAR(20) NOT NULL,
  FOREIGN KEY (RegNo)              REFERENCES Student(RegNo),
  FOREIGN KEY (RoomNumber, BedNumber) REFERENCES Bed(RoomNumber, BedNumber),
  FOREIGN KEY (PaymentID)          REFERENCES Payment(PaymentID),
  UNIQUE (RegNo, Semester),               -- one booking per student per semester
  UNIQUE (RoomNumber, BedNumber, Semester) -- one student per bed per semester
);

--Inserting sample data

INSERT INTO Room    VALUES ('C3');
INSERT INTO Student VALUES ('M24B23/011', 'Kobumanzi Trishia');
INSERT INTO Bed     VALUES ('C3', 1, 'Available');
INSERT INTO Payment VALUES (1001, 'M24B23/011', 'Pending');

--Applying a trigger to ensure that a student cannot book a bed if there payment is not verified

DELIMITER $$
CREATE TRIGGER to_validate_booking
BEFORE INSERT ON Booking
FOR EACH ROW
BEGIN
  IF (SELECT VerificationStatus FROM Payment WHERE PaymentID = NEW.PaymentID) <> 'Verified' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'You cannot book because your payment is not verified.';
  END IF;

  IF (SELECT BedStatus FROM Bed WHERE RoomNumber = NEW.RoomNumber AND BedNumber = NEW.BedNumber) <> 'Available' THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The bed is already occupied.';
  END IF;
END$$
DELIMITER ;

--Testing the code
--Trigger blocks booking because payment is not yet verified
INSERT INTO Booking (RegNo, RoomNumber, BedNumber, PaymentID, Semester)
VALUES ('M24B23/011', 'C3', 1, 1001, '2025-S1');
--Expected: ERROR — "You cannot book because your payment is not verified."

--Verifying the payment so that booking can be allowed
UPDATE Payment SET VerificationStatus = 'Verified' WHERE PaymentID = 1001;

--Trigger now allows booking since payment is verified
INSERT INTO Booking (RegNo, RoomNumber, BedNumber, PaymentID, Semester)
VALUES ('M24B23/011', 'C3', 1, 1001, '2025-S1');
--Expected: SUCCESS

--View results
SELECT * FROM Booking;
SELECT * FROM Payment;