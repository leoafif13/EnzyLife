from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock

from main import app

client = TestClient(app)


@patch("main.save_chat")
@patch("main.load_knowledge")
@patch("main.chat_model")
def test_chat_success(
    mock_chat,
    mock_knowledge,
    mock_save
):

    mock_knowledge.return_value = "Eco Enzyme adalah hasil fermentasi."

    fake_response = MagicMock()
    fake_response.text = "Eco Enzyme adalah cairan hasil fermentasi."

    mock_chat.generate_content.return_value = fake_response

    response = client.post(
        "/chat",
        json={
            "message":"Apa itu Eco Enzyme?"
        }
    )

    assert response.status_code == 200

    assert "reply" in response.json()


@patch("main.chat_model")
def test_chat_api_error(mock_chat):

    mock_chat.generate_content.side_effect = Exception("Gemini Error")

    response = client.post(
        "/chat",
        json={
            "message":"Halo"
        }
    )

    assert response.status_code == 200

    assert response.json()["reply"] == "Gemini Error"


def test_chat_invalid_body():

    response = client.post(
        "/chat",
        json={}
    )

    assert response.status_code == 422