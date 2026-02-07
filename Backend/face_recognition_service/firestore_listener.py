import time
import firebase_admin 
from firebase_admin import credentials, firestore
from face_recognizer import recognize_from_url

cred  = credentials.Certificate('serviceAccountKey.json')
firebase_admin.initialize_app(cred)
print("FIREBASE INITIAlIZED...")

db = firestore.client()

def on_visitor_snapshot(col_snapshot, changes, read_time):
    # print("SNAPSHOT TRIGERRED....")
    for change in changes :
        # print("CHANGE TYPE: ", change.type.name)
        # print("DATA: ", change.document.to_dict())
        if change.type.name != "ADDED":
            continue

        doc = change.document
        visitor = doc.to_dict()

        if visitor.get("status") != "pending":
            continue

        image_url = visitor.get('imageUrl')
        if image_url is None:
            print("IMAGE NOT FOUND---")

        try:
            result = recognize_from_url(image_url)

            doc.reference.update({
                "Name": result['Name'],
                "Relation" : result['Relation'],
                "Recognized" : result['Recognized'],
                "status": "processed"

            })

            print(f" Processed visitor {doc.id}: {result}")

        except Exception as e:
            doc.reference.update({
                "status": "error",
                "ErrorMessage": str(e)
            })
            print(f"Error processing {doc.id}: {e}")

db.collection("visitors").on_snapshot(on_visitor_snapshot)
print("Listening for visitor events...")
while True:
    time.sleep(60)

