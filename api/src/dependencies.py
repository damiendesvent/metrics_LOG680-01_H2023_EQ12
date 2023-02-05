from datetime import datetime, timedelta
from fastapi import Depends, FastAPI, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from jose import JWTError, jwt
from passlib.context import CryptContext

from src.db import SessionLocal, engine


from typing import  Union

import src.schemas


from sqlalchemy.orm import Session

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

