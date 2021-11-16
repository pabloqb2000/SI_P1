CREATE OR REPLACE FUNCTION updInventoryAndCustomer_trigger()
RETURNS trigger AS $$
BEGIN
    IF OLD.status IS NULL THEN
        -- Update orders
        NEW.orderdate := CURRENT_DATE;

        -- Update inventory
        UPDATE inventory
        SET 
            stock = stock - quantity,
            sales = sales + quantity
        FROM orderdetail
        WHERE orderdetail.prod_id = inventory.prod_id AND 
            orderdetail.orderid = NEW.orderid;

        -- Create alerts
        INSERT INTO alerts (prod_id) 
        SELECT inventory.prod_id
        FROM orderdetail 
        INNER JOIN orders    ON orders.orderid = orderdetail.orderid 
        INNER JOIN inventory ON orderdetail.prod_id = inventory.prod_id 
        WHERE orders.orderid = NEW.orderid AND stock <= 0;

        -- Update customers
        UPDATE customers
        SET
            balance = balance - NEW.totalamount,
            loyalty = loyalty + NEW.totalamount*5
        WHERE customers.customerid = NEW.customerid;

    END IF;
    RETURN NEW;
END;
$$
LANGUAGE 'plpgsql';

DROP TRIGGER IF EXISTS updInventoryAndCustomer ON orders;

CREATE TRIGGER updInventoryAndCustomer
BEFORE UPDATE OF status 
ON orders
FOR EACH ROW
EXECUTE PROCEDURE updInventoryAndCustomer_trigger();