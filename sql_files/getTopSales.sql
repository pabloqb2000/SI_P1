CREATE OR REPLACE FUNCTION getTopSales(
    year1 INT, year2 INT)
    RETURNS TABLE(year INT, Film VARCHAR, sales BIGINT) AS $$
    BEGIN
        RETURN QUERY
        SELECT yr::integer, title, quantity
        FROM(
            SELECT  yr, title, quantity, rank()
            OVER (
                PARTITION BY yr
                ORDER BY quantity DESC
            ) AS rk
            FROM (
                SELECT 
                    EXTRACT(YEAR FROM orders.orderdate) AS yr,
                    movietitle AS title, 
                    Sum(quantity) AS quantity
                FROM imdb_movies
                LEFT JOIN products ON imdb_movies.movieid = products.movieid
                LEFT JOIN orderdetail ON orderdetail.prod_id = products.prod_id
                LEFT JOIN orders ON orders.orderid = orderdetail.orderid
                WHERE EXTRACT(YEAR FROM orders.orderdate) BETWEEN year1 AND year2
                GROUP BY imdb_movies.movieid, 1
                ORDER BY 3 DESC
            ) AS T
        ) AS R
        WHERE rk = 1
        ORDER BY quantity DESC;
    END;
$$ LANGUAGE plpgsql;

SELECT * FROM getTopSales(2018, 2021);

            