FROM python:3.11-alpine

WORKDIR /app
RUN mkdir -p /app
COPY ./requirements.txt .
COPY src/ /app/ 
RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "/app/main.py"]
