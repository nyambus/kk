### Вариант: Система для ведения дневника

#### Этап 1: Установка окружения

- **Выберите язык и фреймворк**: Используем Python и фреймворк Flask.
- **Установите необходимые библиотеки**:
  ```bash
  pip install Flask Flask-SQLAlchemy
  ```

#### Этап 2: Настройка проекта

1. **Создайте структуру проекта**:
    ```
    diary_app/
    ├── app.py
    ├── templates/
    │   ├── index.html
    │   └── diary_entry.html
    └── models.py
    ```

2. **Создайте файл `app.py`**:
    ```python
    from flask import Flask, render_template, request, redirect
    from models import db, DiaryEntry

    app = Flask(__name__)
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///diary.db'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

    db.init_app(app)

    @app.route('/')
    def index():
        entries = DiaryEntry.query.all()
        return render_template('index.html', entries=entries)

    @app.route('/add', methods=['POST'])
    def add_entry():
        content = request.form.get('content')
        entry = DiaryEntry(content=content)
        db.session.add(entry)
        db.session.commit()
        return redirect('/')

    if __name__ == '__main__':
        with app.app_context():
            db.create_all()
        app.run(debug=True)
    ```

3. **Создайте файл `models.py`**:
    ```python
    from flask_sqlalchemy import SQLAlchemy

    db = SQLAlchemy()

    class DiaryEntry(db.Model):
        id = db.Column(db.Integer, primary_key=True)
        content = db.Column(db.String(500), nullable=False)
    ```

4. **Создайте файл HTML `index.html` в папке `templates/`**:
    ```html
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Diary</title>
    </head>
    <body>
        <h1>Your Diary</h1>
        <form action="/add" method="POST">
            <textarea name="content" required></textarea>
            <button type="submit">Add Entry</button>
        </form>
        <ul>
            {% for entry in entries %}
                <li>{{ entry.content }}</li>
            {% endfor %}
        </ul>
    </body>
    </html>
    ```

#### Этап 3: Запуск сервиса

1. **Запустите приложение**:
   ```bash
   python app.py
   ```

2. **Перейдите в браузере на `http://127.0.0.1:5000`**. Вы сможете добавлять записи в дневник.

#### Этап 4: Внедрение уязвимостей

1. **Уязвимость XSS**: Позволяет вставлять пользовательские скрипты через поле ввода текста.
   - Вместо отображения текста безопасно отобразите его как HTML:
     ```html
     <li>{{ entry.content|safe }}</li>
     ```

### Вариант: Сервис обмена сообщениями с шифрованием

#### Этап 1: Установка окружения

- **Выберите язык и фреймворк**: Опять же, используем Python с Flask.
- **Установите необходимые библиотеки**:
  ```bash
  pip install Flask Flask-SocketIO cryptography
  ```

#### Этап 2: Настройка проекта

1. **Создайте структуру проекта**:
    ```
    chat_app/
    ├── app.py
    ├── templates/
    │   └── chat.html
    └── encryption.py
    ```

2. **Создайте файл `app.py`**:
    ```python
    from flask import Flask, render_template, request
    from flask_socketio import SocketIO
    import encryption

    app = Flask(__name__)
    socketio = SocketIO(app)

    @app.route('/')
    def index():
        return render_template('chat.html')

    @socketio.on('send_message')
    def handle_message(data):
        message = encryption.decrypt_message(data['message'])
        socketio.emit('receive_message', {'message': message})

    if __name__ == '__main__':
        socketio.run(app, debug=True)
    ```

3. **Создайте файл `encryption.py`**:
    ```python
    from cryptography.fernet import Fernet

    key = Fernet.generate_key()
    cipher_suite = Fernet(key)

    def encrypt_message(message):
        return cipher_suite.encrypt(message.encode())

    def decrypt_message(encrypted_message):
        return cipher_suite.decrypt(encrypted_message).decode()
    ```

4. **Создайте файл HTML `chat.html` в папке `templates/`**:
    ```html
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <title>Chat</title>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/socket.io/4.0.0/socket.io.min.js"></script>
    </head>
    <body>
        <h1>Chat Room</h1>
        <input type="text" id="message">
        <button onclick="sendMessage()">Send</button>
        <ul id="messages"></ul>

        <script>
            const socket = io();

            function sendMessage() {
                const message = document.getElementById('message').value;
                socket.emit('send_message', {message: message});
            }

            socket.on('receive_message', function(data) {
                const li = document.createElement('li');
                li.appendChild(document.createTextNode(data.message));
                document.getElementById('messages').appendChild(li);
            });
        </script>
    </body>
    </html>
    ```

#### Этап 3: Запуск сервиса

1. **Запустите приложение**:
   ```bash
   python app.py
   ```

2. **Перейдите в браузере на `http://127.0.0.1:5000`** для использования чата.

-----------------------------------------------------------------------------
### Вариант: Система для ведения дневника

#### Уязвимость XSS (межсайтовый скриптинг)

1. **Измените отображение контента в `index.html`**:
   Вместо безопасного отображения контента, уберите фильтрацию:
   ```html
   <ul>
       {% for entry in entries %}
           <li>{{ entry.content }}</li> <!-- Убрано |safe -->
       {% endfor %}
   </ul>
   ```

2. **Теперь пользователь может вставлять HTML и JavaScript**:
   Например, записав следующий контент:
   ```html
   <script>alert('XSS Vulnerability!');</script>
   ```

#### Другие уязвимости

- **SQL-инъекция**: Если вы добавите компонент для поиска через базу данных, можно не валидировать входные данные.
   - Добавьте следующую функцию поиска, не использовав подготовленные выражения:
   ```python
   @app.route('/search', methods=['GET'])
   def search():
       query = request.args.get('query')
       results = db.session.execute(f"SELECT * FROM diary_entry WHERE content LIKE '%{query}%'")
       return render_template('search_results.html', results=results)
   ```

### Вариант: Сервис обмена сообщениями с шифрованием

#### Уязвимость в шифровании

1. **Используйте предопределённый и небезопасный ключ**:
   Измените `encryption.py` следующим образом:
   ```python
   key = b'my_predefined_key_123456789012'  # Не безопасный ключ длиной 32 байта
   cipher_suite = Fernet(key)
   ```

2. **Теперь шифрование будет предсказуемым**:
   Если злоумышленник узнал ключ, он сможет расшифровать сообщения.

#### Уязвимость через неконтролируемый ввод

- **Добавьте возможность отправлять сообщения без валидации**:
   Измените обработчик на стороне сервера, чтобы он принимал нешифрованные сообщения:
   ```python
   @socketio.on('send_message')
   def handle_message(data):
       # Уберите декодирование
       message = data['message']
       socketio.emit('receive_message', {'message': message})
   ```

Теперь злоумышленник может отправлять любой текст и не сможет контролировать его содержание.
