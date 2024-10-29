-- Active: 1728740067802@@127.0.0.1@3306
CREATE DATABASE School_Students;
    
    CREATE TABLE Student(
        Regno VARCHAR(15),
        Accessno VARCHAR(10),
        StudentName VARCHAR(25),
        TelNo INT,
        AmountPaid INT
    );

    DESCRIBE Student;

    ALTER TABLE Student
    ADD CONSTRAINT Con1
    PRIMARY KEY (Regno);

    ALTER TABLE Student
    ADD CONSTRAINT Con2
    CHECK(LENGTH(Regno)>9);

    ALTER TABLE Student
    MODIFY Accessno VARCHAR(10) NOT NULL; 

    ALTER TABLE Student
    MODIFY StudentName VARCHAR(25) NOT NULL;

    ALTER TABLE Student
    ADD CONSTRAINT Con3
    CHECK(LENGTH(TelNo)=10);

    ALTER TABLE Student
    MODIFY AmountPaid INT NOT NULL;
    ALTER TABLE Student
    ADD CONSTRAINT Con4
    CHECK(AmountPaid>200000);

    ALTER TABLE Student
    ADD COLUMN Course VARCHAR(10);

    ALTER TABLE Student
    ADD CONSTRAINT Con5
    CHECK(IN('BSCS','BSDS','BSIT','DIT'));

    ALTER TABLE Student
    ADD CONSTRAINT Con6
    UNIQUE(Accessno);

    