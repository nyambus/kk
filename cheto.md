Создание проекта с уязвимостями на Docker — отличная идея, позволяющая легко управлять окружением и зависимостями. Вот пошаговая инструкция по развертыванию веб-приложения с уязвимостями, используя Docker.

### Проект: Веб-приложение для интернет-магазина с уязвимостями на Docker

#### Уязвимости
1. **SQL Injection**
2. **Brute Force**
3. **XSS (Кросс-Сайтовый Скриптинг)**
4. **CSRF (Межсайтовая подделка запросов)**
5. **Неправильное управление файловым доступом**

### Шаги по разворачиванию

#### 1. Установка Docker
Убедитесь, что у вас установлен Docker. Если нет, выполните следующие команды в зависимости от вашей операционной системы:

- **Ubuntu/Debian**:
  ```bash
  sudo apt update
  sudo apt install -y docker.io docker-compose
  ```

- **Windows/Mac**: Скачайте и установите [Docker Desktop](https://www.docker.com/products/docker-desktop).

#### 2. Создание структуры проекта
Создайте новую директорию проекта и перейдите в нее:

```bash
mkdir ecommerce-vulnerable
cd ecommerce-vulnerable
```

Внутри создайте структуру директорий:

```bash
mkdir app
mkdir db
```

#### 3. Настройка Dockerfile
В директории **app** создайте файл `Dockerfile`:

```Dockerfile
# Укажите базовый образ
FROM php:8.0-apache

# Установите необходимые расширения
RUN docker-php-ext-install mysqli

# Копируйте приложение внутрь контейнера
COPY ./src /var/www/html/

# Настройка прав
RUN chown -R www-data:www-data /var/www/html
```

#### 4. Создание структуры приложения
В директории **app** создайте поддиректорию **src** и добавьте файл `index.php`:

```bash
mkdir src
```

Создайте файл **src/index.php** с содержимым:

```php
<?php
$conn = mysqli_connect('db', 'root', 'password', 'ecommerce');

if (isset($_POST['login'])) {
    $username = $_POST['username'];
    $password = $_POST['password'];
    // SQL Injection уязвимость
    $result = mysqli_query($conn, "SELECT * FROM users WHERE username='$username' AND password='$password'");
    if (mysqli_num_rows($result) > 0) {
        session_start();
        $_SESSION['username'] = $username;
    }
}

if (isset($_SESSION['username'])) {
    echo "<h1>Добро пожаловать, " . htmlspecialchars($_SESSION['username']) . "</h1>";
} else {
    echo '<form method="POST"><input name="username"><input name="password"><button type="submit" name="login">Вход</button></form>';
}
?>
```

Создайте файл **src/delete_account.php**:

```php
<?php
session_start();
if (isset($_SESSION['username'])) {
    $conn = mysqli_connect('db', 'root', 'password', 'ecommerce');
    mysqli_query($conn, "DELETE FROM users WHERE username='" . $_SESSION['username'] . "'");
    session_destroy();
    header("Location: index.php");
}
?>
```

Создайте файл **src/upload.php** для демонстрации уязвимости загрузки файлов:

```php
<?php
if (isset($_FILES['file'])) {
    move_uploaded_file($_FILES['file']['tmp_name'], './uploads/' . $_FILES['file']['name']);
}
?>
<form action="" method="POST" enctype="multipart/form-data">
    <input type="file" name="file" />
    <input type="submit" value="Загрузить" />
</form>
```

#### 5. Настройка базы данных
Создайте файл **docker-compose.yml** в корне проекта:

```yaml
version: '3.8'

services:
  app:
    build:
      context: ./app
    ports:
      - "8080:80"
    depends_on:
      - db

  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: password
      MYSQL_DATABASE: ecommerce
    volumes:
      - db_data:/var/lib/mysql

volumes:
  db_data:
```

#### 6. Инициализация базы данных
Создайте файл **db/init.sql** с запросами для создания таблицы пользователей:

```sql
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL
);
INSERT INTO users (username, password) VALUES ('admin', 'password123');
```

Обновите секцию **db** в `docker-compose.yml`, чтобы использовать инициализационный скрипт:

```yaml
db:
  image: mysql:5.7
  environment:
    MYSQL_ROOT_PASSWORD: password
    MYSQL_DATABASE: ecommerce
  volumes:
    - db_data:/var/lib/mysql
    - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql
```

#### 7. Запуск контейнеров
В корневой директории проекта выполните:

```bash
docker-compose up --build
```

Это скачает образы, создаст контейнеры и запустит приложение.

#### 8. Проверка приложения
Откройте браузер и перейдите по адресу [http://localhost:8080](http://localhost:8080). Вы должны увидеть форму для входа в приложение.

#### 9. Тестирование уязвимостей
- **SQL Injection**: Попробуйте использовать введите `admin' OR '1'='1` в поле имени пользователя и любой пароль.
- **Brute Force**: Попробуйте несколько паролей без ограничения попыток.
- **XSS**: В вставьте скрипт в поле имени пользователя при регистрации.
- **CSRF**: Проверьте, без токена, можно ли выполнить запрос к `delete_account.php`.
- **Неправильное управление файлами**: Попробуйте загрузить файл без проверки.

### Заключение
Вы успешно развернули веб-приложение с современными уязвимостями, используя Docker. Это окружение прекрасно подходит для изучения безопасности веб-приложений и тестирования. Убедитесь, что данный проект используется только в образовательных целях в контролируемом окружении. 
