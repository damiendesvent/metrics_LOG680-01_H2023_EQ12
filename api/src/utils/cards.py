import datetime
from sqlalchemy.orm import Session

from src.models import models

import src.schemas
import uuid

# from sqlalchemy.orm import joinedload


def __is_valid_uuid(uuid_to_test, version=4):
    try:
        uuid_obj = uuid.UUID(uuid_to_test, version=version)
    except ValueError:
        return False

    return str(uuid_obj) == uuid_to_test

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

"""
    This function returns a card by its content
"""
def get_card_by_content(db: Session, content: str):
    return db.query(models.Card).filter(models.Card.content == content).first()

"""
    This function returns a card by its content and its creation date
"""
def get_card_by_content_and_created_at(db: Session, content: str, created_at: datetime):
    return db.query(models.Card).filter(models.Card.content == content).filter(models.Card.created_at == created_at).filter(models.Card.parent_card_id == None).first()

"""
    This function returns a card by its id
"""
def get_card_by_id(db: Session, id: str):
    return db.query(models.Card).filter(models.Card.id == id).first()

"""
    This function returns all the cards of a specific column. Column_id can be either the id of the column or the name of the column
"""
def get_cards_by_column_id(db: Session, column_id: str, project_owner: str, project_id: int, items_per_page: int, offset: int):
    # get if column_id is a valid uuid or not
    if __is_valid_uuid(column_id) == True:
        return db.query(models.Card).filter(models.Card.column_id == column_id).limit(items_per_page).offset(offset).all()
    else:
        # we get the column id searching by the name of the column
        print("column_id: ", column_id)

        column_id = db.query(models.ProjectColumn).filter(models.ProjectColumn.name == column_id).filter(models.ProjectColumn.project_id == project_id).filter(models.ProjectColumn.project_owner==project_owner).first().id

        return db.query(models.Card).filter(models.Card.column_id == column_id).limit(items_per_page).offset(offset).all()


"""
    This function returns all the cards of a specific column that have been uploaded in a specific time range. Column_id can be either the id of the column or the name of the column
"""
def get_cards_by_column_id_with_time_range(db: Session, column_id: str, project_owner: str, project_id: int , start_time: datetime, end_time: datetime, items_per_page: int, offset: int):
    # get if column_id is a valid uuid or not
    if __is_valid_uuid(column_id) == True:
        return db.query(models.Card).filter(models.Card.column_id == column_id).filter(models.Card.uploaded_at >= start_time).filter(models.Card.uploaded_at <= end_time).limit(items_per_page).offset(offset).all()
    else:
        # we get the column id searching by the name of the column
        print("column_id: ", column_id)

        column_id = db.query(models.ProjectColumn).filter(models.ProjectColumn.name == column_id).filter(models.ProjectColumn.project_id == project_id).filter(models.ProjectColumn.project_owner==project_owner).first().id

        return db.query(models.Card).filter(models.Card.column_id == column_id).filter(models.Card.uploaded_at >= start_time).filter(models.Card.uploaded_at <= end_time).limit(items_per_page).offset(offset).all()

"""
    This function returns all the cards that have been uploaded in a specific time range. 
"""
def get_cards_by_time_range(db: Session, start_time: datetime, end_time: datetime, items_per_page: int, offset: int):
    return db.query(models.Card).filter(models.Card.uploaded_at >= start_time).filter(models.Card.uploaded_at <= end_time).limit(items_per_page).offset(offset).all()

# """
#     This function returns all the cards that have been uploaded to the done column
# """
# def get_completed_cards_by_time_range(db: Session, start_time: datetime, end_time: datetime, items_per_page: int, offset: int):
#     return db.query(models.Card).filter(models.Card.uploaded_at >= start_time).filter(models.Card.uploaded_at <= end_time).filter(models.Card.parent_card_id == None).filter(models.Card.closed == True).limit(items_per_page).offset(offset).all()
