from fastapi import FastAPI
from pydantic import BaseModel
import joblib

app = FastAPI()

model = joblib.load("sentiment_model.joblib")


class ReviewRequest(BaseModel):
    komentar: str


@app.get("/")
def home():
    return {
        "message": "FastAPI EnzyLife Running"
    }


@app.post("/predict")
def predict(data: ReviewRequest):

    prediction = model.predict(
        [data.komentar]
    )[0]

    probability = model.predict_proba(
        [data.komentar]
    )[0]

    confidence = float(max(probability))

    return {
        "label": prediction,
        "score": round(confidence * 100, 2)
    }