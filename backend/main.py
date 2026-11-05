from fastapi import FastAPI

app = FastAPI(title="LearningTracker API")


@app.get("/")
def root():
    return {"message": "hello world"}


@app.get("/health")
def health():
    return {"status": "ok"}

