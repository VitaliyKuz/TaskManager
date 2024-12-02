import os
from flask import Flask, render_template, request, redirect, url_for
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from sqlalchemy.exc import ProgrammingError

app = Flask(__name__)

db_user = os.environ.get('POSTGRES_USER', 'user')
db_password = os.environ.get('POSTGRES_PASSWORD', 'password')
db_host = os.environ.get('POSTGRES_HOST', 'db')
db_name = os.environ.get('POSTGRES_DB', 'task_manager')

app.config['SQLALCHEMY_DATABASE_URI'] = f'postgresql://{db_user}:{db_password}@{db_host}:5432/{db_name}'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
migrate = Migrate(app, db)

class Task(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(120), nullable=False)
    description = db.Column(db.Text, nullable=True)
    priority = db.Column(db.String(50), nullable=False, default='Medium')
    due_date = db.Column(db.Date, nullable=True)

@app.before_first_request
def initialize_database():
    try:
        db.create_all()  
    except ProgrammingError as e:
        print("Error during database initialization:", e)

@app.route('/')
def index():
    try:
        tasks = Task.query.order_by(Task.due_date).all()
    except ProgrammingError:
        tasks = []
    return render_template('index.html', tasks=tasks)

@app.route('/tasks', methods=['POST'])
def create_task():
    title = request.form['title']
    description = request.form.get('description')
    priority = request.form.get('priority', 'Medium')
    due_date = request.form.get('due_date')

    new_task = Task(title=title, description=description, priority=priority, due_date=due_date)
    db.session.add(new_task)
    db.session.commit()
    return redirect(url_for('index'))

@app.route('/tasks/<int:task_id>', methods=['POST'])
def delete_task(task_id):
    task = Task.query.get(task_id)
    if task:
        db.session.delete(task)
        db.session.commit()
    return redirect(url_for('index'))

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000)
