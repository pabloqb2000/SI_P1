CREATE OR REPLACE FUNCTION setOrderAmount() RETURNS void AS $$
    BEGIN
        UPDATE orders
        SET netamount = sum_price
        FROM (
            SELECT SUM(price) AS sum_price, orders.orderid AS orderid
            FROM orders
            LEFT JOIN orderdetail ON orders.orderid = orderdetail.orderid
            GROUP BY orders.orderid
        ) AS summed
        WHERE summed.orderid = orders.orderid;
    END
$$ LANGUAGE plpgsql;

SELECT setOrderAmount();