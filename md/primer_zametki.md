### Шаг 1: Подготовка окружения

1. **Установите Python**: Убедитесь, что у вас установлена последняя версия Python (версия 3.6 и выше).
   - Можно скачать с [официального сайта Python](https://www.python.org/downloads/).

2. **Создайте виртуальное окружение**:
   ```bash
   python -m venv venv
   ```

3. **Активируйте виртуальное окружение**:
   - На Windows:
     ```bash
     venv\Scripts\activate
     ```
   - На macOS/Linux:
     ```bash
     source venv/bin/activate
     ```

### Шаг 2: Установка зависимостей

1. **Установите Flask и SQLite**:
   ```bash
   pip install Flask Flask-SQLAlchemy
   ```

### Шаг 3: Создание структуры проекта

Создайте следующие файлы и директории:

```
note_service/
│
├── app.py
└── templates/
    └── notes.html
```

### Шаг 4: Реализация приложения

1. **Создайте файл `app.py`** и вставьте следующий код:

   ```python
   from flask import Flask, request, render_template, redirect, url_for
   from flask_sqlalchemy import SQLAlchemy

   app = Flask(__name__)
   app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///notes.db'
   db = SQLAlchemy(app)

   class Note(db.Model):
       id = db.Column(db.Integer, primary_key=True)
       content = db.Column(db.String(200), nullable=False)

   db.create_all()  # Создает базы данных при первом запуске

   @app.route('/')
   def index():
       notes = Note.query.all()
       return render_template('notes.html', notes=notes)

   @app.route('/add', methods=['POST'])
   def add_note():
       content = request.form['note_content']
       new_note = Note(content=content)
       db.session.add(new_note)
       db.session.commit()
       return redirect(url_for('index'))

   if __name__ == '__main__':
       app.run(debug=True)
   ```

2. **Создайте файл `templates/notes.html`** и вставьте следующий код:

   ```html
   <!DOCTYPE html>
   <html lang="en">
   <head>
       <meta charset="UTF-8">
       <meta name="viewport" content="width=device-width, initial-scale=1.0">
       <title>Заметки</title>
   </head>
   <body>
       <h1>Мои заметки</h1>
       <form action="/add" method="post">
           <input type="text" name="note_content" placeholder="Введите заметку" required>
           <button type="submit">Добавить</button>
       </form>

       <ul>
           {% for note in notes %}
               <li>{{ note.content }}</li>
           {% endfor %}
       </ul>
   </body>
   </html>
   ```

### Шаг 5: Внедрение уязвимостей

Теперь, чтобы встроить уязвимости, рассмотрим несколько аспектов:

1. **SQL-инъекция**:
   - Для внедрения этой уязвимости, не проверяем вводимые данные.
   - Например, замените `content = request.form['note_content']` на `content = request.form['note_content']` без какого-либо экранирования. Это потенциально уязвимо к SQL-инъекциям при более сложных запросах.

2. **XSS (межсайтовый скриптинг)**:
   - Отображение контента заметок без экранирования делает приложение уязвимым. Замените `{{ note.content }}` на `{{ note.content | safe }}` в `notes.html`, чтобы позволить выполнение HTML/JS кода.

### Шаг 6: Запуск приложения

1. **Запустите приложение**:
   ```bash
   python app.py
   ```

2. **Откройте браузер и перейдите по адресу**: `http://127.0.0.1:5000/`

