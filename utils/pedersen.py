# set up environment: 
# python3.9 -m venv ~/cairo_venv
# source ~/cairo_venv/bin/activate

# usage: pass an atom value or head+tail of Pedersen hashes to hash
#        curl 'http://localhost:3000/pedersen?atom=23.222'
#     OR curl 'http://localhost:3000/pedersen?head=2.323.424&tail=297324'

from starkware.crypto.signature.signature import pedersen_hash
from http.server import BaseHTTPRequestHandler, HTTPServer
from urllib.parse import urlparse
from urllib.parse import parse_qs

PORT = 3000

def hash_noun(n):
  if "atom" in n:
    return pedersen_hash(int(n['atom'][0].replace('.', '')), 0)
  elif "head" in n and "tail" in n:
    return pedersen_hash(int(n['head'][0].replace('.', '')), int(n['tail'][0].replace('.', '')))
  else:
    raise Exception("Error: arg should be atom or head&tail")

class GP(BaseHTTPRequestHandler):
  def _set_headers(self):
    self.send_response(200)
    self.send_header('Content-type', 'text/html')
    self.end_headers()
  def do_HEAD(self):
    self._set_headers()
  def do_GET(self):
    self._set_headers()
    if self.path == '/favicon.ico':
      return
    qs_noun = parse_qs(urlparse(self.path).query)
    h = hash_noun(qs_noun)
    self.wfile.write(str(h).encode('utf-8'))

def run(server_class=HTTPServer, handler_class=GP, port=PORT):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    print('Server running at localhost:' + str(PORT) + '...')
    httpd.serve_forever()

run()
