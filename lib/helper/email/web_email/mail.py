from flask import Flask, request, jsonify
import smtplib
from email.message import EmailMessage
import os

app = Flask(__name__)

# Endpoint to send email
@app.route("/send_email", methods=["POST"])
def send_email():
    data = request.json
    sender_email = os.environ.get("EMAIL_USER")   # Use environment variables
    sender_password = os.environ.get("EMAIL_PASS")
    recipient_email = data.get("recipient_email")
    subject = data.get("subject")
    body = data.get("body")

    if not all([recipient_email, subject, body]):
        return jsonify({"error": "Missing fields"}), 400

    # Create the email
    msg = EmailMessage()
    msg["From"] = sender_email
    msg["To"] = recipient_email
    msg["Subject"] = subject
    msg.set_content(body)

    try:
        with smtplib.SMTP_SSL("smtp.gmail.com", 465) as smtp:
            smtp.login(sender_email, sender_password)
            smtp.send_message(msg)
        return jsonify({"message": "Email sent successfully!"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
