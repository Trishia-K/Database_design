CREATE DATABASE IF NOT EXISTS AgriculturalSupportDB;
USE AgriculturalSupportDB;

-- 1. GEOGRAPHY
CREATE TABLE district(
    districtID INT AUTO_INCREMENT PRIMARY KEY,
    districtName VARCHAR(50) NOT NULL UNIQUE,
    region ENUM('Central','Western','Eastern','Northern') NOT NULL
);

CREATE TABLE subCounty(
    subCountyID INT AUTO_INCREMENT PRIMARY KEY,
    subCountyName VARCHAR(50) NOT NULL,
    districtID INT NOT NULL,
    FOREIGN KEY (districtID) REFERENCES district(districtID) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE village(
    villageID INT AUTO_INCREMENT PRIMARY KEY,
    villageName VARCHAR(50) NOT NULL,
    parishName VARCHAR(50),
    subCountyID INT NOT NULL,
    FOREIGN KEY (subCountyID) REFERENCES subCounty(subCountyID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 2. USERS & ROLES
CREATE TABLE user(
    userID INT AUTO_INCREMENT PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    dateOfBirth DATE NOT NULL,
    phoneNumber VARCHAR(15),
    NIN CHAR(14) NOT NULL UNIQUE,
    dateRegistered DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE farmer(
    farmerID INT PRIMARY KEY,
    TIN VARCHAR(20),
    farmerType ENUM('SmallScale','Commercial'),
    cooperativeName VARCHAR(100),
    isActive BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (farmerID) REFERENCES user(userID) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE extensionWorker(
    workerID INT PRIMARY KEY,
    qualification VARCHAR(100),
    dateEmployed DATE NOT NULL,
    subCountyID INT NOT NULL,
    isActive BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (workerID) REFERENCES user(userID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (subCountyID) REFERENCES subCounty(subCountyID) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE ministryStaff(
    staffID INT PRIMARY KEY,
    department VARCHAR(100),
    staffRole VARCHAR(50),
    accessLevel VARCHAR(20) DEFAULT 'standard',
    FOREIGN KEY (staffID) REFERENCES user(userID) ON DELETE CASCADE ON UPDATE CASCADE
);

-- 3. FARM
CREATE TABLE farm(
    farmID INT AUTO_INCREMENT PRIMARY KEY,
    farmerID INT NOT NULL,
    villageID INT NOT NULL,
    farmName VARCHAR(100),
    farmSizeAcres DECIMAL(10,2) NOT NULL CHECK (farmSizeAcres > 0),
    coffeeVariety ENUM('Robusta','Arabica') NOT NULL,
    gpsCoordinates VARCHAR(100) NOT NULL,
    landOwnershipType VARCHAR(50),
    FOREIGN KEY (farmerID) REFERENCES farmer(farmerID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (villageID) REFERENCES village(villageID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 4. SEASON
CREATE TABLE season(
    seasonID INT AUTO_INCREMENT PRIMARY KEY,
    seasonYear INT NOT NULL,
    seasonLabel VARCHAR(20) NOT NULL,
    startDate DATE NOT NULL,
    endDate DATE NOT NULL,
    CHECK (endDate > startDate),
    UNIQUE (seasonYear, seasonLabel)
);

-- 5. PRODUCTION & VISITS
CREATE TABLE productionRecord(
    recordID INT AUTO_INCREMENT PRIMARY KEY,
    farmID INT NOT NULL,
    seasonID INT NOT NULL,
    quantityKG DECIMAL(10,2) NOT NULL CHECK (quantityKG >= 0),
    qualityGrade VARCHAR(20),
    status ENUM('Pending','Verified') DEFAULT 'Pending',
    verifiedBy INT NULL,
    dateRecorded DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (farmID) REFERENCES farm(farmID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (seasonID) REFERENCES season(seasonID) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (verifiedBy) REFERENCES extensionWorker(workerID) ON DELETE SET NULL ON UPDATE CASCADE,
    UNIQUE KEY one_record_per_season (farmID, seasonID)
);

CREATE TABLE farmVisit(
    visitID INT AUTO_INCREMENT PRIMARY KEY,
    farmID INT NOT NULL,
    workerID INT NOT NULL,
    visitDate DATE NOT NULL DEFAULT (CURRENT_DATE),
    purposeOfVisit VARCHAR(255),
    problemsObserved TEXT,
    adviceGiven TEXT,
    followUpRequired BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (farmID) REFERENCES farm(farmID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (workerID) REFERENCES extensionWorker(workerID) ON DELETE RESTRICT ON UPDATE CASCADE
);

-- 6. INVENTORY
CREATE TABLE product(
    productID INT AUTO_INCREMENT PRIMARY KEY,
    productName VARCHAR(100) NOT NULL,
    productType ENUM('Seedling','Fertilizer','Pesticide','Tools') NOT NULL,
    unitOfMeasure VARCHAR(20),
    stockQuantity INT NOT NULL DEFAULT 0 CHECK (stockQuantity >= 0)
);

CREATE TABLE productDistribution(
    distributionID INT AUTO_INCREMENT PRIMARY KEY,
    productID INT NOT NULL,
    farmID INT NOT NULL,
    staffID INT,
    workerID INT,
    seasonID INT NOT NULL,
    quantityDistributed INT NOT NULL CHECK (quantityDistributed > 0),
    dateDispatched DATE NOT NULL DEFAULT (CURRENT_DATE),
    verificationDate DATE DEFAULT NULL,
    status ENUM('Pending','Received') DEFAULT 'Pending',
    FOREIGN KEY (productID) REFERENCES product(productID) ON DELETE RESTRICT ON UPDATE CASCADE,
    FOREIGN KEY (farmID) REFERENCES farm(farmID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (staffID) REFERENCES ministryStaff(staffID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (workerID) REFERENCES extensionWorker(workerID) ON DELETE SET NULL ON UPDATE CASCADE,
    FOREIGN KEY (seasonID) REFERENCES season(seasonID) ON DELETE RESTRICT ON UPDATE CASCADE,
    UNIQUE KEY one_product_per_farm_per_season (farmID, productID, seasonID)
);

-- 7. VIEWS
CREATE VIEW FarmerDashboard AS
SELECT
    p.userID AS farmerID,
    p.firstName,
    p.lastName,
    f.farmID,
    f.farmName,
    f.farmSizeAcres,
    f.coffeeVariety,
    v.villageName,
    sc.subCountyName,
    d.districtName,
    ew.workerID AS extensionWorkerID,
    wu.firstName AS workerFirstName,
    wu.lastName AS workerLastName,
    ew.qualification AS workerQualification,
    s.seasonLabel,
    pr.quantityKG,
    pr.status AS productionStatus
FROM user p
JOIN farmer fa ON p.userID = fa.farmerID
JOIN farm f ON fa.farmerID = f.farmerID
JOIN village v ON f.villageID = v.villageID
JOIN subCounty sc ON v.subCountyID = sc.subCountyID
JOIN district d ON sc.districtID = d.districtID
LEFT JOIN extensionWorker ew ON ew.subCountyID = sc.subCountyID
LEFT JOIN user wu ON ew.workerID = wu.userID
LEFT JOIN productionRecord pr ON f.farmID = pr.farmID
LEFT JOIN season s ON pr.seasonID = s.seasonID;

CREATE VIEW WorkerPendingVerifications AS
SELECT
    pr.recordID,
    f.farmName,
    p.firstName AS farmerFirstName,
    p.lastName AS farmerLastName,
    pr.quantityKG,
    pr.dateRecorded
FROM productionRecord pr
JOIN farm f ON pr.farmID = f.farmID
JOIN user p ON f.farmerID = p.userID
WHERE pr.status = 'Pending';

CREATE VIEW StaffProductDashboard AS
SELECT
    productID,
    productName,
    productType,
    stockQuantity,
    CASE
        WHEN stockQuantity > 100 THEN 'Sufficient'
        WHEN stockQuantity BETWEEN 1 AND 100 THEN 'Low Stock'
        ELSE 'Out of Stock'
    END AS inventoryStatus
FROM product;

CREATE VIEW ProductionByDistrict AS
SELECT
    d.districtName,
    d.region,
    s.seasonLabel,
    COUNT(DISTINCT fa.farmerID) AS totalFarmers,
    SUM(pr.quantityKG) AS totalKG
FROM productionRecord pr
JOIN farm f ON pr.farmID = f.farmID
JOIN farmer fa ON f.farmerID = fa.farmerID
JOIN season s ON pr.seasonID = s.seasonID
JOIN village v ON f.villageID = v.villageID
JOIN subCounty sc ON v.subCountyID = sc.subCountyID
JOIN district d ON sc.districtID = d.districtID
GROUP BY d.districtName, d.region, s.seasonLabel;

-- 8. STORED PROCEDURES
DELIMITER //
CREATE PROCEDURE RegisterSystemUser(
    IN p_role VARCHAR(10),
    IN p_fname VARCHAR(50),
    IN p_lname VARCHAR(50),
    IN p_dob DATE,
    IN p_phone VARCHAR(15),
    IN p_nin CHAR(14),
    IN p_tin VARCHAR(20),
    IN p_fType VARCHAR(20),
    IN p_coop VARCHAR(100),
    IN p_qual VARCHAR(100),
    IN p_subID INT,
    IN p_dept VARCHAR(100),
    IN p_sRole VARCHAR(50)
)
BEGIN
    DECLARE v_id INT;
    START TRANSACTION;
        INSERT INTO user (firstName, lastName, dateOfBirth, phoneNumber, NIN)
        VALUES (p_fname, p_lname, p_dob, p_phone, p_nin);
        SET v_id = LAST_INSERT_ID();
        IF p_role = 'farmer' THEN
            INSERT INTO farmer (farmerID, TIN, farmerType, cooperativeName) VALUES (v_id, p_tin, p_fType, p_coop);
        ELSEIF p_role = 'worker' THEN
            INSERT INTO extensionWorker (workerID, qualification, dateEmployed, subCountyID) VALUES (v_id, p_qual, CURRENT_DATE, p_subID);
        ELSEIF p_role = 'staff' THEN
            INSERT INTO ministryStaff (staffID, department, staffRole) VALUES (v_id, p_dept, p_sRole);
        END IF;
    COMMIT;
END //

CREATE PROCEDURE RecordProduction(
    IN p_farmID INT,
    IN p_seasonID INT,
    IN p_quantityKG DECIMAL(10,2),
    IN p_qualityGrade VARCHAR(20)
)
BEGIN
    INSERT INTO productionRecord (farmID, seasonID, quantityKG, qualityGrade, status)
    VALUES (p_farmID, p_seasonID, p_quantityKG, p_qualityGrade, 'Pending');
END //
DELIMITER ;

-- 9. TRIGGERS
DELIMITER //
CREATE TRIGGER trg_disjoint_farmer BEFORE INSERT ON farmer FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM extensionWorker WHERE workerID = NEW.farmerID)
    OR EXISTS (SELECT 1 FROM ministryStaff WHERE staffID = NEW.farmerID)
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User already has a role in the system.';
    END IF;
END //

CREATE TRIGGER trg_disjoint_worker BEFORE INSERT ON extensionWorker FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM farmer WHERE farmerID = NEW.workerID)
    OR EXISTS (SELECT 1 FROM ministryStaff WHERE staffID = NEW.workerID)
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User already has a role in the system.';
    END IF;
END //

CREATE TRIGGER trg_disjoint_staff BEFORE INSERT ON ministryStaff FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM farmer WHERE farmerID = NEW.staffID)
    OR EXISTS (SELECT 1 FROM extensionWorker WHERE workerID = NEW.staffID)
    THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User already has a role in the system.';
    END IF;
END //

CREATE TRIGGER trg_stock_update BEFORE INSERT ON productDistribution FOR EACH ROW
BEGIN
    DECLARE v_stock INT;
    DECLARE v_visited INT;
    SELECT COUNT(*) INTO v_visited FROM farmVisit WHERE farmID = NEW.farmID;
    IF v_visited = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Farm has no logged visits. An extension worker must visit first.';
    END IF;
    SELECT stockQuantity INTO v_stock FROM product WHERE productID = NEW.productID;
    IF v_stock < NEW.quantityDistributed THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient stock for this distribution.';
    ELSE
        UPDATE product SET stockQuantity = stockQuantity - NEW.quantityDistributed WHERE productID = NEW.productID;
    END IF;
END //

CREATE TRIGGER trg_verify_production BEFORE UPDATE ON productionRecord FOR EACH ROW
BEGIN
    IF NEW.status = 'Verified' THEN
        IF NEW.verifiedBy IS NULL OR NOT EXISTS (SELECT 1 FROM extensionWorker WHERE workerID = NEW.verifiedBy)
        THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only a registered extension worker can verify production records.';
        END IF;
    END IF;
END //

CREATE TRIGGER trg_confirm_distribution BEFORE UPDATE ON productDistribution FOR EACH ROW
BEGIN
    IF NEW.status = 'Received' THEN
        IF NEW.workerID IS NULL OR NOT EXISTS (SELECT 1 FROM extensionWorker WHERE workerID = NEW.workerID)
        THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only an extension worker can confirm product receipt.';
        END IF;
        SET NEW.verificationDate = CURRENT_DATE;
    END IF;
END //
DELIMITER ;

-- 10. ROLES AND PRIVILEGES
CREATE ROLE IF NOT EXISTS farmer_role;
CREATE ROLE IF NOT EXISTS worker_role;
CREATE ROLE IF NOT EXISTS staff_role;

GRANT SELECT ON AgriculturalSupportDB.FarmerDashboard TO farmer_role;
GRANT INSERT ON AgriculturalSupportDB.productionRecord TO farmer_role;
GRANT SELECT ON AgriculturalSupportDB.product TO farmer_role;

GRANT SELECT ON AgriculturalSupportDB.WorkerPendingVerifications TO worker_role;
GRANT INSERT ON AgriculturalSupportDB.farmVisit TO worker_role;
GRANT UPDATE ON AgriculturalSupportDB.productionRecord TO worker_role;
GRANT INSERT ON AgriculturalSupportDB.productDistribution TO worker_role;
GRANT UPDATE ON AgriculturalSupportDB.productDistribution TO worker_role;
GRANT SELECT ON AgriculturalSupportDB.farm TO worker_role;

GRANT ALL PRIVILEGES ON AgriculturalSupportDB.* TO staff_role;

CREATE USER IF NOT EXISTS 'farmer_user'@'localhost' IDENTIFIED BY 'Farmer@2026';
CREATE USER IF NOT EXISTS 'worker_user'@'localhost' IDENTIFIED BY 'Worker@2026';
CREATE USER IF NOT EXISTS 'staff_user'@'localhost' IDENTIFIED BY 'Staff@2026';

GRANT farmer_role TO 'farmer_user'@'localhost';
GRANT worker_role TO 'worker_user'@'localhost';
GRANT staff_role TO 'staff_user'@'localhost';

SET DEFAULT ROLE farmer_role TO 'farmer_user'@'localhost';
SET DEFAULT ROLE worker_role TO 'worker_user'@'localhost';
SET DEFAULT ROLE staff_role TO 'staff_user'@'localhost';

FLUSH PRIVILEGES;

-- 11. SAMPLE DATA
INSERT INTO district (districtName, region) VALUES ('Mukono', 'Central'), ('Masaka', 'Central'), ('Mbale', 'Eastern'), ('Mbarara', 'Western');
INSERT INTO subCounty (subCountyName, districtID) VALUES ('Goma', 1), ('Seeta', 1), ('Nyendo', 2), ('Wanale', 3), ('Mbarara TC', 4);
INSERT INTO village (villageName, parishName, subCountyID) VALUES ('Misindye', 'Seeta Parish', 1), ('Namataba', 'Goma Parish', 2), ('Nyendo A', 'Nyendo Parish', 3), ('Busano', 'Wanale South', 4);

CALL RegisterSystemUser('farmer', 'Sarah', 'Namukasa', '1988-05-12', '0701111111', 'CM88000111111A', 'TIN-001', 'SmallScale', 'Mukono Coffee Growers', NULL, NULL, NULL, NULL);
CALL RegisterSystemUser('farmer', 'Moses', 'Ochieng', '1990-03-22', '0782222222', 'CM90000222222B', 'TIN-002', 'SmallScale', NULL, NULL, NULL, NULL, NULL);
CALL RegisterSystemUser('farmer', 'Grace', 'Atim', '1985-11-08', '0753333333', 'CF85000333333C', 'TIN-003', 'Commercial', 'Masaka Farmers Co-op', NULL, NULL, NULL, NULL);
CALL RegisterSystemUser('worker', 'John', 'Okello', '1980-07-15', '0774444444', 'CM80000444444D', NULL, NULL, NULL, 'BSc Agriculture', 1, NULL, NULL);
CALL RegisterSystemUser('worker', 'Lydia', 'Nakakande', '1983-02-28', '0705555555', 'CF83000555555E', NULL, NULL, NULL, 'Diploma Agri-Business', 3, NULL, NULL);
CALL RegisterSystemUser('staff', 'Robert', 'Byaruhanga', '1975-09-30', '0756666666', 'CM75000666666F', NULL, NULL, NULL, NULL, NULL, 'Crop Production', 'Officer');

INSERT INTO season (seasonYear, seasonLabel, startDate, endDate) VALUES (2024, '2024-A', '2024-03-01', '2024-05-31'), (2024, '2024-B', '2024-10-01', '2024-12-31');
INSERT INTO product (productName, productType, unitOfMeasure, stockQuantity) VALUES ('Robusta Seedlings', 'Seedling', 'plants', 300), ('NPK Fertilizer', 'Fertilizer', 'kg', 80);
INSERT INTO farm (farmerID, villageID, farmName, farmSizeAcres, coffeeVariety, gpsCoordinates, landOwnershipType) VALUES (1, 1, 'Namukasa Plot', 4.5, 'Robusta', '0.31, 32.58', 'Kibanja'), (3, 3, 'Atim Estate', 6.0, 'Arabica', '0.13, 31.73', 'Freehold');
INSERT INTO farmVisit (farmID, workerID, visitDate, purposeOfVisit, adviceGiven, followUpRequired) VALUES (1, 4, '2024-02-20', 'Pre-season inspection', 'Apply copper fungicide', TRUE), (2, 5, '2024-02-25', 'Farm registration', 'Water twice weekly', FALSE);
INSERT INTO productionRecord (farmID, seasonID, quantityKG, qualityGrade) VALUES (1, 1, 950.00, 'Grade A'), (2, 1, 2200.00, 'Grade A');
INSERT INTO productDistribution (productID, farmID, staffID, workerID, seasonID, quantityDistributed, dateDispatched) VALUES (1, 1, 6, 4, 1, 100, '2024-03-10'), (2, 2, 6, 5, 1, 25, '2024-03-12');

INSERT INTO farmer(farmerID, TIN) VALUES(4, 'TIN-006');