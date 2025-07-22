#!/usr/bin/env python3
"""
Production HTTP Server for Risk Agents Landing Page
Optimized for Docker container deployment
"""

import http.server
import socketserver
import os
import sys
import signal
import logging
from pathlib import Path

# Configuration
HOST = "0.0.0.0"  # Listen on all interfaces
PORT = 8080       # Standard port for the application

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[logging.StreamHandler(sys.stdout)]
)
logger = logging.getLogger(__name__)

class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Custom handler optimized for production"""
    
    def log_message(self, format, *args):
        """Override to use proper logging"""
        logger.info("%s - - [%s] %s" % (
            self.address_string(),
            self.log_date_time_string(),
            format % args
        ))
    
    def end_headers(self):
        """Add security and performance headers"""
        # Security headers
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.send_header('X-Frame-Options', 'DENY')
        self.send_header('X-XSS-Protection', '1; mode=block')
        self.send_header('Referrer-Policy', 'strict-origin-when-cross-origin')
        
        # Performance headers
        if self.path.endswith(('.css', '.js', '.png', '.jpg', '.jpeg', '.gif', '.ico')):
            self.send_header('Cache-Control', 'public, max-age=86400')  # 24 hours
        else:
            self.send_header('Cache-Control', 'public, max-age=3600')   # 1 hour
        
        # CORS headers (if needed for subdomains)
        self.send_header('Access-Control-Allow-Origin', 'https://*.risk-agents.com')
        self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        
        super().end_headers()
    
    def do_GET(self):
        """Handle GET requests with root path handling"""
        # Serve index.html for root path
        if self.path == '/' or self.path == '':
            self.path = '/index.html'
        elif self.path == '/health':
            # Health check endpoint
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write(b'{"status": "healthy", "service": "risk-agents-landing"}')
            return
        
        return super().do_GET()
    
    def do_OPTIONS(self):
        """Handle CORS preflight requests"""
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', 'https://*.risk-agents.com')
        self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()

class ThreadedTCPServer(socketserver.ThreadingMixIn, socketserver.TCPServer):
    """Threaded server for better performance"""
    allow_reuse_address = True
    daemon_threads = True

def signal_handler(signum, frame):
    """Handle graceful shutdown"""
    logger.info("Received shutdown signal, stopping server...")
    sys.exit(0)

def main():
    """Main function to start the web server"""
    
    # Set up signal handlers for graceful shutdown
    signal.signal(signal.SIGTERM, signal_handler)
    signal.signal(signal.SIGINT, signal_handler)
    
    # Verify index.html exists
    if not os.path.exists('index.html'):
        logger.error("index.html not found in current directory")
        sys.exit(1)
    
    try:
        # Create threaded server for better performance
        with ThreadedTCPServer((HOST, PORT), CustomHTTPRequestHandler) as httpd:
            logger.info(f"🌐 Risk Agents Landing Page Server")
            logger.info(f"🚀 Server running on http://{HOST}:{PORT}")
            logger.info(f"📁 Serving files from: {os.getcwd()}")
            logger.info(f"🔗 Health check: http://{HOST}:{PORT}/health")
            logger.info(f"🛑 Press Ctrl+C to stop")
            
            # Start serving
            httpd.serve_forever()
            
    except PermissionError:
        logger.error(f"Permission denied! Port {PORT} requires elevated privileges.")
        sys.exit(1)
        
    except OSError as e:
        if e.errno == 98:  # Address already in use
            logger.error(f"Port {PORT} is already in use!")
        else:
            logger.error(f"Server error: {e}")
        sys.exit(1)
        
    except KeyboardInterrupt:
        logger.info("Server stopped by user")
        sys.exit(0)

if __name__ == "__main__":
    main()
