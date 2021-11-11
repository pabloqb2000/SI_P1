ALTER TABLE customers
    DROP COLUMN address2,
    DROP COLUMN city,
    DROP COLUMN state,
    DROP COLUMN zip,
    DROP COLUMN country,
    DROP COLUMN region,
    DROP COLUMN phone,
    DROP COLUMN creditcardtype,
    DROP COLUMN creditcardexpiration,
    DROP COLUMN age,
    DROP COLUMN income,
    DROP COLUMN gender,
    ADD salt varchar(32),
    ADD loyalty int DEFAULT 0,
    ADD balance bigint;

DROP TABLE imdb_movielanguages;
DROP TABLE imdb_moviecountries;

ALTER TABLE imdb_movies
    DROP COLUMN movierelease,
    DROP COLUMN movietype,
    DROP COLUMN issuspended;

ALTER TABLE imdb_actors
    DROP COLUMN gender;

ALTER TABLE imdb_actormovies
    DROP COLUMN ascharacter,
    DROP COLUMN isvoice,
    DROP COLUMN isarchivefootage,
    DROP COLUMN isuncredited,
    DROP COLUMN creditsposition;

ALTER TABLE imdb_directormovies
    DROP COLUMN ascharacter,
    DROP COLUMN participation,
    DROP COLUMN isarchivefootage,
    DROP COLUMN isuncredited,
    DROP COLUMN iscodirector,
    DROP COLUMN ispilot,
    DROP COLUMN ischief,
    DROP COLUMN ishead;

ALTER TABLE inventory
    ADD CONSTRAINT prod_id FOREIGN KEY (prod_id) REFERENCES products(prod_id);

ALTER TABLE orderdetail
    ADD CONSTRAINT prod_id FOREIGN KEY (prod_id) REFERENCES products(prod_id),
    ADD CONSTRAINT orderid FOREIGN KEY (orderid) REFERENCES orders(orderid);

ALTER TABLE orders
    ADD CONSTRAINT customerid FOREIGN KEY (customerid) REFERENCES customers(customerid); 

ALTER TABLE imdb_actormovies
    ADD CONSTRAINT movieid FOREIGN KEY (movieid) REFERENCES imdb_movies(movieid),
    ADD CONSTRAINT actorid FOREIGN KEY (actorid) REFERENCES imdb_actors(actorid);

CREATE TABLE alerts (
    prod_id int,
    alert_date timestamp,
    FOREIGN KEY (prod_id) REFERENCES products(prod_id)
);

CREATE OR REPLACE FUNCTION setCustomersBalance(IN initialBalance bigint) RETURNS SETOF customers AS $$
    DECLARE
        r customers%rowtype;
    BEGIN
    FOR r IN
        SELECT * FROM customers
    LOOP
        r.balance = random()*($1 + 1);
        RETURN NEXT r; -- return current row of SELECT
    END LOOP;
    RETURN;
END

$$ LANGUAGE plpgsql;

SELECT * FROM setCustomersBalance(100);

CREATE OR REPLACE FUNCTION setOrderAmount() RETURNS VOID AS $$$$
    DECLARE
        o orders%rowtype;
        od orderdetail%rowtype;
        p products%rowtype;
        suma numeric := 0;
        sum_impuestos numeric := 0;
    BEGIN
    FOR o IN
        SELECT * FROM orders
    LOOP
        FOR od IN 
            SELECT * from orderdetail
        LOOP
            sum_impuestos = sum_impuestos + orderdetail.price
            RETURN NEXT od;
        END LOOP;
        FOR p IN 
            SELECT * from products
        LOOP
            suma = suma + orderdetail.price
            RETURN NEXT od;
        END LOOP;
        o.netamount = suma
        o.totalamount = sum_impuestos
        RETURN NEXT o; -- return current row of SELECT
    END LOOP;
    RETURN;
END

 LANGUAGE plpgsql;
