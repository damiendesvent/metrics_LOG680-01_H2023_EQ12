import datetime
from sqlalchemy.orm import Session

from src.models import models

import src.schemas
import uuid

from sqlalchemy.orm import joinedload

def create_card(db: Session, card: src.schemas.Card):
    
    id = str(uuid.uuid4())

    db_recipe = models.Card(id=id,
                            project_id=card.project_id,
                            name = card.name,
                            content = card.content,
                            column_id = card.column_id,
                            created_at=card.created_at)

    db_recipe.save(db)   

    return db_recipe

def get_card_by_content(db: Session, content: str):
    return db.query(models.Card).filter(models.Card.content == content).first()

def get_card_by_content_and_created_at(db: Session, content: str, created_at: datetime):
    return db.query(models.Card).filter(models.Card.content == content).filter(models.Card.created_at == created_at).filter(models.Card.parent_card_id == None).first()

def get_card_by_id(db: Session, id: str):
    return db.query(models.Card).filter(models.Card.id == id).first()

def get_cards_by_column_id(db: Session, column_id: str):
    return db.query(models.Card).filter(models.Card.column_id == column_id).all()

def get_cards_by_column_id_with_column(db: Session, column_id: str):
    return db.query(models.Card).options(joinedload(models.Card.column)).filter(models.Card.column_id == column_id).all()


"""
    This function returns all the cards of a specific column that have been uploaded in a specific time range
"""
def get_cards_by_column_id_with_time_range(db: Session, column_id: str , start_time: datetime, end_time: datetime, items_per_page: int, offset: int):
    return db.query(models.Card).filter(models.Card.column_id == column_id).filter(models.Card.uploaded_at >= start_time).filter(models.Card.uploaded_at <= end_time).limit(items_per_page).offset(offset).all()

"""
    This function returns all the cards that have been uploaded in a specific time range
"""
def get_cards_by_time_range(db: Session, start_time: datetime, end_time: datetime, items_per_page: int, offset: int):
    return db.query(models.Card).filter(models.Card.uploaded_at >= start_time).filter(models.Card.uploaded_at <= end_time).limit(items_per_page).offset(offset).all()

def get_total_count(db: Session):
    return db.query(models.Card).count()


"""
    This function returns all the cards that have been uploaded to the done column
"""
def get_completed_cards_by_time_range(db: Session, start_time: datetime, end_time: datetime, items_per_page: int, offset: int):
    return db.query(models.Card).filter(models.Card.uploaded_at >= start_time).filter(models.Card.uploaded_at <= end_time).filter(models.Card.parent_card_id == None).filter(models.Card.lead_time > 0).limit(items_per_page).offset(offset).all()
