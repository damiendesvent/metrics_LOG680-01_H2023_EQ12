import databases
import sqlalchemy

from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

host = "172.18.0.2"
user = "postgres"
password = "log680"
db = "metrics"
DATABASE_URL = f"postgresql://{user}:{password}@{host}/{db}"

# DATABASE_URL = 'postgresql://postgres:glassfood@localhost:5432/wanderpi'
# DATABASE_URL = "sqlite:///glassfood.sqlite"
# DATABASE_URL = "postgresql://user:password@postgresserver/db"

database = databases.Database(DATABASE_URL)

metadata = sqlalchemy.MetaData()

# notes = sqlalchemy.Table(
#     "notes",
#     metadata,
#     sqlalchemy.Column("id", sqlalchemy.Integer, primary_key=True),
#     sqlalchemy.Column("text", sqlalchemy.String),
#     sqlalchemy.Column("completed", sqlalchemy.Boolean),
# )


# engine = sqlalchemy.create_engine(
#     DATABASE_URL, connect_args={"check_same_thread": False}
# )

engine = sqlalchemy.create_engine(
    DATABASE_URL
)


SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()
