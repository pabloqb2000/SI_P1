#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from app import app
from flask import render_template, request, url_for, redirect, session, abort
import json
import os
from os import path
import hashlib
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

    return render_template('index.html', title = "Home", films=films, categories=categories, values=values)
    
@app.route('/login', methods=['GET', 'POST'])
def login():
    return render_template('login.html', title='Login')

@app.route('/history')
def history():
    return render_template('history.html', title='History')

@app.route('/cart')
def cart():
    catalogue_data = open(os.path.join(app.root_path,'catalogue/catalogue.json'), encoding="utf-8").read()
    catalogue = json.loads(catalogue_data)
    films = catalogue['peliculas']*3
    total = sum([film['precio'] for film in films])
    return render_template('cart.html', title = "Cart", films_in_chart=films, total=total)

@app.route('/film/<int:film_id>')
def film(film_id):
    
    print("ID:  ", film_id)
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

    return render_template('film.html', title=film['titulo'], film=film)

@app.route('/register', methods=['GET'])
def regiter():
    user_data = {
        'email': '',
        'username': '',
        'creditcard': '',
        'direction': '',
    }
    return render_template('register.html', title='Register', values=user_data)

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
    ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
    chars=[]
    for i in range(16):
        chars.append(random.choice(ALPHABET))

    salt = "".join([
        random.choice("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        for _ in range(16)
    ])
    password_hash = hashlib.blake2b((salt+password).encode('utf-8')).hexdigest()

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
        return render_template('register.html', title='Register', error_msg=validation_msg, values=user_data)

    # Check if username already exists
    base_dir = path.join(path.dirname(path.abspath(__file__)), 'usuarios')
    other_users = [
        name for name in os.listdir(base_dir) 
        if path.isdir(os.path.join(base_dir, name))
    ]
    if username in other_users:
        return render_template('register.html', title='Register', error_msg='Username is already in use!', values=user_data)
        return redirect(url_for('index'))

    # Create a new user file
    user_dir = path.join(base_dir, username)
    os.mkdir(user_dir)
    with open(path.join(user_dir, 'datos.dat'), 'w', encoding='utf-8') as f:
        json.dump(user_data, f, ensure_ascii=False, indent=4)

    return redirect(url_for('login'))

@app.route('/logout', methods=['GET', 'POST'])
def logout():
    session.pop('usuario', None)
    return redirect(url_for('index'))

@app.errorhandler(404)
def page_not_found(error):
   return render_template('404.html', title = '404'), 404
