CREATE TABLE `customers`(
`ID` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
`name` VARCHAR(50),
`country` VARCHAR(50),
`balance` DECIMAL(10,2)
)AUTO_INCREMENT = 1000;

CREATE TABLE `transactions`(
`transaction_ID` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
`customer_ID` INT NOT NULL,
`amount` DECIMAL(10,2),
`transaction_type` ENUM('Deposit','Withdrawal','Transfer','Payment','Fee','Refund'),
`date` DATE,
FOREIGN KEY(`customer_ID`) REFERENCES `customers`(`ID`)
)AUTO_INCREMENT = 10000;

CREATE TABLE `suspicious_flags`(
`flag_id` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
`transaction_ID` INT NOT NULL,
`reason` VARCHAR (255),
`created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY(`transaction_ID`) REFERENCES `transactions`(`transaction_ID`)
)AUTO_INCREMENT = 100;

CREATE TABLE `alerts`(
`alert_ID` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
`customer_ID` INT,
`message` TEXT,
`created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
FOREIGN KEY(`customer_ID`) REFERENCES `customers`(`ID`)
)AUTO_INCREMENT = 200;