#!/usr/bin/env python3
# -- coding: utf-8 --

from app import app
from flask import render_template, request, url_for, redirect, session, abort, make_response
import json
import os
from os import path
import random
import app.database as db
from app.utils import *
import datetime
from collections import Counter

@app.route('/')
@app.route('/index')
def index():
    if request.args:
        films = db.movieSearch(
            request.args.get('title'),
            request.args.get('category')
        )
        
        values = {
            'title': request.args.get('title'),
            'category': request.args.get('category').title(),
            'genre': request.args.get('genre'),
            'actors': request.args.get('actors')
        }
        actors = db.getActors(
            request.args.get('actors'),
            request.args.get('genre')
        )
        print(actors)
    else:
        films = db.getListOfMovies()
        values = {
            'title': '',
            'category': 'All',
            'genre': 'Action',
            'actors': '5'
        }
        actors = None

    categories = db.getGenres()

    return render_template(
        'index.html', logged='user' in session,
        title = "Home", 
        films=films, 
        categories=categories, 
        values=values,
        actors=actors
    )
    
@app.route('/login', methods=['GET', 'POST'])
def login():
    if 'username' in request.values and request.values['username']:
        username = request.values['username']

        if db.userExists(username):
            user_data = db.getUserData(username)
            password_hash = hash_password(user_data['salt'], request.values['password'])

            if user_data['username'] == username and \
               user_data['password'] == password_hash:
                if 'last_url' in session and session['last_url'] and session['last_url'] != url_for('login'):
                    last_url = session['last_url']
                else:
                    last_url = url_for('index')
                session['last_url'] = ''
                if not 'films' in session or not session['films']:
                    delete_user_data(session)
                    if 'user_cart' in session and username in session['user_cart']:
                        session['films'] = session['user_cart'][username]
                session['user'] = username
                session.modified = True

                resp = make_response(redirect(last_url))
                resp.set_cookie('username', username)
                return resp
            else:
                return render_template(
                    'login.html', logged='user' in session, 
                    error_msg=f"Invalid password for {username}",
                    user=request.cookies.get('username')
                )
        else:
            return render_template(
                'login.html', logged='user' in session, 
                error_msg="User is not registered",
                user=request.cookies.get('username')
            )
    else:
        if request.referrer != url_for('login'):
            session['last_url'] = request.referrer
            session.modified = True
        return render_template('login.html', logged='user' in session, user=request.cookies.get('username'))

@app.route('/add-to-cart', methods=['POST'])
def add_to_cart():
    if 'film-id' in request.values:
        if 'films' in session:
            session['films'].append(request.values['film-id'])
            session.modified = True
        else:
            session['films'] = [request.values['film-id']]
            session.modified = True
        return redirect(url_for('cart'))
    else:
        return redirect(request.referrer)

@app.route('/remove-from-cart', methods=['POST'])
def remove_from_cart():
    if 'filmid' in request.values and \
       'films' in session and \
       request.values['filmid'] in session['films']:

        session['films'].remove(request.values['filmid'])
        session.modified = True
        return redirect(url_for('cart'))
    else:
        return redirect(request.referrer)

@app.route('/history')
def history():
    if 'user' in session:        
        user_data = db.getUserData(session['user'])
        history = [] #TODO: get this from db

        return render_template('history.html', logged='user' in session, user=user_data, films_bought=history[::-1], any_film=len(history)>0)
    else:
        session['last_url'] = url_for('history')
        session.modified = True
        return render_template('login.html', logged='user' in session, error_msg="You need to be logged in to access this page!", user=request.cookies.get('username'))

@app.route('/cart')
def cart():
    catalogue_data = open(os.path.join(app.root_path,'catalogue/catalogue.json'), encoding="utf-8").read()
    catalogue = json.loads(catalogue_data)
    films_by_id = {str(film['id']): film for film in catalogue['peliculas']}

    if 'films' in session:
        id_counts = Counter(session['films'])
        films = [films_by_id[film_id] for film_id in id_counts]
        for film in films:
            film['amount'] = id_counts[str(film['id'])]
    else:
        films = []


    total = round(sum([film['precio']*film['amount'] for film in films]), 2)
    return render_template(
        'cart.html', logged='user' in session,
        title = "Cart", 
        any_film=len(films)>0, 
        films_in_chart=films, 
        total=total
    )

@app.route('/film/<int:film_id>')
def film(film_id):
    film = db.getFilmById(film_id)
    
    if not film:
        abort(404)

    return render_template('film.html', logged='user' in session, film=film)

@app.route('/register', methods=['GET'])
def register():
    user_data = {
        'email': '',
        'username': '',
        'creditcard': '',
        'direction': '',
    }
    return render_template('register.html', logged='user' in session, values=user_data)

@app.route('/register', methods=['POST'])
def register_post():
    # Get information from request
    email = request.values.get('email')
    username = request.values.get('username')
    password = request.values.get('password')
    confirmation = request.values.get('confirmation')
    creditcard = request.values.get('creditcard')
    direction = request.values.get('direction')

    # Encode password and generate salt
    salt, password_hash = generate_salt_and_pwd(password)

    # Validate user data
    user_data = {
        'email': email,
        'username': username,
        'password': password_hash,
        'creditcard': creditcard,
        'direction': direction,
        'salt': salt,
        'balance': random.randint(0, 100),
        'points': 0,
    }
    validation_msg = validate_user_registration_data(email, username, password, confirmation, creditcard, direction)
    if validation_msg:
        return render_template('register.html', logged='user' in session, error_msg=validation_msg, values=user_data)

    # Check if username already exists
    user_exists = db.userExists(username)
    if user_exists:
        return render_template('register.html', logged='user' in session, error_msg='Username is already in use!', values=user_data)

    # Save user data
    db.registerUser(user_data)

    return render_template('login.html', logged='user' in session, user=username)

@app.route('/buy/<pay_method>', methods=['GET', 'POST'])
def buy(pay_method):
    if 'user' in session:
        if 'films' in session and pay_method in ['money', 'points']:
            # Read history
            with open(path.join(app.root_path, 'usuarios', session['user'], 'historial.json')) as f:
                history = json.load(f)

            # Read user data
            with open(path.join(app.root_path, 'usuarios', session['user'], 'datos.dat')) as f:
                user_data = json.load(f)
            
            # Read films
            catalogue_data = open(os.path.join(app.root_path,'catalogue/catalogue.json'), encoding="utf-8").read()
            catalogue = json.loads(catalogue_data)
            films_by_id = {str(film['id']): film for film in catalogue['peliculas']}
            id_counts = Counter(session['films'])
            films_to_buy = [films_by_id[film_id] for film_id in id_counts]
            for film in films_to_buy:
                film['amount'] = id_counts[str(film['id'])]

            # Check if user has enough money
            total = round(sum([film['precio']*film['amount'] for film in films_to_buy]), 2)
            if pay_method == 'money' and user_data['balance'] >= total:
                # Substract money and add points
                user_data['balance'] = round(user_data['balance']-total, 2)
                user_data['points'] += int(round(total*5, 0))

            elif pay_method == 'points' and user_data['points']/100 >= total:
                # Substract points
                user_data['points'] = int(round(user_data['points']/100 - total))

            else:
                return render_template(
                    'cart.html', logged='user' in session,
                    title = "Cart", 
                    any_film=len(films_to_buy)>0, 
                    films_in_chart=films_to_buy, 
                    total=total,
                    error_msg=f'Not enough {pay_method}!',
                )
            
            if 'user_cart' in session and session['user'] and session['user'] in session['user_cart']:
                session['user_cart'][session['user']] = []
                session.modified = True

            # Save user data
            with open(path.join(app.root_path, 'usuarios', session['user'], 'datos.dat'), 'w') as f:
                json.dump(user_data, f, ensure_ascii=False, indent=4)

            # Add films to history
            for film in films_to_buy:
                film['date'] = str(datetime.date.today())
            history += films_to_buy
            with open(path.join(app.root_path, 'usuarios', session['user'], 'historial.json'), 'w') as f:
                json.dump(history, f, ensure_ascii=False, indent=4)
            session['films'] = []
            session.modified = True
            
        return redirect(url_for('cart'))
    else:
        return render_template('login.html', logged='user' in session, error_msg='You need to be logged in to buy films!', user=request.cookies.get('username'))

@app.route('/add_money', methods=['GET', 'POST'])
def add_money():
    if 'user' in session:
        db.addMoneyUser(session['user'], 100)
    return redirect(url_for('history'))

@app.route('/logout', methods=['GET', 'POST'])
def logout():
    delete_user_data(session)

    return redirect(url_for('index'))

@app.route('/random_number', methods=['GET', 'POST'])
def random_number():
    return str(random.randint(0, 100))

@app.errorhandler(404)
def page_not_found(error):
   return render_template('404.html', logged='user' in session), 404

def delete_user_data(session):
    if 'user' in session and 'films' in session and session['films']:
        if 'user_cart' in session:
            session['user_cart']['user'] = session['films']
        else:
            session['user_cart'] = {session['user']: session['films']}
        session.modified = True
    
    session.pop('user', None)
    session.pop('films', None)
