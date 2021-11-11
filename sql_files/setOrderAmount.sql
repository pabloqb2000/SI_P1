CREATE OR REPLACE FUNCTION setOrderAmount() RETURNS VOID AS $$
    DECLARE
        o orders%rowtype;
        od orderdetail%rowtype;
        p products%rowtype;
        suma numeric := 0;
        sum_impuestos numeric := 0;
        i numeric := 0;
        j numeric := 0;
    BEGIN
    FOR o IN
        SELECT * FROM orders
    LOOP
        i = 0;
        FOR od IN 
            SELECT * from orderdetail where o.orderid = orderdetail.orderid
        LOOP
            raise notice 'orderid: %', od.orderid;
            i = i + 1;
            sum_impuestos = sum_impuestos + od.price;
            FOR p IN 
                SELECT * FROM products as pr WHERE od.prod_id = pr.prod_id
            LOOP
                suma = suma + p.price;
            END LOOP;
        END LOOP;
        j = j + 1;
        --raise notice 'Value_i: %', i;
        --raise notice 'Value_j: %', o.orderid;
        o.netamount = suma;
        o.totalamount = sum_impuestos;
    END LOOP;
    RETURN;
END

$$ LANGUAGE plpgsql;

DO $$ BEGIN
    PERFORM setOrderAmount();
END $$;