from flask import Flask
import os
import psycopg2

app = Flask(__name__)

@app.route("/")
def home():
    return """
    <html>
        <head>
            <title>DevOps Assignment</title>
        </head>
        <body>
            <h1>IT Infrastructure & DevOps Trainee</h1>
            <p>Flask application is running successfully!</p>
            <p>Nginx reverse proxy is working.</p>
            <p>PostgreSQL backend is configured.</p>
        </body>
    </html>
    """

@app.route("/health")
def health():
    return {"status": "healthy"}

@app.route("/db-test")
def db_test():
    try:
        conn = psycopg2.connect(
            host=os.getenv("DB_HOST", "db"),
            database=os.getenv("POSTGRES_DB", "devopsdb"),
            user=os.getenv("POSTGRES_USER", "devops"),
            password=os.getenv("POSTGRES_PASSWORD", "devopspass")
        )
        conn.close()
        return {"database": "connected"}
    except Exception as e:
        return {"database": "error", "message": str(e)}, 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
