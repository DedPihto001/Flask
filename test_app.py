import unittest

from app import app


class FlaskAppTests(unittest.TestCase):
    def setUp(self):
        self.client = app.test_client()

    def test_home(self):
        response = self.client.get("/")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json, {"message": "Hello from Flask!"})

    def test_info(self):
        response = self.client.get("/info")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json["app"], "Flask Docker Demo")

    def test_calculate(self):
        response = self.client.get("/calc/7/5")
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json, {"a": 7, "b": 5, "sum": 12})


if __name__ == "__main__":
    unittest.main()
