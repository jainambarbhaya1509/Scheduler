from flask import Flask, request, jsonify
import smtplib
from email.message import EmailMessage
import os
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route("/send_email", methods=["POST"])
def send_email():
    data = request.json

    # Sender details
    sender_email = "pranavvdv@gmail.com"
    sender_password = "ucfnymzzeuwmrcip"
    sender_name = "Scheduler App"

    # Email content
    recipient_email = data.get("email")
    subject = data.get("subject")
    body = data.get("body")

    if not all([recipient_email, subject, body]):
        return jsonify({"error": "Missing fields"}), 400

    # Build email
    msg = EmailMessage()
    msg["From"] = f"{sender_name} <{sender_email}>"   # <--- FIXED
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
    port = int(os.environ.get("PORT", 8080))
    app.run(host="0.0.0.0", port=port)
