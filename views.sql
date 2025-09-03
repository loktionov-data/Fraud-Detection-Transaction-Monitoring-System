##Clients info view
CREATE VIEW client_info AS
SELECT `customer_ID`, `customers`.`name`, COUNT(`transactions`.`transaction_ID`) AS `amount_of_transactions`, ROUND(AVG(`transactions`.`amount`),2) AS `mean_transaction`, 
MAX(`date`) as `last_date` 
FROM `transactions` JOIN `customers` ON `transactions`.`customer_ID` = `customers`.`ID`
GROUP BY `customer_ID`;

##Countries by activity
CREATE VIEW countries_by_activity AS
SELECT `customers`.`country`, COUNT(`transactions`.`customer_ID`) AS `amount_of_transactions`, 
COUNT(DISTINCT `transactions`.`customer_ID`) AS `total_users`, ROUND(SUM(`transactions`.`amount`),2) AS `total_sum`, MAX(`transactions`.`date`) as `last_date`
FROM `transactions` JOIN `customers` ON `customers`.`ID` = `transactions`.`customer_ID`
GROUP BY `country`
ORDER BY `amount_of_transactions` DESC;

##Fee share
CREATE VIEW fee_share AS
SELECT ROUND(SUM(CASE WHEN `transactions`.`transaction_type` = 'Fee' THEN ABS(`transactions`.`amount`) ELSE 0 END),2) AS `fee_sum`,
ROUND(SUM(ABS(`transactions`.`amount`)),2) AS `total_sum`, 
ROUND(SUM(CASE WHEN `transactions`.`transaction_type` = 'Fee' THEN ABS(`transactions`.`amount`) ELSE 0 END) * 100.0 / SUM(ABS(transactions.`amount`)), 2) AS fee_share
FROM `transactions`;

##Suspicious users
CREATE VIEW suspicious_users AS
SELECT `customers`.`ID`, `customers`.`name`, `customers`.`country`, `customers`.`balance` , 
COUNT(`transactions`.`transaction_id`) AS `withdrawals_last_month`
FROM `customers` JOIN `transactions` ON `customers`.`ID` = `transactions`.`customer_ID`
WHERE `transactions`.`transaction_type` = 'Withdrawal' AND `transactions`.`date` >= CURDATE() - INTERVAL 30 DAY
GROUP BY `customers`.`ID`, `customers`.`name`, `customers`.`country`, `customers`.`balance`
HAVING `withdrawals_last_month` >= 3 AND `customers`.`balance` < 10000;  