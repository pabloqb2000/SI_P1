import re

def validate_user_registration_data(email, username, password, confirmation, creditcard, direction):
    if not email or \
       not username or \
       not password or \
       not confirmation or \
       not creditcard or \
       not direction:
        return "Empty field"
    
    if len(username) < 6 or \
       any(not c.isalnum() for c in username):
        return "Invalid username"
    
    if not re.compile(r'(\w|\-|\.)+\@(\w|\-|\.)+\.(\w|\-|\.)+').match(email):
        return "Invalid email"

    if len(password) < 8:
        return "Invalid password"
    
    if password != confirmation:
        return "Password doesn't match confirmation password"
    
    if not re.compile(r'(\d\-?){16}').match(creditcard):
        return "Invalid creditcard"

    if len(direction) > 50:
        return "Invalid direction"

    return ""

def filter_search(films, args):
    title = args.get('title')

    films_filtered = [
        film for film in films
        if title in film['titulo'].lower()
    ]
    if args.get('category') != 'All':
        films_filtered = [
            film for film in films_filtered
            if film['categoria'] == args.get('category')
        ]

    return films_filtered

def get_categories(films):
    categories_set = {film['categoria'] for film in films}
    return ['All'] + list(categories_set)
