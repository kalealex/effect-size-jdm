## Prerequisites
Installation of Python 3.6.0>

### Setting Up
To run, first create and start a virtual enviornment. I prefer to call my virtual environments venv, but do your thing.
```
python3 -m venv venv
source venv/bin/activate
```
Your shell name should have a (venv) to dictate that you are in the virtual environment. Make sure you activate your virtual environment each time you are developing.

Next, install all the dependencies in the requirements.txt file. This will probably take some time
```
pip install -r requirements.txt
```

Since we want to run Flask, we will use the built in flask cli tool. First, we need to set our environment variables.
```
export FLASK_APP=application.py     # tells flask which file is the entry point
export FLASK_ENV=development        # tells flask to start the server in development mode for hot module reloading
```

### Running the dev server
To run the development server simply:
```
flask run
```

or if you haven't done the above,
```
source venv/bin/activate
export FLASK_APP=application.py
export FLASK_ENV=development
flask run
```

If you are running into an error with ```flask run``` it is likely because you either 1) Haven't activated your virtual environment or 2) You haven't exported your bash variables.

### Setup Firebase
If you haven't created a Firebase account yet, create one. Navigate to the console [https://console.firebase.google.com/] and create a new project for this interface.

#### Create Firebase Database
After it's been loaded, go to the Database tab on the left hand navigation bar. Scroll down until you see "Choose Realtime Database", and click the Create Database button found in that card. For ease of use, allow it to start in test mode.

#### Export Database secret key
Finally, we need to connect to the database. Click on the gear at the top of the settings toolbar on the left, and navigate to "Project Settings". Go to "Service Accounts", the 4th tab from the left of the settings page. Generate a new private key, and put that key in "secret" folder in this project and rename it to secret.json.

#### Update Database connect code
The database URL needs to be updated. In your project structure, navigate to src/app/__init__.py. Look for the 'databaseURL' variable, and set it equal to whatever the public url for your firebase database is.