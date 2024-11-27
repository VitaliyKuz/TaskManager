from flask import Flask, render_template, request, redirect, url_for, Response
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from prometheus_client import Counter, generate_latest
import os
from dotenv import load_dotenv

# Завантаження змінних середовища
load_dotenv()

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv(
    'DATABASE_URL', 'postgresql://user:1@db:5432/tasks_db'
)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Метрика Prometheus
task_counter = Counter('task_operations_total', 'Total task operations', ['operation'])

# Модель для завдань
class Task(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=True)
    priority = db.Column(db.String(50), nullable=False)
    due_date = db.Column(db.DateTime, nullable=False)
    status = db.Column(db.String(50), default='active')

    def __repr__(self):
        return f"<Task {self.title}>"

# Ініціалізація бази даних
def initialize_database():
    with app.app_context():
        db.create_all()

# Маршрут для головної сторінки
@app.route('/')
def index():
    tasks = Task.query.all()
    return render_template('index.html', tasks=tasks)

# Додавання нового завдання
@app.route('/add', methods=['POST'])
def add_task():
    task_counter.labels(operation='add').inc()
    title = request.form['title']
    description = request.form['description']
    priority = request.form['priority']
    due_date = datetime.strptime(request.form['due_date'], '%Y-%m-%d')
    task = Task(title=title, description=description, priority=priority, due_date=due_date)
    db.session.add(task)
    db.session.commit()
    return redirect(url_for('index'))

# Видалення завдання
@app.route('/delete/<int:task_id>')
def delete_task(task_id):
    task_counter.labels(operation='delete').inc()
    task = Task.query.get_or_404(task_id)
    db.session.delete(task)
    db.session.commit()
    return redirect(url_for('index'))

# Маршрут для метрик Prometheus
@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype='text/plain')

if __name__ == '__main__':
    initialize_database()  # Виклик ініціалізації бази даних
    app.run(host='0.0.0.0', port=5000)
