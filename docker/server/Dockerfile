FROM python:3.7

RUN pip install sklearn numpy joblib Flask

COPY server.py /app/server.py
COPY model.joblib /app/model.joblib

WORKDIR /app
ENTRYPOINT ["python3", "server.py"]
