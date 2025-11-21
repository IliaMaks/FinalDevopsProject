FROM python:3.11-slim

WORKDIR /app

# Do not create .pyc files and force stdout/stderr to be unbuffered
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install dependencies
RUN pip install --no-cache-dir flask

# Copy project files
COPY Pythoncode ./Pythoncode
COPY Website ./Website

# Data directory inside the container (NFS mount in Kubernetes)
ENV DATA_DIR=/data
VOLUME ["/data"]

EXPOSE 5000

CMD ["python", "Website/app.py"]
