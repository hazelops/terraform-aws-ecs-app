# flask_web/app.py
import os
from flask import Flask

app = Flask(__name__)
appname = os.getenv('APP_NAME', 'ProxyTesting')
@app.route('/')
def hello_world():
    return appname


if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=3000)
