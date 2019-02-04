from flask import Blueprint
bp = Blueprint('database', __name__)
from app.db import routes
