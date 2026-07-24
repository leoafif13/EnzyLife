from fastapi.testclient import TestClient
from unittest.mock import patch

from main import app

client = TestClient(app)


@patch("main.sentiment_model")
def test_predict_positive(mock_model):

    mock_model.predict.return_value = ["positif"]
    mock_model.predict_proba.return_value = [[0.95,0.03,0.02]]

    response = client.post(
        "/predict",
        json={
            "komentar":"Aroma eco enzyme sangat segar"
        }
    )

    assert response.status_code == 200

    assert response.json() == {
        "label":"positif",
        "score":95.0
    }


@patch("main.sentiment_model")
def test_predict_negative(mock_model):

    mock_model.predict.return_value = ["negatif"]
    mock_model.predict_proba.return_value = [[0.02,0.03,0.95]]

    response = client.post(
        "/predict",
        json={
            "komentar":"Baunya busuk sekali"
        }
    )

    assert response.status_code == 200

    assert response.json()["label"] == "negatif"


def test_predict_invalid_request():

    response = client.post(
        "/predict",
        json={}
    )

    assert response.status_code == 422