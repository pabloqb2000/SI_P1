UPDATE orderdetail
SET price = products.price * quantity * (1 - 1./51*(EXTRACT(YEAR FROM CURRENT_DATE) - EXTRACT(YEAR FROM orders.orderdate)))
    -- Usamos 1/51 porque pasado un año el precio es el 102% del precio anterior
    -- Entonces 1/102*2 = 1/51, esto es mas exacto que usar 1/50
FROM products, orders
WHERE orderdetail.prod_id = products.prod_id AND orderdetail.orderid = orders.orderid;




 
