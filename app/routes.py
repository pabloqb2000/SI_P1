#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from app import app
from flask import render_template, request, url_for, redirect, session, abort
import json
import os
import sys

@app.route('/')
@app.route('/index')
def index():
    catalogue_data = open(os.path.join(app.root_path,'catalogue/catalogue.json'), encoding="utf-8").read()
    catalogue = json.loads(catalogue_data)
    return render_template('index.html', title = "Home", films=catalogue['peliculas'])
    
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

@app.route('/register')
def regiter():
    return render_template('register.html', title='Register')

@app.route('/logout', methods=['GET', 'POST'])
def logout():
    session.pop('usuario', None)
    return redirect(url_for('index'))

@app.errorhandler(404)
def page_not_found(error):
   return render_template('404.html', title = '404'), 404
