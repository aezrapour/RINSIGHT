import speech_recognition as sr
import pygame
import sys

# Initialize Pygame
pygame.init()

# Get the current display resolution
infoObject = pygame.display.Info()
window_size = (infoObject.current_w, infoObject.current_h)

# Set up the window in full screen mode
screen = pygame.display.set_mode(window_size, pygame.FULLSCREEN)
pygame.display.set_caption("Continuous Speech to Text in Full Screen")

# Your existing code for font, text_color, etc.
font = pygame.font.Font(None, 64)
text_color = (100, 0, 0)
background_color = (0, 0, 0)

# Your existing functions and code for speech recognition and text display
# Initialize SpeechRecognition
recognizer = sr.Recognizer()
mic = sr.Microphone()

# Example function to display text in the Pygame window
def display_text(text):
    screen.fill(background_color)
    rendered_text = font.render(text, True, text_color)
    text_rect = rendered_text.get_rect(center=(window_size[0]//2, window_size[1]//2))
    screen.blit(rendered_text, text_rect)
    pygame.display.flip()

# Function to continuously listen and process speech
# Function to continuously listen and process speech
def listen_and_process():
    output_string = ""
    try:
        with mic as source:
            recognizer.adjust_for_ambient_noise(source)
            while True:
                # display_text("Listening...")
                audio = recognizer.listen(source, timeout=5, phrase_time_limit=5)
                # display_text("Processing...")
                try:
                    text = recognizer.recognize_google(audio)
                    print(f"Recognized Text: {text}")  # Console output for debugging
                    display_text(text)
                except sr.UnknownValueError:
                    # display_text("Sorry, I did not understand that.")
                    continue
                except sr.RequestError as e:
                    continue
                    # display_text(f"Could not request results; {e}")
                
                # Check for Pygame events within the loop
                for event in pygame.event.get():
                    if event.type == pygame.QUIT or (event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE):
                        pygame.quit()
                        sys.exit()

    except Exception as e:
        print(f"Error Type: {type(e).__name__}, Error Message: {e}")  # More detailed error output

listen_and_process()