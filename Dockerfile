FROM python:3.12-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        kiwix-tools \
        curl \
        nginx-light \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --no-cache-dir pyyaml

WORKDIR /app
COPY parse_content.py .
COPY setup.sh .
COPY serve.sh .
COPY content.yaml .
COPY entrypoint.sh .
COPY nginx.conf /etc/nginx/nginx.conf
COPY index.html .

RUN chmod +x setup.sh serve.sh entrypoint.sh parse_content.py

# Content volume — mount your SSD / storage here
VOLUME /data

EXPOSE 8888 8080

ENTRYPOINT ["/app/entrypoint.sh"]
