from app import app

client = app.test_client()


def test_home():
    assert client.get("/").status_code == 200


def test_health():
    assert client.get("/health").get_json() == {"status": "healthy"}


def test_config_hides_secret(monkeypatch):
    monkeypatch.setenv("API_TOKEN", "super-secret")
    body = client.get("/config").get_json()
    assert body["api_token_loaded"] is True
    assert "super-secret" not in str(body)


def test_error_returns_500():
    assert client.get("/error").status_code == 500
