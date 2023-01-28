from sqlalchemy.orm import Session

from src.models import models

import src.schemas
import uuid

from sqlalchemy.orm import joinedload

def create_recipe(db: Session, card: src.schemas.Card):
    
    id = str(uuid.uuid4())

    db_recipe = models.Card(id=id,
                            bame = card.name,
                            content = card.content,
                            column_id = card.column_id,
                            created_at=card.created_at)

    db_recipe.save(db)   

    return db_recipe


def get_card_by_id(db: Session, id: str):
    return db.query(models.Card).filter(models.Card.id == id).first()

def get_cards_by_column_id(db: Session, column_id: str):
    return db.query(models.Card).filter(models.Card.column_id == column_id).all()

def get_cards_by_column_id_with_column(db: Session, column_id: str):
    return db.query(models.Card).options(joinedload(models.Card.column)).filter(models.Card.column_id == column_id).all()

def get_cards_by_column_id_with_time_range(db: Session, column_id: str , start_time: int, end_time: int, items_per_page: int, offset: int):
    return db.query(models.Card).filter(models.Card.column_id == column_id).filter(models.Card.created_at >= start_time).filter(models.Card.created_at <= end_time).limit(items_per_page).offset(offset).all()

def get_total_count(db: Session):
    return db.query(models.Card).count()

