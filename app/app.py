from flask import Flask
app = Flask(__name__)

@app.route("/")
def hello_world():

    with open('/mnt/secrets-store/mysecret', 'r') as file:
        secret = file.read().strip()

        return "Hello, World this is my secret: " + str(secret)


if __name__ == "__main__":
    app.run(host='0.0.0.0')