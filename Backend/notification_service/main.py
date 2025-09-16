import firebase_admin     # we use firebase admin sdk to send push notifications
from firebase_admin import credentials, firestore, messaging

cred = credentials.Certificate("serviceAccountKey.json")
firebase_admin.initialize_app(cred)

db = firestore.client()


# Firestore listener for new visitors
def on_snapshot(col_snapshot, changes, read_time):
    for change in changes:
        if change.type.name == 'ADDED':
            visitor = change.document.to_dict()
            device_id = visitor.get("deviceId")
            image_url = visitor.get("imageUrl")
            timestamp = visitor.get("timestamp")

            # Lookup user with this deviceId
            users_ref = db.collection("users").where("deviceId", "==", device_id).stream()
            for user_doc in users_ref:
                user = user_doc.to_dict()
                device_token = user.get("fcmToken")

                if device_token:
                    message = messaging.Message(
                        notification=messaging.Notification(
                            title="🔔 Someone's at your door!",
                            body=f"Visitor detected at {timestamp}",
                            image=image_url
                        ),
                        token=device_token
                    )

                    try:
                        response = messaging.send(message)
                        print(f" Notification sent to {user_doc.id}: {response}")
                    except Exception as e:
                        print("Error sending notification:", e)
                else:
                    print(f" No fcmToken found for user {user_doc.id}")

col_query = db.collection("visitors")
col_query.on_snapshot(on_snapshot)

print("🔍 Listening for visitors...")
while True:
    pass
