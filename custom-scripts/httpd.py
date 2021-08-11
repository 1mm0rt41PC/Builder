import http.server
import socketserver
import sys
PORT = int(sys.argv[2]) if len(sys.argv)==3 else 80
INTERFACE = sys.argv[1] if len(sys.argv)>=2 else '0.0.0.0'

if INTERFACE == '-h':
	print(f'Usage: \n {sys.argv[0]} [interface] [port]')
	sys.exit(-1)

handler = http.server.SimpleHTTPRequestHandler

with socketserver.TCPServer((INTERFACE, PORT), handler) as httpd:
	print(f"Server started on {INTERFACE}:{PORT}")
	httpd.serve_forever()