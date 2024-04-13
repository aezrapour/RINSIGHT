import asyncio
import time
import websockets
import base64
import pyaudio

# Setup PyAudio parameters
FORMAT = pyaudio.paInt16  # Adjust as needed
CHANNELS = 1
RATE = 16000  # Adjust to match your audio sample rate

# Initialize PyAudio and stream
p = pyaudio.PyAudio()
stream = p.open(format=FORMAT, channels=CHANNELS, rate=RATE, output=True)

# Your existing variables and file setup
audio_buffer = b''
i = 0
times_since_last = []

async def parse_audio(audio_str):
    global audio_buffer, i, times_since_last, stream
    try:
        i += 1
        audio = base64.b64decode(audio_str)
        audio_buffer += audio

        # Write decoded audio to PyAudio stream for playback
        stream.write(audio)

        if i % 100 == 0:  # Every 100 messages, print average period
            if times_since_last:
                print("Average period:", sum(times_since_last) / len(times_since_last))
            times_since_last.clear()

        # Reset buffer or handle it according to your logic
        # For continuous playback, you might not need to reset the buffer

    except Exception as e:
        print(e)

async def echo(websocket):
    async for message in websocket:
        await parse_audio(message)

async def main():
    async with websockets.serve(echo, "0.0.0.0", 8887):
        await asyncio.Future()  # run forever

try:
    asyncio.run(main())
finally:
    # Ensure resources are cleaned up properly
    stream.stop_stream()
    stream.close()
    p.terminate()