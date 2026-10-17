
from fastapi import FastAPI
from pydantic import BaseModel
import joblib

app = FastAPI()

sentiment_model = joblib.load("sentiment_model.joblib")


class ReviewRequest(BaseModel):
    komentar: str


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
