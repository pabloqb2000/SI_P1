
UPDATE orders
SET netamount = sum(price)
FROM  orderdetail
WHERE orderdetail.orderid = orders.orderid AND
      netamount IS NULL
GROUP BY orderdetail.orderid;


-- Debug only 
SELECT netamount
FROM orders
LIMIT 10;
