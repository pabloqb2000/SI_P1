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
    ADD salt varchar(32);

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


    




