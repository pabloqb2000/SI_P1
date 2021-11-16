/*
SELECT
    MIN(balance) AS min_balance,
    MAX(balance) AS max_balance,
    AVG(balance) AS avg_balance
FROM customers;

SELECT 
    orderdetail.price AS order_price,
    EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM orders.orderdate) AS year_diff,
    products.price AS product_price
FROM orderdetail
INNER JOIN products ON orderdetail.prod_id = products.prod_id
INNER JOIN orders   ON orderdetail.orderid = orders.orderid
LIMIT 5;

SELECT netamount, tax, totalamount, sum(price * quantity)
FROM orders
INNER JOIN orderdetail ON orderdetail.orderid = orders.orderid
GROUP BY orders.orderid
LIMIT 5;

SELECT * FROM getTopSales(2015, 2021);

SELECT * FROM getTopActors('Drama') LIMIT 5;


SELECT * FROM orders ORDER BY orderdate LIMIT 2;
SELECT * FROM orderdetail WHERE prod_id = 4432 AND orderid = 151582;
UPDATE orderdetail
SET quantity = 3
WHERE prod_id = 4432 AND orderid = 151582;
SELECT * FROM orders ORDER BY orderdate LIMIT 2;
UPDATE orderdetail
SET quantity = 1
WHERE prod_id = 4432 AND orderid = 151582;
SELECT * FROM orders ORDER BY orderdate LIMIT 2;

DELETE FROM orderdetail  WHERE prod_id = 4432 AND orderid = 151582;
SELECT * FROM orders ORDER BY orderdate LIMIT 2;

INSERT INTO orderdetail  VALUES
    (151582, 4432, 12.3529411764706, 1);
SELECT * FROM orders ORDER BY orderdate LIMIT 2;
*/

UPDATE orderdetail
SET quantity = 30
WHERE orderid = 146760 AND prod_id = 3758;

SELECT * FROM orders WHERE orderid = 146760;
SELECT * FROM orderdetail
LEFT JOIN inventory ON inventory.prod_id = orderdetail.prod_id
WHERE orderid = 146760;
SELECT firstname, balance, loyalty FROM customers
INNER JOIN orders ON customers.customerid = orders.customerid
WHERE orderid = 146760;
SELECT * FROM alerts;

UPDATE orders
SET status = 'Paid'
WHERE orderid = 146760;

SELECT * FROM orders WHERE orderid = 146760;
SELECT * FROM orderdetail
LEFT JOIN inventory ON inventory.prod_id = orderdetail.prod_id
WHERE orderid = 146760;
SELECT firstname, balance, loyalty FROM customers
INNER JOIN orders ON customers.customerid = orders.customerid
WHERE orderid = 146760;
SELECT * FROM alerts;

UPDATE orders
SET status = NULL, orderdate = CAST('2021-10-24' AS DATE)
WHERE orderid = 146760;

SELECT * FROM orders WHERE orderid = 146760;

