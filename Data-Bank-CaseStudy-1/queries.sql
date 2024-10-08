--note :: tables are stored in music project database

select * from regions

select * from customer_nodes

select * from customer_transactions

--CASE STUDY QUESTIONS
--1. How many different nodes make up the Data Bank network?

select count(distinct node_id)
from customer_nodes

--2. How many nodes are there in each region?
select regions.region_id, count(node_id)
from customer_nodes, regions
where customer_nodes.region_id = regions.region_id
group by regions.region_id

select region_id, count(node_id)
from customer_nodes inner join regions
using (region_id)
group by region_id

--3. How many customers are divided among the regions?
select region_id, count(distinct customer_id)
from customer_nodes inner join regions
using (region_id)
group by region_id

--4. Determine the total amount of transactions for each region name.
select region_name, sum(txn_amount)
from customer_nodes as n,  customer_transactions as t, regions as r 
where n.region_id = r.region_id and n.customer_id = t.customer_id
group by region_name

--5. How long does it take on an average to move clients to a new node?
SELECT ROUND(AVG((CAST(end_date AS date) - CAST(start_date AS date))::numeric), 2) AS average_duration_days
FROM customer_nodes
WHERE end_date != '9999-12-31';

SELECT ROUND(AVG((TO_DATE(end_date, 'YYYY-MM-DD') - TO_DATE(start_date, 'YYYY-MM-DD'))), 2) AS average_duration_days
FROM customer_nodes
WHERE end_date != '9999-12-31';

--6. What is the unique count and total amount for each transaction type?
select txn_type, count(customer_id), sum(txn_amount)
from customer_transactions
group by txn_type

--7. What is the average number and size of past deposits across all customers?
select round(count(customer_id)/(select count(distinct customer_id) from customer_transactions)) as ads
from customer_transactions
where txn_type= 'deposit'

--8.For each month-how many Data Bank customers make more than 1 depositand at least either 1 purchase or 1 withdrawal in a single month?
WITH transaction_count_per_month_cte AS (
    SELECT
        customer_id,
        EXTRACT(MONTH FROM CAST(txn_date AS DATE)) AS txn_month,
        SUM(CASE WHEN txn_type = 'deposit' THEN 1 ELSE 0 END) AS deposit_count,
        SUM(CASE WHEN txn_type = 'withdrawal' THEN 1 ELSE 0 END) AS withdrawal_count,
        SUM(CASE WHEN txn_type = 'purchase' THEN 1 ELSE 0 END) AS purchase_count
    FROM
        customer_transactions
    GROUP BY
        customer_id,
        EXTRACT(MONTH FROM CAST(txn_date AS DATE))
)

SELECT
    txn_month,
    COUNT(DISTINCT customer_id) AS cust_count
FROM
    transaction_count_per_month_cte
WHERE
    deposit_count > 1 AND (purchase_count >= 1 OR withdrawal_count >= 1)
GROUP BY
    txn_month;
