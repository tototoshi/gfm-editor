# coding: utf-8
import os
from flask import Flask
from flask import request
from flask import render_template
from flask import g
from flask import redirect
from flask import flash
from flask import url_for
from flask import request
from flask import jsonify
from flask import Response
from sqlalchemy import create_engine
from markdown import markdown
from bs4 import BeautifulSoup
from sqlalchemy.sql import text
import json

app = Flask(__name__)


def remove_script_tag(html):
    soup = BeautifulSoup(html)
    to_extract = soup.findAll('script')
    for item in to_extract:
        item.extract()
    return unicode(soup)

def list_notes():
    return g.db.execute('select * from note').fetchall()

@app.before_request
def connect_db():
    g.db = create_engine('postgresql://localhost/gfmeditor')

@app.route('/')
def index():
    return render_template('index.html', notes=list_notes())

@app.route('/<int:note_id>')
def view(note_id):
    note_id = int(note_id)
    q = text('SELECT * FROM note WHERE id = :note_id')
    row = g.db.execute(q, note_id=note_id).fetchone()
    if row is None:
        return redirect(url_for('index'))
    return render_template('view.html', note_id=note_id, raw=row['raw'], notes=list_notes())

@app.route('/api/notes')
def api_list_notes():
    notes = []
    for note in list_notes():
        notes.append({'id': note['id'], 'title': note['title'], 'raw': note['raw']})
    return Response(json.dumps(notes),  mimetype='application/json')

@app.route('/api/note/<int:note_id>')
def get_note_by_id(note_id):
    q = text('SELECT * FROM note WHERE id = :note_id')
    row = g.db.execute(q, note_id=note_id).fetchone()
    return jsonify(row)

@app.route('/api/render', methods=['POST'])
def render():
    raw = request.form['raw']
    html = markdown(raw, extensions=['gfm'])
    html = remove_script_tag(html)
    return html

@app.route('/api/note/<int:note_id>', methods=['DELETE'])
def api_delete(note_id):
    q = text('DELETE FROM note WHERE id = :note_id')
    g.db.execute(q, note_id=note_id)
    return jsonify({'id': note_id})

@app.route('/api/note', methods=['POST'])
def api_create():
    raw = request.json.get('raw')
    title = request.json.get('title').strip()
    if title == '':
        return '', 400
    q = text('INSERT INTO note (title, raw) VALUES (:title, :raw) RETURNING *')
    row = g.db.execute(q, title=title, raw=raw).fetchone()
    return jsonify(row)

@app.route('/api/note/<int:note_id>', methods=['PUT'])
def save(note_id):
    note_id = request.json.get('id')
    raw = request.json.get('raw')
    title = request.json.get('title').strip()
    if title == '':
        return ''
    note_id = int(note_id)
    q = text("""UPDATE note set title = :title,
        raw = :raw WHERE id = :note_id""")
    g.db.execute(q, title=title, raw=raw, note_id=note_id)
    return jsonify({'id': note_id, 'title': title, 'raw': raw})


if __name__ == '__main__':
    app.config.update({'DEBUG': True })
    app.run(use_reloader=False)
