import json
from typing import List
import uuid
from fastapi import APIRouter, Depends, HTTPException

import src.utils.cards
import src.utils.columns

from src.dependencies import *

from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder


router = APIRouter(
    prefix="/api",
    tags=["api"],
    dependencies=[Depends(get_db)],
    responses={404: {"description": "Not found"}},
)

"""
    Nombre de tâches actives pour une colonne donnée et une période donnée
"""

@router.get("/get_column_cards_by_time_range/{project_owner}/{project_id}/{column_id}", response_model=List[src.schemas.Card])
async def get_column_cards_by_time_range(project_owner: str, project_id: int, column_id: str, start_date: datetime, end_date: datetime, db : Session = Depends(get_db), page_number: int = 1, items_count: int = 20):
    offset = (page_number - 1) * items_count

    if page_number < 1:
        raise HTTPException(status_code=400, detail="page_number must be greater than 0")

    if items_count < 1:
        raise HTTPException(status_code=400, detail="items_count must be greater than 0")

    if start_date > end_date:
        raise HTTPException(status_code=400, detail="start_date must be less than end_date")

    if src.utils.columns.get_column_by_id(db, column_id, project_owner, project_id) is None:
        raise HTTPException(status_code=404, detail="Column not found with id: " + column_id)

    print(start_date.strftime("%Y-%m-%d %H:%M:%S"))
    print(end_date.strftime("%Y-%m-%d %H:%M:%S"))
    
    cards = src.utils.cards.get_cards_by_column_id_with_time_range(db, column_id,project_owner, project_id, start_date, end_date, items_count, offset)

    return JSONResponse(
            status_code=200,
            content={"page_id": page_number, "items_count": len(cards), "next_page_id": page_number+1, "cards": jsonable_encoder(cards)},
        )


"""
    Nombre de tâches dans chaque colonne pour une période donnée (snapshots du board Kanban entre certaines dates). 
"""

@router.get("/get_all_columns_with_cards_by_time_range/{project_owner}/{project_id}", response_model=List[src.schemas.ProjectColumn])
async def get_all_columns_with_cards_by_time_range(project_owner: str, project_id: int, start_date: datetime, end_date: datetime, db : Session = Depends(get_db), page_number: int = 1, items_count: int = 20):
    offset = (page_number - 1) * items_count

    if page_number < 1:
        raise HTTPException(status_code=400, detail="page_number must be greater than 0")

    if items_count < 1:
        raise HTTPException(status_code=400, detail="items_count must be greater than 0")

    if start_date > end_date:
        raise HTTPException(status_code=400, detail="start_date must be less than end_date")

    print(start_date.strftime("%Y-%m-%d %H:%M:%S"))
    print(end_date.strftime("%Y-%m-%d %H:%M:%S"))
    
    columns = src.utils.columns.get_all_columns_with_cards_by_time_range(db, start_date, end_date, items_count, offset)

    return JSONResponse(
            status_code=200,
            content={"page_id": page_number, "items_count": len(columns), "next_page_id": page_number+1, "columns": jsonable_encoder(columns)},
        )

"""
    Nombre de tâches dans chaque colonne sans tenir compte de la date
"""
@router.get("/get_all_columns_with_cards/{project_owner}/{project_id}", response_model=List[src.schemas.ProjectColumn])
async def get_all_columns_with_cards(project_owner: str, project_id: int, db : Session = Depends(get_db), page_number: int = 1, items_count: int = 20):
    offset = (page_number - 1) * items_count

    if page_number < 1:
        raise HTTPException(status_code=400, detail="page_number must be greater than 0")

    if items_count < 1:
        raise HTTPException(status_code=400, detail ="items_count must be greater than 0")

    # columns = src.utils.columns.get_all_columns(db)
    columns = src.utils.columns.get_all_columns_with_cards(db)

    if columns is None:
        raise HTTPException(status_code=404, detail="Columns not found")

    return JSONResponse(
            status_code=200,
            content={"page_id": page_number, "items_count": len(columns), "next_page_id": page_number+1, "columns": jsonable_encoder(columns)},
        )


"""
    Nombre de tâches dans une colonne donnée sans tenir compte de la date
"""
@router.get("/get_column_cards/{project_owner}/{project_id}/{column_id}", response_model=List[src.schemas.Card])
async def get_column_cards(project_owner: str, project_id: int, column_id: str, db : Session = Depends(get_db), page_number: int = 1, items_count: int = 20):
    offset = (page_number - 1) * items_count

    if page_number < 1:
        raise HTTPException(status_code=400, detail="page_number must be greater than 0")

    if items_count < 1:
        raise HTTPException(status_code=400, detail="items_count must be greater than 0")

    if src.utils.columns.get_column_by_id(db, column_id) is None:
        raise HTTPException(status_code=404, detail="Column not found with id: " + column_id)

    cards = src.utils.cards.get_cards_by_column_id(db, column_id, project_owner, project_id, items_count, offset)

    return JSONResponse(
            status_code=200,
            content={"page_id": page_number, "items_count": len(cards), "next_page_id": page_number+1, "cards": jsonable_encoder(cards)},
        )


# """
#     Nombre de tâches complétés pour une période donnée 
# """
# @router.get("/get_completed_cards_by_time_range/{project_owner}/{project_id}", response_model=List[src.schemas.Card])
# async def get_completed_cards_by_time_range(project_owner: str, project_id: int, start_date: datetime , end_date: datetime, db : Session = Depends(get_db), page_number: int = 1, items_count: int = 20):
#     offset = (page_number - 1) * items_count

#     if page_number < 1:
#         raise HTTPException(status_code=400, detail="page_number must be greater than 0")

#     if items_count < 1:
#         raise HTTPException(status_code=400, detail="items_count must be greater than 0")

#     if start_date > end_date:
#         raise HTTPException(status_code=400, detail="start_date must be less than end_date")

#     cards = src.utils.cards.get_completed_cards_by_time_range(db, start_date, end_date, items_count, offset)

#     return JSONResponse(
#             status_code=200,
#             content={"page_id": page_number, "items_count": len(cards), "next_page_id": page_number+1, "cards": jsonable_encoder(cards)},
#         )