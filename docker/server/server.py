from flask import Flask, request
import json
import joblib
import re
import numpy as np

app = Flask(__name__)  # Основной объект приложения Flask


model = joblib.load('model.joblib')


@app.route('/')
def hello():
    return "Hello, from Flask"

@app.route('/predict', methods=["POST"])
def freq_handler():
    data = request.get_json(force=True)
    features = np.array(data['data'])

    result = model.predict([features])

    response = {
        "result": int(result[0])
    }
    return json.dumps(response)

if __name__ == '__main__':
    app.run("0.0.0.0", 9091)  # Запускаем сервер на 9091 порту
