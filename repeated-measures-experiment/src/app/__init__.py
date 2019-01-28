# from app import models

import logging
import os
from flask import Flask, request, current_app
from flask_sqlalchemy import SQLAlchemy
# from flask_migrate import Migrate
from flask_bootstrap import Bootstrap
from flask_moment import Moment
from config import Config
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db

# db = SQLAlchemy()
# migrate = Migrate()
bootstrap = Bootstrap()
moment = Moment()


def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    # db.init_app(app)
    bootstrap.init_app(app)
    moment.init_app(app)
    print(os.path.dirname(os.path.abspath(__file__)))

    # init firebase
    cred = credentials.Certificate(Config.FIREBASE_SECRET_PATH)
    # cred = credentials.Certificate('./secret.json')
    firebase_app = firebase_admin.initialize_app(cred, {
        'databaseURL': 'https://beliefdrivenvis.firebaseio.com/'
    })

    from app.db import bp as db_bp
    app.register_blueprint(db_bp)

    # Register error handles in /errors
    from app.errors import bp as errors_bp
    app.register_blueprint(errors_bp)

    # from app.auth import bp as auth_bp
    # app.register_blueprint(auth_bp, url_prefix='/auth')

    # Register app.main, which contains most of our routes
    from app.main import bp as main_bp
    app.register_blueprint(main_bp)

    # if not app.debug and not app.testing:
    #     if not os.path.exists('logs'):
    #         os.mkdir('logs')
    #     file_handler = RotatingFileHandler('logs/microblog.log',
    #                                        maxBytes=10240, backupCount=10)
    #     file_handler.setFormatter(logging.Formatter(
    #         '%(asctime)s %(levelname)s: %(message)s '
    #         '[in %(pathname)s:%(lineno)d]'))
    #     file_handler.setLevel(logging.INFO)
    #     app.logger.addHandler(file_handler)

    #     app.logger.setLevel(logging.INFO)
    #     app.logger.info('Experiment startup')

    return app
