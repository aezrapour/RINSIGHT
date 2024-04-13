from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

connections = {
    "flutter": [],
    "esp32": []
}

@app.websocket("/flutter")
async def websocket_flutter_endpoint(websocket: WebSocket):
    await websocket.accept()
    connections['flutter'].append(websocket)
    try:
        while True:
            text_data = await websocket.receive_text()
            print(f"Received data from Flutter: {text_data}")
            # Forward this message to all ESP32 connections
            for esp32_websocket in connections['esp32']:
                await esp32_websocket.send_text(text_data)
    except WebSocketDisconnect:
        print("Flutter WebSocket connection closed by client.")
        connections['flutter'].remove(websocket)
    finally:
        await websocket.close()

@app.websocket("/")
async def websocket_esp32_endpoint(websocket: WebSocket):
    await websocket.accept()
    connections['esp32'].append(websocket)
    try:
        while True:
            # ESP32 might also send data back to server
            text_data = await websocket.receive_text()
            print(f"Received data from ESP32: {text_data}")
    except WebSocketDisconnect:
        print("ESP32 WebSocket connection closed by client.")
        connections['esp32'].remove(websocket)
    finally:
        await websocket.close()

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8887)
