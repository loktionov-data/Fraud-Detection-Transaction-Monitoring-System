##Suspicious transactions
DELIMITER $$
CREATE PROCEDURE find_suspicious()
BEGIN
SELECT `customers`.`ID`, `customers`.`name`, `customers`.`country`, `transactions`.`date`, 
COUNT(`transactions`.`transaction_ID`) AS `transaction_count`, ROUND(SUM(`transactions`.`amount`),2) AS `total_amount`
FROM `customers` JOIN `transactions` ON `customers`.`ID` = `transactions`.`customer_ID`
GROUP BY `transactions`.`customer_ID`, DATE(`transactions`.`date`)
HAVING `total_amount` > 10000 OR `transaction_count` > 5 
ORDER BY `total_amount` DESC;
END$$
DELIMITER ;

##Create alerts in alerts table for suspicious transactions
DELIMITER //
CREATE PROCEDURE generate_alerts()
BEGIN
INSERT INTO alerts(`customer_ID`, `message`, `created_at`)
SELECT `transactions`.`customer_ID`, CONCAT('Suspicious activity detected on ', DATE(`transactions`.`date`), 
               ': total_amount=', ROUND(SUM(`transactions`.`amount`),2), 
               ', transactions_count=', COUNT(*)),
NOW()
FROM `transactions`
GROUP BY `transactions`.`customer_ID`, DATE(`transactions`.`date`)
HAVING ABS(SUM(`transactions`.`amount`)) > 10000 OR COUNT(*) > 5;
END//
DELIMITER ;

##Country statistics (active clients, total sums)
DELIMITER $$
CREATE PROCEDURE country_stats()
BEGIN
SELECT `cusotmers`.`country`, COUNT(DISTINCT `transactions`.`customer_ID`) as `active_clients`,
ROUND(SUM(`transactions`.`amount`),2) as `total_transactions_sum`,
ROUND(AVG(`transactions`.`amount`),2) AS `average_transaction_sum`
FROM `customers` JOIN `transactions` ON `customers`.`ID` = `transactions`.`customer_ID`
GROUP BY `customer`.`country`
ORDER BY `total_transactions_sum` DESC;
END$$
DELIMITER ;