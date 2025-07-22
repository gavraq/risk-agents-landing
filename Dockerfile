# Use Python 3.11 slim image as base
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy application files
COPY index.html .
COPY server.py .

# Create a non-root user for security
RUN useradd -m -u 1000 webuser && \
    chown -R webuser:webuser /app

# Switch to non-root user
USER webuser

# Expose port 8080
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python3 -c "import urllib.request; urllib.request.urlopen('http://localhost:8080')" || exit 1

# Run the server
CMD ["python3", "server.py"]
