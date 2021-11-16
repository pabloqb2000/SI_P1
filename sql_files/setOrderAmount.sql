CREATE OR REPLACE FUNCTION setOrderAmount() RETURNS void AS $$
    BEGIN
        UPDATE orders
        SET netamount = sum_price
        FROM (
            SELECT SUM(price * quantity) AS sum_price, orders.orderid AS orderid
            FROM orders
            INNER JOIN orderdetail ON orders.orderid = orderdetail.orderid
            GROUP BY orders.orderid
        ) AS summed
        WHERE summed.orderid = orders.orderid;
        UPDATE orders
        SET totalamount = netamount * (1 + tax/100);
    END
$$ LANGUAGE plpgsql;

SELECT setOrderAmount();