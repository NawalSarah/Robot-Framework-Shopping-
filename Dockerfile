# Packages the whole suite + a browser into one image, so it runs the same everywhere.
#   docker build -t robot-ui-suite .
#   docker run --rm -v "$PWD/results:/app/results" robot-ui-suite
FROM python:3.12-slim

# Chromium and a matching chromedriver from Debian (they are versioned together).
RUN apt-get update \
    && apt-get install -y --no-install-recommends chromium chromium-driver \
    && rm -rf /var/lib/apt/lists/*

ENV CHROME_BINARY=/usr/bin/chromium \
    CHROMEDRIVER_PATH=/usr/bin/chromedriver

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
CMD ["python", "run_tests.py"]
