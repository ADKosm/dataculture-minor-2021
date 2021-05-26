#!/bin/bash

set -xe

mkdir -p crypt

cat > crypt/crypt.py <<END
import sys
from pathlib import Path

from cryptography.fernet import Fernet

key = b'-H5QKgetGkLdGK3eimqnujur0JLr4GUL5L75-E6VdmE='


def main(command, filepath):
    path = Path(filepath)
    assert path.exists(), "No such file {}".format(filepath)
    fnet = Fernet(key)
    with open(filepath, 'rb') as f:
        data = f.read()

    if command == 'encrypt':
        result = fnet.encrypt(data)
    elif command == 'decrypt':
        result = fnet.decrypt(data.decode('utf-8').strip().encode('utf-8'))
    else:
        print("No such command {}".format(command))

    print(result.decode('utf-8'))


if __name__ == "__main__":
    assert len(sys.argv) >= 1, "Not enough arguments. Pass command and path"
    _, command, filepath = sys.argv
    main(command, filepath)
END

cat > crypt/Dockerfile <<END
FROM python:3.7

RUN pip install cryptography

COPY crypt.py /app/crypt.py

ENTRYPOINT ["python3", "/app/crypt.py"]
END

mkdir -p server

cat > server/Dockerfile <<END
FROM python:3.7

RUN pip install sklearn numpy joblib Flask

COPY server.py /app/server.py
COPY model.joblib /app/model.joblib

WORKDIR /app
ENTRYPOINT ["python3", "server.py"]
END

cat > server/Dockerfile.train <<END
FROM python:3.7

RUN pip install sklearn numpy joblib

COPY train.py /app/train.py

ENTRYPOINT ["python3", "/app/train.py"]
END

cat > server/server.py <<END
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
END

cat > server/train.py <<END
from sklearn import datasets
from sklearn.linear_model import LogisticRegression
from joblib import dump, load
import sys


def main(output):
    iris = datasets.load_iris()
    X = iris.data
    y = iris.target

    clf = LogisticRegression(random_state=0).fit(X, y)
    print(clf.score(X, y))

    dump(clf, output)

if __name__ == "__main__":
    assert len(sys.argv) >= 1, "Not enough arguments. Pass path"
    _, filepath = sys.argv
    main(filepath)
END
