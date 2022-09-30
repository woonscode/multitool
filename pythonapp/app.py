from flask import Flask, render_template
from flask_cors import CORS
import os

app = Flask(__name__)
cors = CORS(app)

name = os.environ.get("NAME")
color = os.environ.get("COLOR")
port = os.environ.get("PORT")

@app.route("/")
def home():
    return render_template("index.html", color=color)

@app.route("/hello")
def hello():
    return f"Hello, {name}!"

@app.route("/exit")
def bye():
    return f"Goodbye, {name}!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=port)