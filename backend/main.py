from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World apeczka"}

@app.get("/games")
def get_games():
    # przykładowe dane gier
    return [
        {"id": 1, "title": "Gra 1", "duration": "30min"},
        {"id": 2, "title": "Gra 2", "duration": "45min"}
    ]
