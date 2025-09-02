## Filling user data
DELIMITER $$
CREATE PROCEDURE SEEDUSERS()
BEGIN
	DECLARE `First_Name` VARCHAR(50);
    DECLARE `Surname` VARCHAR(50);
    DECLARE `seed_country` VARCHAR(50);
    DECLARE `seed_balance` DECIMAL(10,2);
    DECLARE `seed_name` VARCHAR(50);
    DECLARE `I` INT DEFAULT 1;
    
WHILE I <=200 DO
	SET `First_Name`= ELT(FLOOR(RAND()*50)+1,
    'Alexei', 'Katarina', 'Milena', 'Piotr', 'Anya', 'Sergei', 'Dominik', 'Ivana', 'Oleg',
    'Mikhail', 'Zoran', 'Jana', 'Bogdan', 'Daria', 'Viktor', 'Elzbieta', 'Stanislav', 'Nikita',
    'Agnieszka', 'Radek', 'Pavel', 'Magdalena', 'Stefan', 'Irena', 'Luka', 'Natalia', 'Boris',
    'Veronika', 'Andrei', 'Vesna', 'Leonard', 'Isabella', 'Dimitri', 'Tatiana', 'Jovan', 'Kristina',
    'Roman', 'Sofia', 'Igor', 'Marta', 'Leonid', 'Alina', 'Marek', 'Olga', 'Miroslav', 'Ludmila',
    'Ethan', 'Amelia', 'Yurii', 'Zlata');
    SET `Surname` = ELT(FLOOR(RAND()*80)+1,
    'Smith', 'Taylor', 'Morgan', 'Parker', 'Carter', 'Miller', 'Cooper', 'Turner', 'Walker', 'Harris', 'Lewis', 'Scott', 
    'Clarke', 'Reed', 'Gray', 'Price', 'Stone', 'Cole', 'Lane', 'Brooks', 'Hayes', 'Perry', 'West', 'Page', 'Hunt', 'Wells', 
    'Marsh', 'Frost', 'Grant', 'Blake', 'Dean', 'Pratt', 'Ford', 'Burke', 'Drake', 'Boone', 'Bell', 'Ross', 'Shaw', 'Frank', 
    'Jordan', 'Mason', 'Harper', 'Spencer', 'Sawyer', 'Baxter', 'Archer', 'Fisher', 'Hunter', 'Wheeler', 'Porter', 'Kramer', 
    'Weber', 'Roth', 'Haas', 'Braun', 'Stein', 'Frankel', 'Berger', 'Singer', 'Adler', 'Weiss', 'Stern', 'Katz', 'Rubin', 'Gold', 
    'Vogel', 'Haas', 'Wolf', 'Brand', 'Meyer', 'Klein', 'Lorenz', 'Hoff', 'Beck', 'Cross', 'Day', 'Shaw', 'Lane', 'Gill', 'Nash', 'Abbott');
    SET `seed_name` = CONCAT_WS(' ', `First_Name`, `Surname`);
    SET `seed_country` = ELT(FLOOR(RAND()*35)+1,
    'Germany', 'France', 'Italy', 'Spain', 'Portugal', 'Poland', 'Czechia', 'Slovakia', 'Hungary', 'Austria', 
    'Switzerland', 'Netherlands', 'Belgium', 'Denmark', 'Sweden', 'Norway', 'Finland', 'Estonia', 'Latvia', 'Lithuania', 
    'Greece', 'Croatia', 'Serbia', 'Bulgaria', 'Romania', 'Slovenia', 'Turkey', 'Georgia', 'Armenia', 'Canada', 'United States', 
    'Mexico', 'Brazil', 'Argentina', 'Australia', 'Japan'
    );
    SET `seed_balance` = ROUND(RAND()*100000 ,2 );
    INSERT INTO `customers`(`name`, `country`, `balance`) VALUES (`seed_name`, `seed_country`, `seed_balance`);
    SET I = I+1;
END WHILE;
END$$
DELIMITER ;

##Filling transactions data
DELIMITER //
CREATE PROCEDURE SEEDTRANSACTIONS()
BEGIN
	DECLARE `seed_cust_id` INT;
    DECLARE `seed_amount` DECIMAL(10,2);
    DECLARE `seed_type` VARCHAR(50);
    DECLARE `seed_date` DATE;
    DECLARE `I` INT DEFAULT 1;
WHILE I <= 800 DO
	SET `seed_cust_id` = (SELECT `ID` FROM customers ORDER BY RAND() LIMIT 1);
    SET `seed_amount` = ROUND(RAND()*50000 + 100,2);
    SET `seed_type` = ELT(FLOOR(RAND()*6)+1, 'Deposit','Withdrawal','Transfer','Payment','Fee','Refund');
    SET `seed_date` = DATE_ADD('2023-01-01', INTERVAL FLOOR(RAND()*911) DAY);
    INSERT INTO `transactions`(`customer_ID`, `amount`, `transaction_type`, `date`) VALUES (`seed_cust_id`, `seed_amount`, `seed_type`, `seed_date`);
    SET I = I+1;
END WHILE;
END//
DELIMITER ; 

##Filling suspicious flags 
DELIMITER $$
CREATE PROCEDURE SEEDFLAGS()
BEGIN
	DECLARE `seed_transaction_ID` INT;
    DECLARE `seed_reason` VARCHAR(255);
    DECLARE `seed_creation_date` TIMESTAMP;
    DECLARE `I` INT DEFAULT 1;
WHILE I <= 300 DO
	SET `seed_transaction_ID` = (SELECT `transaction_ID` FROM transactions ORDER BY RAND() LIMIT 1);
    SET `seed_reason` = ELT(FLOOR(RAND()*6)+1, 
    "High transaction amount",
    "Multiple withdrawals in short time",
    "Suspicious country transfer",
    "Unusual transaction pattern",
    "Balance below threshold",
    "Frequent failed transactions");
    SET `seed_creation_date` = DATE_ADD(CURRENT_TIMESTAMP, INTERVAL FLOOR(RAND() * -911) DAY);
    INSERT INTO suspicious_flags(`transaction_ID`, `reason`, `created_at`) VALUES(`seed_transaction_ID`, `seed_reason`, `seed_creation_date`);
    SET I = I+1;
END WHILE;
END$$
DELIMITER ;

##Filling alerts
DELIMITER //
CREATE PROCEDURE SEEDALERTS()
BEGIN
	DECLARE `seed_cust_id` INT;
    DECLARE `seed_message` TEXT;
    DECLARE `seed_creation_date`TIMESTAMP;
    DECLARE `I` INT DEFAULT 1;
WHILE I<=100 DO
	SET `seed_cust_id` = (SELECT `ID` FROM `customers` ORDER BY RAND() LIMIT 1);
    SET `seed_message` = ELT(FLOOR(RAND()*6)+1,
    "Client flagged for unusually high transaction.",
    "Customer performed multiple withdrawals within 1 hour.",
    "Suspicious transfer detected to foreign account.",
    "Possible fraud: irregular transaction activity.",
    "Low balance detected after recent withdrawal.",
    "Customer requires manual review due to failed transactions.");
    SET `seed_creation_date` = DATE_ADD(CURRENT_TIMESTAMP, INTERVAL FLOOR(RAND() * -911) DAY);
    INSERT INTO alerts(`customer_ID`, `message`, `created_at`)  VALUES(`seed_cust_id`, `seed_message`, `seed_creation_date`);
    SET I = I + 1;
END WHILE;
END//
DELIMITER ;

##Procedure for changing transactions data
DELIMITER $$
CREATE PROCEDURE MINUSVALUES()
BEGIN
SET SQL_SAFE_UPDATES = 0;
UPDATE `transactions` 
SET amount = amount *(-1)
WHERE transactions.`transaction_type` IN ("Withdrawal", "Fee", "Payment"); 
END$$
DELIMITER ;

##Saving tables
##Saving customers
DELIMITER //
CREATE PROCEDURE SAVECUSTOMERS()
BEGIN
SELECT 'ID', 'name', 'country', 'balance'
UNION ALL
SELECT * FROM customers  
INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\bank_customers.csv'  
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'  
LINES TERMINATED BY '\r\n';
END//
DELIMITER ;

##Saving transactions
DELIMITER //
CREATE PROCEDURE SAVETRANSACTIONS()
BEGIN
SELECT 'transaction_ID', 'customer_ID', 'amount', 'transaction_type', 'date'
UNION ALL
SELECT * FROM frauddetectionsystem.transactions  
INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\bank_transactions.csv'  
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'  
LINES TERMINATED BY '\r\n';
END//
DELIMITER ;

##Saving flags
DELIMITER //
CREATE PROCEDURE SAVEFLAGS()
BEGIN
SELECT 'flag_id', 'transaction_ID', 'reason', 'created_at'
UNION ALL
SELECT * FROM suspicious_flags
INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\suspicious_flags.csv'  
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'  
LINES TERMINATED BY '\r\n';
END//
DELIMITER ;

##Saving alerts
DELIMITER //
CREATE PROCEDURE SAVEALERTS()
BEGIN
SELECT 'alert_ID', 'customer_ID', 'message', 'created_at'
UNION ALL
SELECT * FROM suspicious_flags
INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\bank_alerts.csv'  
FIELDS TERMINATED BY ','  
ENCLOSED BY '"'  
LINES TERMINATED BY '\r\n';
END//
DELIMITER ;
