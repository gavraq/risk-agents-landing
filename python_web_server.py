#!/usr/bin/env python3
"""
Simple HTTP Server for Gavin Slater Landing Page
Run this script to serve the landing page on your local network
"""

import http.server
import socketserver
import os
import sys
from pathlib import Path

# Configuration
HOST = "192.168.0.45"  # Your local machine IP
PORT = 8080            # Port 8080 to match your main domain in Nginx Proxy Manager

class CustomHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    """Custom handler to serve index.html for root requests"""
    
    def end_headers(self):
        # Add CORS headers if needed
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()
    
    def do_GET(self):
        # Serve index.html for root path
        if self.path == '/':
            self.path = '/index.html'
        return super().do_GET()

def create_index_file():
    """Create the index.html file if it doesn't exist"""
    index_content = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Gavin Slater - Welcome</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            overflow: hidden;
        }

        .container {
            max-width: 800px;
            width: 90%;
            text-align: center;
            position: relative;
            z-index: 2;
        }

        .welcome-section {
            margin-bottom: 4rem;
            animation: fadeInUp 1s ease-out;
        }

        .logo {
            width: 120px;
            height: 120px;
            background: rgba(255, 255, 255, 0.15);
            border-radius: 50%;
            margin: 0 auto 2rem;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 3rem;
            font-weight: bold;
            backdrop-filter: blur(10px);
            border: 2px solid rgba(255, 255, 255, 0.2);
            animation: pulse 2s infinite;
        }

        h1 {
            font-size: 3.5rem;
            font-weight: 700;
            margin-bottom: 1rem;
            background: linear-gradient(45deg, #fff, #f0f0f0);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .subtitle {
            font-size: 1.25rem;
            opacity: 0.9;
            font-weight: 300;
            margin-bottom: 3rem;
        }

        .links-section {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            max-width: 700px;
            margin: 0 auto;
        }

        .link-card {
            background: rgba(255, 255, 255, 0.1);
            backdrop-filter: blur(20px);
            border-radius: 20px;
            padding: 2.5rem 2rem;
            text-decoration: none;
            color: white;
            transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            border: 1px solid rgba(255, 255, 255, 0.2);
            position: relative;
            overflow: hidden;
        }

        .link-card::before {
            content: '';
            position: absolute;
            top: 0;
            left: -100%;
            width: 100%;
            height: 100%;
            background: linear-gradient(90deg, transparent, rgba(255, 255, 255, 0.1), transparent);
            transition: left 0.5s;
        }

        .link-card:hover::before {
            left: 100%;
        }

        .link-card:hover {
            transform: translateY(-10px);
            background: rgba(255, 255, 255, 0.15);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.2);
        }

        .link-icon {
            font-size: 3rem;
            margin-bottom: 1rem;
            display: block;
        }

        .link-title {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 0.5rem;
        }

        .link-description {
            font-size: 1rem;
            opacity: 0.8;
            line-height: 1.5;
        }

        .background-shapes {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            z-index: 1;
            overflow: hidden;
        }

        .shape {
            position: absolute;
            background: rgba(255, 255, 255, 0.05);
            border-radius: 50%;
            animation: float 6s ease-in-out infinite;
        }

        .shape:nth-child(1) {
            width: 200px;
            height: 200px;
            top: 10%;
            left: 10%;
            animation-delay: 0s;
        }

        .shape:nth-child(2) {
            width: 150px;
            height: 150px;
            top: 70%;
            right: 10%;
            animation-delay: 2s;
        }

        .shape:nth-child(3) {
            width: 100px;
            height: 100px;
            top: 50%;
            left: 80%;
            animation-delay: 4s;
        }

        @keyframes fadeInUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        @keyframes pulse {
            0%, 100% {
                transform: scale(1);
            }
            50% {
                transform: scale(1.05);
            }
        }

        @keyframes float {
            0%, 100% {
                transform: translateY(0px) rotate(0deg);
            }
            33% {
                transform: translateY(-20px) rotate(120deg);
            }
            66% {
                transform: translateY(10px) rotate(240deg);
            }
        }

        @media (max-width: 768px) {
            h1 {
                font-size: 2.5rem;
            }
            
            .subtitle {
                font-size: 1.1rem;
            }
            
            .links-section {
                grid-template-columns: 1fr;
                gap: 1.5rem;
            }
            
            .link-card {
                padding: 2rem 1.5rem;
            }
        }
    </style>
</head>
<body>
    <div class="background-shapes">
        <div class="shape"></div>
        <div class="shape"></div>
        <div class="shape"></div>
    </div>

    <div class="container">
        <div class="welcome-section">
            <div class="logo">GS</div>
            <h1>Welcome</h1>
            <p class="subtitle">Discover innovative solutions and learning opportunities</p>
        </div>

        <div class="links-section">
            <a href="http://ai.gavinslater.co.uk" class="link-card">
                <span class="link-icon">🤖</span>
                <div class="link-title">AI Learning Hub</div>
                <div class="link-description">Join our lunch and learn training sessions on Artificial Intelligence and discover the future of technology</div>
            </a>

            <a href="http://credit.gavinslater.co.uk" class="link-card">
                <span class="link-icon">📊</span>
                <div class="link-title">Credit Risk Workflow</div>
                <div class="link-description">Access our comprehensive credit risk management and workflow application</div>
            </a>
        </div>
    </div>
</body>
</html>'''
    
    with open('index.html', 'w', encoding='utf-8') as f:
        f.write(index_content)
    print("✓ Created index.html")

def main():
    """Main function to start the web server"""
    
    # Create index.html if it doesn't exist
    if not os.path.exists('index.html'):
        create_index_file()
    
    # Change to script directory
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    try:
        # Create server
        with socketserver.TCPServer((HOST, PORT), CustomHTTPRequestHandler) as httpd:
            print(f"""
╔══════════════════════════════════════════════════════════════════════════════════╗
║                          🌐 Gavin Slater Web Server                              ║
╠══════════════════════════════════════════════════════════════════════════════════╣
║                                                                                  ║
║  🚀 Server running at: http://{HOST}:{PORT}                                  ║
║  📁 Serving files from: {os.getcwd()}                                        ║
║                                                                                  ║
║  🔗 Access your landing page:                                                   ║
║     Local: http://localhost:{PORT}                                              ║
║     Network: http://{HOST}:{PORT}                                           ║
║                                                                                  ║
║  📱 Mobile/Other devices on network: http://{HOST}:{PORT}                  ║
║                                                                                  ║
║  ⚠️  Note: Configure your DNS/router to point gavinslater.co.uk              ║
║     to {HOST} for the domain to work properly.                             ║
║                                                                                  ║
║  🛑 Press Ctrl+C to stop the server                                            ║
╚══════════════════════════════════════════════════════════════════════════════════╝
            """)
            
            # Start serving
            httpd.serve_forever()
            
    except PermissionError:
        print(f"""
❌ Permission denied! Port {PORT} requires administrator privileges.
   
   Try one of these solutions:
   1. Run as administrator/sudo: sudo python3 server.py
   2. Use a different port: Change PORT in the script
   3. On Windows: Run Command Prompt as Administrator
        """)
        sys.exit(1)
        
    except OSError as e:
        if e.errno == 98:  # Address already in use
            print(f"""
❌ Port {PORT} is already in use!
   
   Try one of these solutions:
   1. Stop the service using port {PORT}
   2. Use a different port: Change PORT in the script
   3. Kill the process: sudo lsof -ti:{PORT} | xargs kill -9
            """)
        else:
            print(f"❌ Server error: {e}")
        sys.exit(1)
        
    except KeyboardInterrupt:
        print("\n\n🛑 Server stopped by user")
        sys.exit(0)

if __name__ == "__main__":
    main()