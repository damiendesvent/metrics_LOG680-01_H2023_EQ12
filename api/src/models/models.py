from sqlalchemy.sql.schema import ForeignKey

from sqlalchemy import Column, Boolean, String, Float, DateTime, Text, Integer
from sqlalchemy.ext.declarative import declared_attr
from sqlalchemy.orm import relationship
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.dialects.postgresql import UUID
import uuid

Base = declarative_base()

from datetime import *

def datetime_parser(o):
    if isinstance(o, datetime):
        return o.__str__()


class BaseModel(Base):
    __abstract__ = True

    project_id = Column(Integer, nullable=False)
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    created_at = Column(DateTime, default=datetime.utcnow)
    name = Column(String(255))

    def save(self, db):
        db.add(self)
        db.commit()
        db.refresh(self)
        return self

    def delete(self, db):
        db.delete(self)
        db.commit()
        return self

    def __repr__(self):
        return f"{self.__class__.__name__}({self.id})"


class ProjectColumn(BaseModel):
    __tablename__ = "columns"
    cards = relationship("Card",  cascade="all, delete-orphan" , lazy="joined")

    def save(self, db):
        db.add(self)
        db.commit()
        db.refresh(self)
        return self

    def delete(self, db):
        db.delete(self)
        db.commit()
        return self

    def add_card(self, card, db):
        self.cards.append(card)
        db.commit()
        db.refresh(self)
        return self

    def __repr__(self):
        return f"Column {self.name} ({self.id})"

class Card(BaseModel):
    __tablename__ = 'cards'

    content = Column(Text)
    column_id = Column(UUID(as_uuid=True), ForeignKey("columns.id"))
    parent_card_id = Column(UUID(as_uuid=True), ForeignKey("cards.id")) # if the card is a child of another card

    uploaded_at = Column(DateTime, default=datetime.utcnow) # when the card was uploaded to the column (not when it was created on Github Website)
    # finished_at = Column(DateTime, default=datetime.utcnow) # when the card was moved to the finished column
    closed = Column(Boolean, default=False)
    closed_at = Column(DateTime, default=None) # when the card was closed if it was closed (None if it was not closed)
    lead_time = Column(Float, default=0) # time between the creation of the card and the upload of the card to the column 
    labels = Column(Text, default="[]")
    assignees = Column(Text, default="[]")
    state = Column(Text, default="no-state")
    pull_state = Column(Text, default=None) # onli if the card is a pull request, it is the state of the pull request
    type_name = Column(String(255), default="Issue") # the type of the card, it can be "Issue" or "PullRequest"

    def save(self, db):
        db.add(self)
        db.commit()
        db.refresh(self)
        return self

    def __repr__(self):
        return f"<Card {self.id} at column {self.column_id}>"

