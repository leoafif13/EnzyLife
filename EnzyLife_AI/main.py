from fastapi import FastAPI
from pydantic import BaseModel, Field, field_validator
import joblib

from rag_gemini import generate_answer

app = FastAPI()

sentiment_model = joblib.load("sentiment_model.joblib")


class ReviewRequest(BaseModel):
    komentar: str


class ChatRequest(BaseModel):
    pertanyaan: str = Field(
        min_length=1,
        max_length=2000
    )
    history: list[dict[str, str]] = Field(
        default_factory=list,
        max_length=30
    )

    @field_validator("pertanyaan")
    @classmethod
    def validate_pertanyaan(cls, value: str) -> str:
        value = value.strip()

        if not value:
            raise ValueError(
                "Pertanyaan tidak boleh kosong atau hanya berisi spasi."
            )

        return value

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
    jawaban = generate_answer(
        data.pertanyaan,
        history=data.history
    )

    return {
        "jawaban": jawaban
    }
