import http.server
import socketserver

PORT = 80

class ThreadingHTTPServer(socketserver.ThreadingMixIn, http.server.HTTPServer):
    pass

Handler = http.server.SimpleHTTPRequestHandler

with ThreadingHTTPServer(("", PORT), Handler) as httpd:
    print("Serving HTTP (Multi-Threaded) on port", PORT)
    httpd.serve_forever()
