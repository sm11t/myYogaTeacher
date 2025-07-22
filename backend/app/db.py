from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from .config import DATABASE_URL

# create SQLAlchemy engine
engine = create_engine(DATABASE_URL, echo=False)

# session factory
SessionLocal = sessionmaker(bind=engine, autoflush=False, autocommit=False)
