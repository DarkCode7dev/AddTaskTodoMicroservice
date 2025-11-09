# Use the official Python image as the base image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the application code
COPY . .

# Install base dependencies and ODBC driver manager BEFORE adding MS repo
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl gnupg2 ca-certificates apt-transport-https \
        unixodbc unixodbc-dev libodbc2 && \
    # Add Microsoft’s GPG key and repository for Debian 12 (Bookworm)
    curl -sSL https://packages.microsoft.com/keys/microsoft.asc \
      | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] \
      https://packages.microsoft.com/debian/12/prod bookworm main" \
      > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    # Install the Microsoft ODBC driver for SQL Server
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 && \
    # Ensure the correct libodbc library is present
    apt-get install -y --reinstall libodbc2 && \
    # Clean up apt caches to reduce image size
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose port and start the FastAPI app
EXPOSE 8000
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
