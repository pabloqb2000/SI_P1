
UPDATE od
SET price = 
    -- Usamos 1/51 porque pasado un año el precio es el 102% del precio anterior
    -- Entonces 1/102*2 = 1/51, esto es mas exacto que usar 1/50
    products.price * quantity * (1 - 1./51*(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM orderdate)))

FROM  products, orders, orderdetail AS od
WHERE orderdetail.prod_id = products.prod_id AND
      orderdetail.orderid = orders.orderid;

/* 
-- Debug only 
SELECT quantity, EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM orderdate) AS yr, products.price, orderdetail.price AS newprice
FROM orderdetail
LEFT JOIN orders
ON orders.orderid = orderdetail.orderid 
LEFT JOIN products
ON orderdetail.prod_id = products.prod_id
ORDER BY price DESC, quantity DESC
LIMIT 10;
*/
