### Шаги по созданию интерактивного обучающего сервиса

#### Шаг 1: Создание структуры проекта

**Что делать:**
Создайте папку для вашего проекта и создайте необходимую структуру файлов. Это обеспечит организованность вашего кода.

**Зачем:**
Хорошая структура проекта позволяет легко навигировать и поддерживать код. Это особенно важно при работе с большими проектами.

**Структура папок:**

```
interactive_learning/
├── app.py              # Главный файл приложения
├── models.py           # Модели базы данных
├── forms.py            # Формы для обработки данных
├── templates/          # Шаблоны HTML
│   ├── base.html       # Шаблон-основа
│   ├── index.html      # Главная страница
│   ├── course.html     # Страница курса
│   ├── quiz.html       # Страница квиза
├── static/             # Статические файлы (CSS, JS)
│   ├── css/            # CSS файлы
│   └── js/             # JS файлы
└── database.db         # Файл базы данных SQLite
```

#### Шаг 2: Установка зависимостей

**Что делать:**
Установите Flask и необходимые библиотеки с помощью `pip`.

```bash
pip install Flask Flask-SQLAlchemy Flask-WTF
```

**Зачем:**
Эти библиотеки предоставляют необходимую функциональность для выполнения вашего приложения:
- **Flask** — основной фреймворк для веб-разработки на Python.
- **Flask-SQLAlchemy** — библиотека для работы с базами данных SQL.
- **Flask-WTF** — расширение для работы с формами и валидацией.

#### Шаг 3: Создание `app.py`

**Что делать:**
Создайте файл `app.py` и добавьте код, который будет обрабатывать маршруты приложения.

**Зачем:**
Этот файл является основным входной точкой вашего приложения Flask. Он определяет маршруты, взаимодействие с базой данных и логику отображения шаблонов.

##### Код `app.py`:

```python
from flask import Flask, render_template, request, redirect, url_for
from models import db, Course, Quiz
from forms import CourseForm, QuizForm

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///database.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.secret_key = 'your_secret_key'

db.init_app(app)

@app.route('/')
def index():
    courses = Course.query.all()
    return render_template('index.html', courses=courses)
```

#### Шаг 4: Создание моделей базы данных

**Что делать:**
Создайте файл `models.py`, чтобы определить структуры данных (модели) для курсов и квизов.

**Зачем:**
Модели представляют собой структуры хранения данных и позволяют Flask-SQLAlchemy взаимодействовать с вашей базой данных.

##### Код `models.py`:

```python
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class Course(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(150), nullable=False)
    description = db.Column(db.Text, nullable=False)

class Quiz(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    course_id = db.Column(db.Integer, db.ForeignKey('course.id'), nullable=False)
    question = db.Column(db.String(255), nullable=False)
    answer = db.Column(db.String(100), nullable=False)
```

#### Шаг 5: Создание форм

**Что делать:**
Создайте файл `forms.py` для определения форм, которые будут использоваться для ввода данных.

**Зачем:**
Формы управляют пользовательским вводом и обеспечивают валидацию данных перед отправкой на сервер.

##### Код `forms.py`:

```python
from flask_wtf import FlaskForm
from wtforms import StringField, TextAreaField, SubmitField
from wtforms.validators import DataRequired

class CourseForm(FlaskForm):
    title = StringField('Title', validators=[DataRequired()])
    description = TextAreaField('Description', validators=[DataRequired()])
    submit = SubmitField('Add Course')

class QuizForm(FlaskForm):
    question = StringField('Question', validators=[DataRequired()])
    answer = StringField('Answer', validators=[DataRequired()])
    submit = SubmitField('Add Quiz')
```

#### Шаг 6: Создание HTML-шаблонов

**Что делать:**
Создайте необходимые HTML-шаблоны для отображения контента.

**Зачем:**
Шаблоны позволяют разделить логику приложения и представление, что упрощает поддержку и улучшает читаемость кода.

##### Пример кода для шаблонов:

- **`base.html`** – основной шаблон для страниц:

```html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Interactive Learning</title>
    <link rel="stylesheet" href="{{ url_for('static', filename='css/style.css') }}">
</head>
<body>
    <nav>
        <a href="/">Home</a>
        <a href="{{ url_for('add_course') }}">Add Course</a>
    </nav>
    <div class="container">
        {% block content %}{% endblock %}
    </div>
</body>
</html>
```

- **`index.html`** — главная страница со списком курсов:

```html
{% extends 'base.html' %}
{% block content %}
<h1>Available Courses</h1>
<ul>
    {% for course in courses %}
        <li><a href="{{ url_for('course', course_id=course.id) }}">{{ course.title }}</a></li>
    {% endfor %}
</ul>
{% endblock %}
```

#### Шаг 7: Создание логики обработки запросов

**Что делать:**
Добавьте логику для обработки ввода данных (например, добавление курсов и квизов).

**Зачем:**
Эта логика управляет взаимодействиями пользователя с приложением и обеспечивает правильное отображение данных.

##### Дополните `app.py`:

```python
@app.route('/course/<int:course_id>')
def course(course_id):
    course = Course.query.get(course_id)
    quizzes = Quiz.query.filter_by(course_id=course_id).all()
    return render_template('course.html', course=course, quizzes=quizzes)

@app.route('/add_course', methods=['GET', 'POST'])
def add_course():
    form = CourseForm()
    if form.validate_on_submit():
        new_course = Course(title=form.title.data, description=form.description.data)
        db.session.add(new_course)
        db.session.commit()
        return redirect(url_for('index'))
    return render_template('add_course.html', form=form)
```

#### Шаг 8: Настройка стилей и скриптов

**Что делать:**
Создайте необходимые CSS и JS файлы для стилизации и интерактивности.

**Зачем:**
Стиль и интерактивность делают приложение более привлекательным и удобным для пользователя.

##### Пример кода для CSS (`static/css/style.css`):

```css
body {
    font-family: Arial, sans-serif;
    margin: 20px;
}

nav {
    margin-bottom: 20px;
}

nav a {
    margin-right: 10px;
}

.container {
    border: 1px solid #ccc;
    padding: 20px;
}
```

#### Шаг 9: Создание базы данных

**Что делать:**
Инициализируйте базу данных с помощью контекста приложения.

**Зачем:**
Создание базы данных позволяет сохранить все ваши курсы и квизы для использования в приложении.

##### Дополните `app.py`:

```python
with app.app_context():
    db.create_all()
```

#### Шаг 10: Запуск приложения

**Что делать:**
Запустите приложение и проверьте его работу.

```bash
python app.py
```

**Зачем:**
Запуск приложения позволит вам протестировать созданный сервис и убедиться в его работоспособности.

Не забудьте перейти по адресу `http://127.0.0.1:5000` в вашем браузере, чтобы увидеть вашу главную страницу.
