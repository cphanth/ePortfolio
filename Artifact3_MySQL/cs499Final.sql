-- create a new user; she can log onto DB from anywhere
-- domain, ip address, host is not specified
CREATE USER jen
IDENTIFIED BY '12qwaszx!@QWASZX';

-- create a new user
CREATE USER bob
IDENTIFIED BY 'password1234';

-- view users
SELECT *
FROM mysql.user;

-- reset password for a user
SET PASSWORD
FOR jen = "p@55w0rd"

-- grant priveleges for user jen
-- only allow read and write priveleges
-- restrict from changing DB structure
GRANT SELECT, INSERT, UPDATE, DELETE, EXECUTE
ON sql_store.*
TO jen

-- grant priveleges for user bob to do anything to any database
GRANT CREATE VIEW
ON *.*
TO bob;

-- revoke priveleges; whoops! bob shouldn't have that kind of power!revoke!
REVOKE CREATE VIEW
ON *.*
FROM bob;

-- bob left the company; remove his user acct
DROP USER bob;

-- implementing SUBQUERIES and AGGREGATE functions!
-- here return list of employees that make more than the average salary within the company
USE sql_hr;

SELECT 
	first_name,
    last_name,
    salary
FROM employees
WHERE salary >
(
	SELECT
		AVG(salary)
	FROM employees;
)

-- implementing correlated subqueries
-- now execute the subquery for each row but average is calculated only for those in the SAME office

SELECT *
FROM employees e
WHERE salary > (
	SELECT AVG(salary)
    FROM employees
    WHERE office_id = e.office_id
);

-- implementing subqueries in the SELECT clause
-- use the sql_invoicing database
-- this performs the average function on the invoice_total and compares each invoice to display the difference
use sql_invoicing;

SELECT
	invoice_id,
    invoice_total,
    (SELECT AVG(invoice_total)
		FROM invoices) AS invoice_average,
	invoice_total - (SELECT invoice_average) AS difference
FROM invoices;

-- joining three tables, using aliases, and filtering!
-- uses the sql_store database
-- using DISTINCT keyword reduces multiple values
USE sql_store;

SELECT DISTINCT customer_id, first_name, last_name
FROM customers c
JOIN orders o USING (customer_id)
JOIN order_items oi USING (order_id)
WHERE oi.product_id = 3;

-- save subqueries in views for complicated subqueries to be used more simply
-- views can be used like tables BUT DO NOT store data
-- creating a view does not return data itself
use sql_invoicing;

CREATE VIEW sales_by_client AS
    SELECT
	   c.client_id,
       c.name,
       SUM(invoice_total) AS total_sales
    FROM clients c
    JOIN invoices i USING (client_id)
    GROUP BY client_id, name;

-- BUT you can query a View like a table
-- without having to write the entire subquery!
SELECT *
FROM sales_by_client
WHERE total_sales > 500;

-- triggers help to maintain data consistency
-- by automatically executing a block of code
-- before or after insert/update/delete statments
/*
here we will update the invoices table when
a payment is inserted into the payments table
*/

DELIMITER $$

CREATE TRIGGER payments_after_insert	-- name of trigger describes table, when, and type of action
	AFTER INSERT ON payments
    FOR EACH ROW		-- this is triggered for each new row
BEGIN	-- raw SQL is written here
	UPDATE invoices
    SET payment_total = payment_total + NEW.amount
    WHERE invoice_id = NEW.invoice_id;
END $$

DELIMITER ;

-- now test this by adding a payment
-- the format of the values reflects the payments table
-- payment_id, client_id, invoice_id, date, amount, payment method
INSERT INTO payments
VALUES (DEFAULT, 5, 3, '2019-01-01', 10, 1);

-- after this executes, the invoice table also updates!



