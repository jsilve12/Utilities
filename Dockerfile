FROM tiangolo/uvicorn-gunicorn-fastapi:python3.9-alpine3.14
RUN apk add --no-cache curl postgresql-libs g++ gcc musl-dev postgresql-dev
COPY requirements.txt .
RUN pip3 install -r requirements.txt

WORKDIR /Utilities
COPY Cloud/ Cloud/
COPY Common/ Common/
COPY Infrastructure/ Infrastructure/
COPY Web-Py/ Web-Py/
COPY setup.py setup.py

python3 setup.py bdist_wheel
pip install dist/utilities-1.0.0-py3-none-any.whl
