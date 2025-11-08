# Use a slim Python image as the base
FROM python:3.11-slim

# Install OS-level packages, including the ODBC libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        gnupg2 \
        unixodbc \
        unixodbc-dev \
        libodbc2 \        # provides libodbc.so.2:contentReference[oaicite:1]{index=1} \
        libodbccr2 \      # cursor library companion \
        && rm -rf /var/lib/apt/lists/*

# Add Microsoft’s GPG key and repository for SQL Server ODBC driver
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor -o /usr/share/keyrings/microsoft.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" \
    > /etc/apt/sources.list.d/mssql-release.list

# Install the Microsoft ODBC driver for SQL Server
RUN apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 && \
    rm -rf /var/lib/apt/lists/*

# Ensure the loader can find newly-installed libraries
RUN ldconfig

# Set the working directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose the port
EXPOSE 8000

# Start the FastAPI application with Uvicorn
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
