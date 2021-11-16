ALTER TABLE customers
    DROP COLUMN IF EXISTS address2,
    DROP COLUMN IF EXISTS city,
    DROP COLUMN IF EXISTS state,
    DROP COLUMN IF EXISTS zip,
    DROP COLUMN IF EXISTS country,
    DROP COLUMN IF EXISTS region,
    DROP COLUMN IF EXISTS phone,
    DROP COLUMN IF EXISTS creditcardtype,
    DROP COLUMN IF EXISTS creditcardexpiration,
    DROP COLUMN IF EXISTS age,
    DROP COLUMN IF EXISTS income,
    DROP COLUMN IF EXISTS gender,
    ADD salt varchar(32),
    ADD loyalty int DEFAULT 0,
    ADD balance NUMERIC;


ALTER TABLE imdb_movies
    DROP COLUMN IF EXISTS movierelease,
    DROP COLUMN IF EXISTS movietype,
    DROP COLUMN IF EXISTS issuspended;

ALTER TABLE imdb_actors
    DROP COLUMN IF EXISTS gender;

ALTER TABLE imdb_actormovies
    DROP COLUMN IF EXISTS ascharacter,
    DROP COLUMN IF EXISTS isvoice,
    DROP COLUMN IF EXISTS isarchivefootage,
    DROP COLUMN IF EXISTS isuncredited,
    DROP COLUMN IF EXISTS creditsposition;

ALTER TABLE imdb_directormovies
    DROP COLUMN IF EXISTS ascharacter,
    DROP COLUMN IF EXISTS participation,
    DROP COLUMN IF EXISTS isarchivefootage,
    DROP COLUMN IF EXISTS isuncredited,
    DROP COLUMN IF EXISTS iscodirector,
    DROP COLUMN IF EXISTS ispilot,
    DROP COLUMN IF EXISTS ischief,
    DROP COLUMN IF EXISTS ishead;


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


CREATE TABLE moviegenres(
    genre VARCHAR(32) NOT NULL,
    PRIMARY KEY (genre)
);

INSERT INTO moviegenres(genre)
SELECT DISTINCT genre
FROM imdb_moviegenres;

ALTER TABLE imdb_moviegenres
    ADD CONSTRAINT genre FOREIGN KEY (genre) REFERENCES moviegenres(genre);


CREATE TABLE moviecountries(
    country VARCHAR(32) NOT NULL,
    PRIMARY KEY (country)
);

INSERT INTO moviecountries(country)
SELECT DISTINCT country
FROM imdb_moviecountries;

ALTER TABLE imdb_moviecountries
    ADD CONSTRAINT country FOREIGN KEY (country) REFERENCES moviecountries(country);


CREATE TABLE movielanguages(
    language VARCHAR(32) NOT NULL,
    PRIMARY KEY (language)
);

INSERT INTO movielanguages(language)
SELECT DISTINCT language
FROM imdb_movielanguages;

ALTER TABLE imdb_movielanguages
    ADD CONSTRAINT language FOREIGN KEY (language) REFERENCES movielanguages(language);


CREATE TABLE alerts (
    prod_id int,
    alert_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (prod_id) REFERENCES products(prod_id)
);


CREATE OR REPLACE FUNCTION setCustomersBalance(IN initialBalance bigint) RETURNS void AS $$
    BEGIN
        UPDATE customers
        SET balance = floor(random() * ($1 + 1))::bigint;
    END
$$ LANGUAGE plpgsql;

SELECT setCustomersBalance(100);
