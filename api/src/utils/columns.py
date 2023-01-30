from sqlalchemy.orm import Session

from src.models import models

import src.schemas
import uuid

from sqlalchemy.orm import joinedload

def create_new_column(db: Session, column: src.schemas.ProjectColumn):

    # db_column = models.ProjectColumn(id=column.id,
    #                         project_id=column.project_id,
    #                         name = column.name,
    #                         cards = column.cards,
    #                         created_at=column.created_at)
    db_column = models.ProjectColumn(**column.dict())

    db_column.save(db)   

    return db_column

def get_column_by_id(db: Session, id: str):
    return db.query(models.ProjectColumn).filter(models.ProjectColumn.id == id).first()

def get_column_by_name(db: Session, name: str):
    return db.query(models.ProjectColumn).filter(models.ProjectColumn.name == name).first()

def get_all_columns(db: Session):
    return db.query(models.ProjectColumn).all()
