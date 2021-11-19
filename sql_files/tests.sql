-- Test setCustomersBalance
SELECT
    MIN(balance) AS min_balance,
    MAX(balance) AS max_balance,
    AVG(balance) AS avg_balance
FROM customers;

-- Test setPrice
SELECT 
    orderdetail.price AS order_price,
    EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM orders.orderdate) AS year_diff,
    products.price AS product_price
FROM orderdetail
INNER JOIN products ON orderdetail.prod_id = products.prod_id
INNER JOIN orders   ON orderdetail.orderid = orders.orderid
LIMIT 5;

-- Test setOrderAmount
SELECT netamount, tax, totalamount, sum(price * quantity) as suma_precios
FROM orders
INNER JOIN orderdetail ON orderdetail.orderid = orders.orderid
GROUP BY orders.orderid
LIMIT 5;

-- Test getTopSales
SELECT * FROM getTopSales(2015, 2021);

-- Test getTopActors
SELECT * FROM getTopActors('Drama') LIMIT 5;

-- Test updOrders
SELECT orderid, netamount, tax, totalamount 
FROM orders WHERE orderid = 151582;                                  -- Show orders
SELECT * FROM orderdetail WHERE prod_id = 4432 AND orderid = 151582; -- Show orderdetail

UPDATE orderdetail
SET quantity = 3
WHERE prod_id = 4432 AND orderid = 151582;   -- Change row
SELECT orderid, netamount, tax, totalamount 
FROM orders WHERE orderid = 151582;          -- Show orders

UPDATE orderdetail
SET quantity = 1
WHERE prod_id = 4432 AND orderid = 151582;   -- Restore row
SELECT orderid, netamount, tax, totalamount 
FROM orders WHERE orderid = 151582;          -- Show orders

DELETE FROM orderdetail  WHERE prod_id = 4432 AND orderid = 151582; -- Delete row
SELECT orderid, netamount, tax, totalamount 
FROM orders WHERE orderid = 151582;                                 -- Show orders

INSERT INTO orderdetail  VALUES                                     
    (151582, 4432, 12.3529411764706, 1);     -- Restore row
SELECT orderid, netamount, tax, totalamount 
FROM orders WHERE orderid = 151582;          -- Show orders

-- Test updInventoryAndCustomer
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


 orderid | customerid | netamount | tax |  totalamount  | status 
---------+------------+-----------+-----+---------------+--------
  146760 |      11387 |     622.8 |  21 | 753.588000000 | 

orderdetails + inventory:
 orderid | prod_id | price | quantity | prod_id | stock | sales 
---------+---------+-------+----------+---------+-------+-------
  146760 |    4416 |  13.2 |        1 |    4416 |   910 |   149
  146760 |    2486 |    19 |        1 |    2486 |   864 |   162
  146760 |    6567 |    18 |        1 |    6567 |   221 |   151
  146760 |    2272 |    16 |        1 |    2272 |   466 |   180
  146760 |    5585 |  14.4 |        1 |    5585 |   962 |   172
  146760 |    2574 |    13 |        1 |    2574 |   922 |   176
  146760 |    3053 |  20.4 |        1 |    3053 |   581 |   168
  146760 |     936 |  21.6 |        1 |     936 |   294 |   163
  146760 |    5118 |  19.2 |        1 |         |       |      
  146760 |    3758 |  15.6 |       30 |    3758 |    22 |   159

customer with customerid = 11387:
 firstname | balance | loyalty 
-----------+---------+---------
 janell    |      68 |       0

alerts:
 prod_id | alert_date 
---------+------------
(0 filas)

orders:
 orderid | customerid | netamount | tax |  totalamount  | status 
---------+------------+-----------+-----+---------------+--------
  146760 |      11387 |     622.8 |  21 | 753.588000000 | Paid

orderdetails + inventory:
 orderid | prod_id | price | quantity | prod_id | stock | sales 
---------+---------+-------+----------+---------+-------+-------
  146760 |    4416 |  13.2 |        1 |    4416 |   909 |   150
  146760 |    3758 |  15.6 |       30 |    3758 |    -8 |   189
  146760 |    2486 |    19 |        1 |    2486 |   863 |   163
  146760 |    6567 |    18 |        1 |    6567 |   220 |   152
  146760 |    2272 |    16 |        1 |    2272 |   465 |   181
  146760 |    5585 |  14.4 |        1 |    5585 |   961 |   173
  146760 |    2574 |    13 |        1 |    2574 |   921 |   177
  146760 |    3053 |  20.4 |        1 |    3053 |   580 |   169
  146760 |     936 |  21.6 |        1 |     936 |   293 |   164
  146760 |    5118 |  19.2 |        1 |         |       |      

customer with customerid = 11387:
 firstname |          balance           | loyalty 
-----------+----------------------------+---------
 janell    | -685.588000000000000000000 |    3768

alerts:
 prod_id |          alert_date           
---------+-------------------------------
    3758 | 2021-11-19 11:46:33.212353+01
