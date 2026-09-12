FROM python:3.12-slim

# Create a dedicated non-root user
RUN useradd --create-home --shell /usr/sbin/nologin appuser

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Give the application user ownership of the application files
RUN chown -R appuser:appuser /app

# Run application as non-root
USER appuser

EXPOSE 5000

CMD ["python", "app.py"]
