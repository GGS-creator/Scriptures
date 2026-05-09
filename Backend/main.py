import os

import gita
from fastapi import FastAPI,HTTPException, Header, Request
from pydantic import BaseModel
import random
from fastapi.responses import FileResponse
from fastapi.middleware.cors import CORSMiddleware
from slowapi import Limiter
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded

app=FastAPI()

limiter=Limiter(key_func=get_remote_address)
app.state.limiter=limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

API_KEY=os.getenv("API_KEY")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def read_index():
    return FileResponse("index.html")

@app.get("/send")
@limiter.limit("5/minute")
def send(request: Request,x_api_key:str=Header(None)):
    if x_api_key != API_KEY:
        raise HTTPException(status_code=403,detail="Unauthorized")
    temp=gita.page("TheHolyGita.txt",random.randint(1,1078))
    return {"message": temp}