from urllib import response

from fastapi import FastAPI
from pydantic import BaseModel
import joblib
import google.generativeai as genai
import json
from datetime import datetime
from dotenv import load_dotenv
import os

app = FastAPI()

load_dotenv()

genai.configure(
    api_key=os.getenv("GEMINI_API_KEY")
)

sentiment_model = joblib.load("sentiment_model.joblib")
chat_model = genai.GenerativeModel("gemini-2.5-flash")

chat_history = []

class ReviewRequest(BaseModel):
    komentar: str

class ChatRequest(BaseModel):
    message: str


@app.get("/")
def home():
    return {
        "message": "FastAPI EnzyLife Running"
    }


@app.post("/predict")
def predict(data: ReviewRequest):

    prediction = sentiment_model.predict(
        [data.komentar]
    )[0]

    probability = sentiment_model.predict_proba(
        [data.komentar]
    )[0]

    confidence = float(max(probability))

    return {
        "label": prediction,
        "score": round(confidence * 100, 2)
    }

@app.post("/chat")
def chat(data: ChatRequest):

    knowledge = load_knowledge()

    history_text = "\n".join(chat_history[-5:])

    prompt = f"""
        Anda adalah chatbot resmi EnzyLife.

        Gunakan informasi berikut sebagai sumber utama:

        {knowledge}

        Aturan:

        1. Jawab hanya seputar Eco Enzyme.
        2. Jika pertanyaan di luar topik Eco Enzyme, jawab:

        "Maaf, saya hanya dapat membantu pertanyaan seputar Eco Enzyme."

        Riwayat Percakapan:

        {history_text}

        Pertanyaan Pengguna:

        {data.message}
    """

    try:

        response = chat_model.generate_content(
            prompt
        )

        save_chat(
            data.message,
            response.text
        )

        chat_history.append(
            f"User: {data.message}"
        )

        chat_history.append(
            f"Bot: {response.text}"
        )

        return {
            "reply": response.text
        }

    except Exception:

        return {
            "reply": "Maaf, chatbot sedang mengalami gangguan."
        }

def load_knowledge():
    with open(
        "knowledge.txt",
        "r",
        encoding="utf-8"
    ) as file:
        return file.read()
    
    
def save_chat(question, answer):

    with open(
        "chat_logs.json",
        "r",
        encoding="utf-8"
    ) as file:

        logs = json.load(file)

    logs.append({
        "question": question,
        "answer": answer,
        "created_at": str(datetime.now())
    })

    with open(
        "chat_logs.json",
        "w",
        encoding="utf-8"
    ) as file:

        json.dump(
            logs,
            file,
            ensure_ascii=False,
            indent=4
        )
