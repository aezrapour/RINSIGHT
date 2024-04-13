import asyncio
import base64
import time
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI()

# Restrict CORS for production use
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Replace with your front-end's address
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.websocket("/")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    audio_buffer = bytearray()
    start_time = time.time()
    message_count = 0

    try:
        while True:
            audio_str = await websocket.receive_text()
            try:
                audio = base64.b64decode(audio_str)
                audio_buffer.extend(audio)
                message_count += 1

                # Periodically log the time and save the audio buffer
                if message_count % 100 == 0:
                    elapsed_time = time.time() - start_time
                    print(f"Received 100 messages in {elapsed_time:.2f} seconds.")
                    with open('./curr_audio.raw', 'ab') as f:
                        f.write(audio_buffer)
                    audio_buffer.clear()

            except Exception as e:
                print(f"Error decoding audio: {e}")

    except Exception as e:
        print(f"WebSocket error: {e}")
    finally:
        await websocket.close()
        # Clean up and save any remaining audio
        if audio_buffer:
            with open('./curr_audio.raw', 'ab') as f:
                f.write(audio_buffer)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8887)
