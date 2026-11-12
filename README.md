# Flask Docker Demo

Простое Flask-приложение с тремя JSON-эндпоинтами:

- `GET /` — приветствие;
- `GET /info` — информация о приложении;
- `GET /calc/<a>/<b>` — сумма двух целых чисел.

## Запуск в Docker

В PowerShell из этой папки выполните:

```powershell
docker build -t my-flask-app .
docker run -d --name my-flask-app -p 5000:5000 my-flask-app
```

Либо запустите через Compose:

```powershell
docker compose up -d --build
```

Проверьте приложение, открыв <http://localhost:5000>, или запросите
`http://localhost:5000/calc/7/5`. Остановка:

```powershell
docker compose down
```

## Запуск локально без Docker

```powershell
python -m pip install -r requirements.txt
python app.py
```

Запуск тестов:

```powershell
python -m unittest -v
```
