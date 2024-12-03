-- Select all Rental properties which aren’t supervised by any staff member
Select * FROM propertyForRent WHERE staffNo IS NULL;
-- What is the Average, Maximum and Minimum Salary earned by a staff member
SELECT AVG(salary) AS average, MAX(salary), MIN(salary) FROM staff;
-- Are there some staff members who earn in the range of 20000 – 60000
SELECT fName, lName, salary FROM staff WHERE salary BETWEEN 20000 AND 60000;
-- Find all owners with the string ‘Glasgow’ in their address.
SELECT * FROM privateOwner WHERE address LIKE "%Glasgow%";
-- List all staff members in position of Manager and Supervisor who earn above 20000
SELECT * FROM staff WHERE position IN ("Manager", "Supervisor") AND salary > 20000;
-- List the number of staff members per branch
SELECT branchNo, COUNT(staffNO) FROM staff GROUP BY branchNo;
-- List all branches with only one staff member
SELECT branchNo, COUNT(staffNO) AS counting FROM staff GROUP BY branchNo HAVING counting = 1;
-- List names of staff members who supervise property in London
SELECT fName, lName FROM staff WHERE branchNo IN (SELECT branchNo FROM propertyForRent WHERE city = "London");