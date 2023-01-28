from datetime import datetime
from typing import List, Union
from pydantic import BaseModel

# We make a snapshot, and we save the cards in that snapshot on the specific column. The same card can be in multiple columns as cards can move
# from one column to another. We can also have a card in multiple snapshots, as a card can be moved from one snapshot to another.

        
class Card(BaseModel):
    id: str
    name: str
    content: str
    created_at: datetime
    column_id: str

    class Config:
        orm_mode = True


class Column(BaseModel):
    name: str
    id: str
    created_at: datetime
    cards: List[Union[Card, None]]

    class Config:
        orm_mode = True