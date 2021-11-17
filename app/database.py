import sys, traceback
from sqlalchemy import create_engine
from sqlalchemy import Table, Column, Integer, String, MetaData, ForeignKey, text
from sqlalchemy.sql import select, and_

img_files = [
    "imgs/Orgazmo.jpg",
    "imgs/Ted.jpg",
    "imgs/AliG.jpg",
    "imgs/Shrek.jpg",
]

# configurar el motor de sqlalchemy
db_engine = create_engine("postgresql://alumnodb:alumnodb@localhost/si1", echo=False)
db_meta = MetaData(bind=db_engine)
# cargar tablas
imdb_movies         = Table('imdb_movies', db_meta, autoload=True, autoload_with=db_engine)
imdb_directormovies = Table('imdb_directormovies', db_meta, autoload=True, autoload_with=db_engine)
imdb_directors      = Table('imdb_directors', db_meta, autoload=True, autoload_with=db_engine)
imdb_actormovies    = Table('imdb_actormovies', db_meta, autoload=True, autoload_with=db_engine)
imdb_actors         = Table('imdb_actors', db_meta, autoload=True, autoload_with=db_engine)
imdb_moviegenres    = Table('imdb_moviegenres', db_meta, autoload=True, autoload_with=db_engine)
products            = Table('products', db_meta, autoload=True, autoload_with=db_engine)

def execute_query(query):
    try:
        # conexion a la base de datos
        db_conn = None
        db_conn = db_engine.connect()  

        db_result = db_conn.execute(query)
        db_conn.close()

        return list(db_result)
    except:
        if db_conn is not None:
            db_conn.close()
        
        print("Exception in DB access:")
        traceback.print_exc(file=sys.stderr)

        return None

def movieSearch(title, genre):
    title = f'%{title}%'
    if genre == 'All':
        q = select([imdb_movies]).where(imdb_movies.c.movietitle.ilike(title))
    else:
        q = select([imdb_movies]) \
            .join(imdb_moviegenres) \
            .where(and_(imdb_movies.c.movietitle.ilike(title), imdb_moviegenres.c.genre == genre))
    return movies_to_dict(execute_query(q))
        

def getListOfMovies(n=20):
    movies_q = select([imdb_movies]).limit(n)   
    movies = execute_query(movies_q)
    return movies_to_dict(movies)

def movies_to_dict(movies):
    movies_to_dict = []
    for movie in movies:
        movie_dict = {
            'id': movie[0],
            'titulo': movie[1],
            'poster': img_files[movie[0] % len(img_files)],
            "anno": int(movie[2]),
        }

        # Get price
        movie_dict['precio'] = float(execute_query(
            select([products.c.price]) \
                .join(imdb_movies) \
                .where(imdb_movies.c.movieid == movie[0]) \
                .limit(1)
        )[0][0])

        movies_to_dict.append(movie_dict)

    return movies_to_dict

def getGenres():
    genres = execute_query(select([imdb_moviegenres.c.genre]).distinct())
    return ['All'] + [g[0] for g in genres]

def getFilmById(film_id):
        movies_q = select([imdb_movies]).where(imdb_movies.c.movieid == film_id)   
        movies = execute_query(movies_q)
        if not movies:
            return None
        movie = movies[0]
        
        movie_dict = {
            'id': movie[0],
            'titulo': movie[1],
            'poster': img_files[movie[0] % len(img_files)],
            "anno": int(movie[2]),
        }

        # Get price
        movie_dict['precio'] = float(execute_query(
            select([products.c.price]) \
                .join(imdb_movies) \
                .where(imdb_movies.c.movieid == movie[0]) \
                .limit(1)
        )[0][0])

        # Get directors
        movie_dict['director'] = ' / '.join([d[0] for d in execute_query(
            select([imdb_directors.c.directorname]) \
                .select_from(imdb_directors)
                .join(imdb_directormovies) \
                .join(imdb_movies) \
                .where(imdb_movies.c.movieid == movie[0])
        )])

        # Get genres
        movie_dict['categoria'] = ' / '.join([g[0] for g in execute_query(
            select([imdb_moviegenres.c.genre]) \
                .select_from(imdb_moviegenres) \
                .join(imdb_movies) \
                .where(imdb_movies.c.movieid == movie[0])
        )])

        # Get actors
        actors = execute_query(
            select([imdb_actors.c.actorname, imdb_actormovies.c.character]) \
                .select_from(imdb_actors)
                .join(imdb_actormovies) \
                .join(imdb_movies) \
                .where(imdb_movies.c.movieid == film_id)
        )
        movie_dict['actores'] = [
            {'nombre': name, 'personaje': pers}
            for name, pers in actors[:5]
        ]

        return movie_dict
    

if __name__ == '__main__':
    for m in getFilmById(103):
        print(m)
