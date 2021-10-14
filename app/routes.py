#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from app import app
from flask import render_template, request, url_for, redirect, session, abort, make_response
import json
import os
from os import path
import random
import sys
from app.utils import *

@app.route('/')
@app.route('/index')
def index():
    catalogue_data = open(os.path.join(app.root_path,'catalogue/catalogue.json'), encoding="utf-8").read()
    catalogue = json.loads(catalogue_data)
    films = catalogue['peliculas']
    categories = get_categories(films)

    values=None
    if request.args:
        films = filter_search(films, request.args)
        values = {
            'title': request.args.get('title'),
            'category': request.args.get('category').title(),
        }

    return render_template(
        'index.html',
        title = "Home", 
        films=films, 
        categories=categories, 
        values=values
    )
    
@app.route('/login', methods=['GET', 'POST'])
def login():
    if 'username' in request.form and request.form['username']:
        username = request.form['username']
        base_dir = path.join(app.root_path, 'usuarios', username)

        if os.path.isdir(base_dir):
            user_data = json.load(open(path.join(base_dir, 'datos.dat')))
            password_hash = hash_password(user_data['salt'], request.form['password'])

            if user_data['username'] == username and \
               user_data['password'] == password_hash:
                last_url = session['last_url']
                session['last_url'] = ''
                session['user'] = username
                session.modified = True

                resp = make_response(redirect(last_url))
                resp.set_cookie('username', username)
                return resp
            else:
                return render_template(
                    'login.html', 
                    error_msg=f"Invalid password for {username}",
                    user=request.cookies.get('username')
                )
        else:
            return render_template(
                'login.html', 
                error_msg="User is not registered",
                user=request.cookies.get('username')
            )
    else:
        if not session['last_url']:
            session['last_url'] = request.referrer
            session.modified = True
        return render_template('login.html', user=request.cookies.get('username'))

@app.route('/add-to-cart', methods=['POST'])
def add_to_cart():
    if 'film-id' in request.form:
        if 'films' in session:
            session['films'].append(request.form['film-id'])
            session.modified = True
        else:
            session['films'] = [request.form['film-id']]
            session.modified = True
        return redirect(url_for('cart'))
    else:
        return redirect(request.referrer)

@app.route('/remove-from-cart', methods=['POST'])
def remove_from_cart():
    if 'film-index' in request.form and \
       'films' in session and \
       request.form['film-index'].isdigit() and \
       len(session['films']) > int(request.form['film-index']):

        session['films'].pop(int(request.form['film-index']))
        session.modified = True
        return redirect(url_for('cart'))
    else:
        return redirect(request.referrer)

@app.route('/history')
def history():
    if 'user' in session:        
        user_data = json.load(open(path.join(app.root_path, 'usuarios', session['user'], 'datos.dat')))

        return render_template('history.html', user=user_data)
    else:
        session['last_url'] = url_for('history')
        session.modified = True
        return render_template('login.html', error_msg="You need to be logged in to access this page!", user=request.cookies.get('username'))

@app.route('/cart')
def cart():
    catalogue_data = open(os.path.join(app.root_path,'catalogue/catalogue.json'), encoding="utf-8").read()
    catalogue = json.loads(catalogue_data)
    films_by_id = {str(film['id']): film for film in catalogue['peliculas']}

    if 'films' in session:
        films = [films_by_id[film_id] for film_id in session['films']]
    else:
        films = []

    total = round(sum([film['precio'] for film in films]), 2)
    return render_template(
        'cart.html',
        title = "Cart", 
        any_film=len(films)>0, 
        films_in_chart=films, 
        total=total
    )

@app.route('/film/<int:film_id>')
def film(film_id):
    catalogue_data = open(os.path.join(app.root_path,'catalogue/catalogue.json'), encoding="utf-8").read()
    catalogue = json.loads(catalogue_data)

    film = None
    for f in catalogue['peliculas']:
        print(type(f['id']), type(film_id))
        if f['id'] == film_id:
            film = f
            print(film)
            break
    
    if not film:
        abort(404)

    return render_template('film.html', film=film)

@app.route('/register', methods=['GET'])
def register():
    user_data = {
        'email': '',
        'username': '',
        'creditcard': '',
        'direction': '',
    }
    return render_template('register.html', values=user_data)

@app.route('/register', methods=['POST'])
def register_post():
    # Get information from request
    email = request.form.get('email')
    username = request.form.get('username')
    password = request.form.get('password')
    confirmation = request.form.get('confirmation')
    creditcard = request.form.get('creditcard')
    direction = request.form.get('direction')

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
    }
    validation_msg = validate_user_registration_data(email, username, password, confirmation, creditcard, direction)
    if validation_msg:
        return render_template('register.html', error_msg=validation_msg, values=user_data)

    # Check if username already exists
    base_dir = path.join(app.root_path, 'usuarios')
    other_users = [
        name for name in os.listdir(base_dir) 
        if path.isdir(os.path.join(base_dir, name))
    ]
    if username in other_users:
        return render_template('register.html', error_msg='Username is already in use!', values=user_data)
        return redirect(url_for('index'))

    # Create a new user file
    user_dir = path.join(base_dir, username)
    os.mkdir(user_dir)
    with open(path.join(user_dir, 'datos.dat'), 'w', encoding='utf-8') as f:
        json.dump(user_data, f, ensure_ascii=False, indent=4)

    return redirect(url_for('login'))

@app.route('/logout', methods=['GET', 'POST'])
def logout():
    session.pop('user', None)
    session.pop('films', None)
    return redirect(url_for('index'))

@app.route('/random_number', methods=['GET', 'POST'])
def random_number():
    return random.randint(0, 100)

@app.errorhandler(404)
def page_not_found(error):
   return render_template('404.html'), 404
