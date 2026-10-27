
import os

from dotenv import load_dotenv
from google import genai

load_dotenv()

api_key = os.getenv("GEMINI_API_KEY")

if not api_key:
    raise ValueError("GEMINI_API_KEY belum ditemukan di file .env")

client = genai.Client(api_key=api_key)

response = client.models.generate_content(
    model="gemini-2.5-flash",
    contents="Jelaskan apa itu Eco Enzyme dalam 3 kalimat."
)

print("Jawaban Gemini:")
print(response.text)
