CREATE OR REPLACE FUNCTION getTopActors(genre CHAR)
    RETURNS TABLE(Actor VARCHAR, Num INT, Debut INT,
                  Film VARCHAR,  Director VARCHAR) AS $$
    BEGIN
        RETURN QUERY
        SELECT 
            actorname,
            CAST(T1.num AS INT),
            CAST(year AS INT),
            movietitle,
            directorname
        FROM (
            SELECT Count(*) AS Num, imdb_actors.actorid
            FROM imdb_actors
            INNER JOIN imdb_actormovies ON imdb_actors.actorid      = imdb_actormovies.actorid
            INNER JOIN imdb_movies      ON imdb_actormovies.movieid = imdb_movies.movieid
            INNER JOIN imdb_moviegenres ON imdb_moviegenres.movieid = imdb_movies.movieid
            WHERE imdb_moviegenres.genre=$1
            GROUP BY imdb_actors.actorid
            HAVING Count(*) > 4
        ) AS T1
        INNER JOIN (
            SELECT actorname, movietitle, imdb_actors.actorid, imdb_movies.movieid, year, rank()
            OVER (
                PARTITION BY imdb_actors.actorid
                ORDER BY year ASC
            ) AS rk
            FROM imdb_actors
            INNER JOIN imdb_actormovies ON imdb_actors.actorid = imdb_actormovies.actorid
            INNER JOIN imdb_movies ON imdb_actormovies.movieid = imdb_movies.movieid
            INNER JOIN imdb_moviegenres ON imdb_moviegenres.movieid = imdb_movies.movieid
            WHERE imdb_moviegenres.genre=$1
        ) AS T2
        ON T1.actorid = T2.actorid
        INNER JOIN imdb_directormovies ON imdb_directormovies.movieid    = T2.movieid
        INNER JOIN imdb_directors      ON imdb_directormovies.directorid = imdb_directors.directorid
        WHERE rk=1
        ORDER BY Num DESC;
    END;
$$ LANGUAGE plpgsql;

-- SELECT * FROM getTopActors('Drama') LIMIT 20;