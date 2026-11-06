import base64
import json
import subprocess
import time
import urllib.request
from pathlib import Path

import websocket


ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "screenshots"
CHROME = Path(r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe")
PORT = 9223
URL = "http://localhost:8765"


def command(ws, identifier, method, params=None):
    ws.send(json.dumps({"id": identifier, "method": method, "params": params or {}}))
    while True:
        result = json.loads(ws.recv())
        if result.get("id") == identifier:
            return result


def main():
    OUTPUT.mkdir(exist_ok=True)
    profile = Path.home() / "AppData" / "Local" / "Temp" / "jasa-dekat-review-chrome"
    subprocess.Popen(
        [
            str(CHROME),
            "--headless=new",
            "--disable-gpu",
            "--hide-scrollbars",
            f"--remote-debugging-port={PORT}",
            f"--user-data-dir={profile}",
            "--window-size=390,844",
            URL,
        ],
        creationflags=subprocess.CREATE_NO_WINDOW,
    )
    for _ in range(60):
        try:
            targets = json.load(urllib.request.urlopen(f"http://localhost:{PORT}/json"))
            target = next(item for item in targets if item.get("type") == "page")
            break
        except Exception:
            time.sleep(1)
    else:
        raise RuntimeError("Chrome remote debugging did not start")

    ws = websocket.create_connection(target["webSocketDebuggerUrl"], suppress_origin=True)
    command(ws, 1, "Page.enable")
    command(ws, 3, "Runtime.enable")
    command(ws, 2, "Emulation.setDeviceMetricsOverride", {
        "width": 390, "height": 844, "deviceScaleFactor": 1, "mobile": True
    })
    time.sleep(20)
    print(command(ws, 4, "Runtime.evaluate", {
        "expression": "document.readyState + ' ' + document.title + ' ' + document.body.innerText"
    }))

    def capture(index, label):
        result = command(ws, 10 + index, "Page.captureScreenshot", {
            "format": "png", "captureBeyondViewport": False
        })
        image = base64.b64decode(result["result"]["data"])
        path = OUTPUT / f"{index:02d}-{label}.png"
        path.write_bytes(image)
        print(path)

    capture(1, "login-mobile")
    command(ws, 20, "Emulation.setDeviceMetricsOverride", {
        "width": 1440, "height": 960, "deviceScaleFactor": 1, "mobile": False
    })
    time.sleep(1)
    capture(2, "login-desktop")
    command(ws, 21, "Emulation.setDeviceMetricsOverride", {
        "width": 390, "height": 844, "deviceScaleFactor": 1, "mobile": True
    })
    command(ws, 22, "Input.dispatchMouseEvent", {
        "type": "mouseMoved", "x": 280, "y": 380, "button": "none"
    })
    command(ws, 23, "Input.dispatchMouseEvent", {
        "type": "mousePressed", "x": 280, "y": 380, "button": "left", "clickCount": 1
    })
    command(ws, 24, "Input.dispatchMouseEvent", {
        "type": "mouseReleased", "x": 280, "y": 380, "button": "left", "clickCount": 1
    })
    time.sleep(1)
    capture(3, "register-mobile")
    def tap_and_type(x, y, text, start_id):
        command(ws, start_id, "Input.dispatchMouseEvent", {
            "type": "mousePressed", "x": x, "y": y, "button": "left", "clickCount": 1
        })
        command(ws, start_id + 1, "Input.dispatchMouseEvent", {
            "type": "mouseReleased", "x": x, "y": y, "button": "left", "clickCount": 1
        })
        command(ws, start_id + 2, "Input.insertText", {"text": text})

    tap_and_type(150, 418, "Nadia Demo", 30)
    tap_and_type(150, 510, "nadia.demo@example.com", 33)
    tap_and_type(150, 605, "rahasia123", 36)
    command(ws, 39, "Input.dispatchMouseEvent", {
        "type": "mousePressed", "x": 190, "y": 708, "button": "left", "clickCount": 1
    })
    command(ws, 40, "Input.dispatchMouseEvent", {
        "type": "mouseReleased", "x": 190, "y": 708, "button": "left", "clickCount": 1
    })
    time.sleep(2)
    capture(4, "home-mobile")
    ws.close()


if __name__ == "__main__":
    main()
