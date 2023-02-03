import datetime
from sqlalchemy.orm import Session

from src.models import models

import src.schemas
import uuid

from sqlalchemy.orm import joinedload

def __is_valid_uuid(uuid_to_test, version=4):
    try:
        uuid_obj = uuid.UUID(uuid_to_test, version=version)
    except ValueError:
        return False

    return str(uuid_obj) == uuid_to_test

def create_new_column(db: Session, column: src.schemas.ProjectColumn):

    # db_column = models.ProjectColumn(id=column.id,
    #                         project_id=column.project_id,
    #                         name = column.name,
    #                         cards = column.cards,
    #                         created_at=column.created_at)
    db_column = models.ProjectColumn(**column.dict())

    db_column.save(db)   

    return db_column


"""
    This function returns a column by its id or by its name
"""
def get_column_by_id(db: Session, id: str):
    if __is_valid_uuid(id) == True:
        return db.query(models.ProjectColumn).filter(models.ProjectColumn.id == id).first()
    else:
        return get_column_by_name(db, id)

"""
    This function returns a column by its name
"""
def get_column_by_name(db: Session, name: str):
    return db.query(models.ProjectColumn).filter(models.ProjectColumn.name == name).first()


def get_all_columns(db: Session):
    return db.query(models.ProjectColumn).all()

def get_all_columns_with_cards(db: Session):
    # return db.query(models.ProjectColumn).options(joinedload(models.ProjectColumn.cards)).filter(models.Card.parent_card_id == None).all() 
    return db.query(models.ProjectColumn).options(joinedload(models.ProjectColumn.cards)).all() 

def get_all_columns_with_cards_by_time_range(db: Session, start_time: datetime, end_time: datetime, items_per_page: int, offset: int):
    return db.query(models.ProjectColumn).options(joinedload(models.ProjectColumn.cards)).filter(models.Card.uploaded_at >= start_time).filter(models.Card.uploaded_at <= end_time).limit(items_per_page).offset(offset).all()