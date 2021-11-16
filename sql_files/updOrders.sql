CREATE OR REPLACE FUNCTION updOrders_trigger()
  RETURNS trigger AS
$$
BEGIN
    IF TG_OP = 'DELETE' THEN      -- use reference to old
        UPDATE orders
        SET netamount = sum_price
        FROM (
            SELECT SUM(price * quantity) AS sum_price, orders.orderid AS orderid
            FROM orders
            LEFT JOIN orderdetail ON orders.orderid = orderdetail.orderid
            GROUP BY orders.orderid
        ) AS summed
        WHERE orders.orderid = old.orderid AND 
            summed.orderid = orders.orderid;

        UPDATE orders
        SET totalamount = netamount * (1 + tax/100)
        WHERE orders.orderid = old.orderid;

        RETURN OLD;
    
    ELSE                        -- use reference to new
        UPDATE orders
        SET netamount = sum_price
        FROM (
            SELECT SUM(price * quantity) AS sum_price, orders.orderid AS orderid
            FROM orders
            LEFT JOIN orderdetail ON orders.orderid = orderdetail.orderid
            GROUP BY orders.orderid
        ) AS summed
        WHERE orders.orderid = new.orderid AND 
            summed.orderid = orders.orderid;

        UPDATE orders
        SET totalamount = netamount * (1 + tax/100)
        WHERE orders.orderid = new.orderid;
    
        RETURN NEW;
    END IF;
END;
$$
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS updOrders ON orderdetail;

CREATE TRIGGER updOrders
AFTER UPDATE OR INSERT OR DELETE
ON orderdetail
FOR EACH ROW
EXECUTE PROCEDURE updOrders_trigger();