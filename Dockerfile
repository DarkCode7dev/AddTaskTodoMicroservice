# Base image
FROM python:3.11-slim

# Install prerequisites and ODBC libraries
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      curl gnupg2 \
      unixodbc \
      unixodbc-dev \
      libodbc1 \  # ensure libodbc.so.2 is available
      # other dependencies you need ...
      && rm -rf /var/lib/apt/lists/*

# Optional: create symlink if the library is installed under another name
RUN if [ ! -e /usr/lib/x86_64-linux-gnu/libodbc.so.2 ] && [ -e /usr/lib/x86_64-linux-gnu/libodbc.so ]; then \
      ln -s /usr/lib/x86_64-linux-gnu/libodbc.so /usr/lib/x86_64-linux-gnu/libodbc.so.2; \
    fi

# Install Microsoft SQL Server driver if needed
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor -o /usr/share/keyrings/microsoft.gpg && \
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com/debian/12/prod bookworm main" \
    > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql18 && \
    rm -rf /var/lib/apt/lists/*

# Copy code, install Python deps, and run your app as before…
