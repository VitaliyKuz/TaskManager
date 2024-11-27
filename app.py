from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
from prometheus_client import Counter, generate_latest
from flask import Response
import os
from dotenv import load_dotenv

load_dotenv()  # Завантаження змінних із .env

app = Flask(__name__)
app.secret_key = 'your_secret_key'
app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv(
    'DATABASE_URL', 'postgresql://user:1@db:5432/tasks_db'
)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

task_counter = Counter('task_operations_total', 'Total task operations', ['operation'])


class Task(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(100), nullable=False)
    description = db.Column(db.Text, nullable=True)
    priority = db.Column(db.String(50), nullable=False)
    due_date = db.Column(db.DateTime, nullable=False)
    status = db.Column(db.String(50), default='active')

    def __repr__(self):
        return f"<Task {self.title}>"


def initialize_database():
    with app.app_context():
        db.create_all()


@app.route('/')
def index():
    tasks = Task.query.all()
    return render_template('index.html', tasks=tasks)


@app.route('/add', methods=['POST'])
def add_task():
    try:
        # Валідація введення
        title = request.form['title']
        if len(title) > 100:
            flash("Title must not exceed 100 characters.")
            return redirect(url_for('index'))

        description = request.form['description']
        if len(description) > 500:
            flash("Description must not exceed 500 characters.")
            return redirect(url_for('index'))

        priority = request.form['priority']
        if priority not in ['High', 'Medium', 'Low']:
            flash("Invalid priority selected.")
            return redirect(url_for('index'))

        due_date_str = request.form['due_date']
        try:
            due_date = datetime.strptime(due_date_str, '%Y-%m-%d')
        except ValueError:
            flash("Invalid date format. Use YYYY-MM-DD.")
            return redirect(url_for('index'))

        # Додавання задачі
        task = Task(title=title, description=description, priority=priority, due_date=due_date)
        db.session.add(task)
        db.session.commit()
        task_counter.labels(operation='add').inc()
        flash("Task added successfully!")
    except Exception as e:
        flash(f"An error occurred: {str(e)}")
    return redirect(url_for('index'))


@app.route('/delete/<int:task_id>')
def delete_task(task_id):
    try:
        task = Task.query.get_or_404(task_id)
        db.session.delete(task)
        db.session.commit()
        task_counter.labels(operation='delete').inc()
        flash("Task deleted successfully!")
    except Exception as e:
        flash(f"An error occurred: {str(e)}")
    return redirect(url_for('index'))


@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype='text/plain')


if __name__ == '__main__':
    initialize_database()
    app.run(host='0.0.0.0', port=5000)
