UPDATE orderdetail
SET price = products.price * (1 - 1./51*(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM orders.orderdate)))
    -- Usamos 1/51 porque pasado un año el precio es el 102% del precio anterior
    -- Entonces 1/102*2 = 1/51, esto es mas exacto que usar 1/50
FROM products, orders
WHERE orderdetail.prod_id = products.prod_id AND orderdetail.orderid = orders.orderid;

/*
-- Debug only 
SELECT quantity, EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM orderdate) AS yr, products.price, orderdetail.price AS newprice
FROM orderdetail
INNER JOIN orders
ON orders.orderid = orderdetail.orderid 
INNER JOIN products
ON orderdetail.prod_id = products.prod_id
ORDER BY price DESC, quantity DESC
LIMIT 10;
*/
