from pydantic import BaseModel
from typing import Literal, Optional

class UserCreate(BaseModel):
    full_name: str
    disability_mode: Literal['blind', 'deaf', 'normal']

class UserResponse(BaseModel):
    id: str
    full_name: str
    disability_mode: str

class FeedbackCreate(BaseModel):
    user_id: str
    feedback_text: str
    rating: int