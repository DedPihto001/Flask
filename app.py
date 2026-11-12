from flask import Flask, jsonify

app = Flask(__name__)


@app.get("/")
def home():
    return jsonify(message="Hello from Flask!")


@app.get("/info")
def info():
    return jsonify(app="Flask Docker Demo", version="1.0.0")


@app.get("/calc/<int:a>/<int:b>")
def calculate(a, b):
    return jsonify(a=a, b=b, sum=a + b)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
