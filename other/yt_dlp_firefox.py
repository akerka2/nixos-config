import sys
import json
import struct
import subprocess

def read_message():
    raw_length = sys.stdin.buffer.read(4)
    if not raw_length:
        return None
    length = struct.unpack("=I", raw_length)[0]
    return json.loads(sys.stdin.buffer.read(length))

def send_message(data):
    encoded = json.dumps(data).encode("utf-8")
    sys.stdout.buffer.write(struct.pack("=I", len(encoded)))
    sys.stdout.buffer.write(encoded)
    sys.stdout.buffer.flush()

while True:
    msg = read_message()
    if msg is None:
        break
    url = msg.get("url", "")
    flags = msg.get("flags", [])
    try:
        result = subprocess.run(
            ["yt-dlp"] + flags + ["--", url],
            capture_output=True,
            text=True,
        )
        send_message({
            "stdout": result.stdout,
            "stderr": result.stderr,
            "returncode": result.returncode,
        })
    except Exception as e:
        send_message({"error": str(e)})
