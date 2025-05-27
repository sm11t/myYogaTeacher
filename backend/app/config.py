from pathlib import Path
from dotenv import load_dotenv
import os

# find the .env file one level up
env_path = Path(__file__).parent.parent / ".env"
load_dotenv(env_path)

DATABASE_URL = os.getenv("DATABASE_URL")
