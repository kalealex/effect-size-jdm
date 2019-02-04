from flask import render_template, request, jsonify, make_response
import random
from app.db import bp
import firebase_admin
from firebase_admin import credentials
from firebase_admin import db


@bp.route('/api/v1.0/createUser', methods=['GET', 'POST'])
def api_endpoint():
    data = request.get_json(force=True)

    ref = db.reference('/workers/' + data["workerId"])
    # todo: create some type of token here
    token = ''.join(random.choice('0123456789ABCDEF') for i in range(16))

    ref.push().set({
        'workerId': data["workerId"],
        'token': token
    })

    return make_response(jsonify({data["workerId"], token}), 200)

@bp.route('/api/v1.0/saveTrial', methods=['GET', 'POST'])
def saveTrial():
    data = request.get_json(force=True)
    ref = db.reference('/workers/' + data["workerId"] + '/responses/')

    ## Use ref.get and ref.push().set() to set the data here
    ref.get()

    return make_response('Successfully saved', 200)

@bp.route('/api/v1.0/save_survey', methods=['GET', 'POST'])
def save_survey():
    # if (response === 'GET'):
    #     return 'the data'

    # todo: get json from passed form or from post request
    ref = db.reference('/survey/' + 'some uid variable instead')
    # todo: save survey json as a string in the database
    # todo: probaby want to mock the survey response as a json object, then save each field as things in the db
    response = make_response(data)
    return response()
