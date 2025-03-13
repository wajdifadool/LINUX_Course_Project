FROM python:latest

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY plant_v2.py .

VOLUME /app/plots

ENTRYPOINT [ "python", "plant_v2.py" ]