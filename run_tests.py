"""One-command test runner:  python run_tests.py

What it does (so you can explain it in an interview):
  1. Starts a tiny web server that hosts the demo shop in ./demo_app
  2. Runs all Robot Framework tests in ./tests against it
  3. Stops the server and writes reports to ./results (open results/report.html)
Exit code is 0 when all tests pass, non-zero otherwise (CI uses this).
"""
import functools
import http.server
import sys
import threading
from pathlib import Path

import robot

ROOT = Path(__file__).parent
PORT = 0   # 0 = let the operating system pick any free port (avoids 'address already in use')


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *args, **kwargs):  # keep the console quiet
        pass


def start_server():
    handler = functools.partial(QuietHandler, directory=str(ROOT / "demo_app"))
    server = http.server.ThreadingHTTPServer(("127.0.0.1", PORT), handler)
    threading.Thread(target=server.serve_forever, daemon=True).start()
    return server


if __name__ == "__main__":
    # Extra arguments are passed to Robot, e.g.  python run_tests.py --variable HEADLESS:False
    server = start_server()
    port = server.server_address[1]
    print(f"Demo shop running at http://localhost:{port}")
    try:
        code = robot.run_cli(
            ["--outputdir", str(ROOT / "results"),
             "--variable", f"BASE_URL:http://localhost:{port}",
             *sys.argv[1:],
             str(ROOT / "tests")],
            exit=False,
        )
    finally:
        server.shutdown()
    print("Open results/report.html in your browser to see the report.")
    sys.exit(code)
