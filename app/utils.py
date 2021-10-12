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
