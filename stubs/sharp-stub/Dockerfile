FROM python:3.12-slim

WORKDIR /app
COPY server.py frames.jsonl ./

EXPOSE 8010
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
    CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8010/healthz')"]

CMD ["python", "server.py"]
