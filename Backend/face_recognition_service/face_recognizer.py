#---------imports--------------------
import os 
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
import cv2 as cv
import pickle
import requests
import numpy as np
from mtcnn.mtcnn import MTCNN
from keras_facenet import FaceNet



"""
#------Initialization
detector = MTCNN()
embedder = FaceNet()



with open('face_artifacts.pkl', 'rb') as f :
    artifacts = pickle.load(f)

model = artifacts['svm']
encoder = artifacts['encoder']


#---------function----------
def GET_EMBEDDING(face_img):
    face_img = face_img.astype('float32')      # 3D vector
    face_img = np.expand_dims(face_img, axis=0) 
    embedding = embedder.embeddings  (face_img)
    return embedding[0]




path = "/home/paradox/Pictures/PHOTOS /KSHITIJ & ANSH/IMG_20240802_193157.jpg"
img = cv.imread(path)
display_img = img.copy()
img = cv.cvtColor(img, cv.COLOR_BGR2RGB)
x,y,w,h = detector.detect_faces(img)[0]['box']
face_img = img[y:y+h, x:x+w]
face_img_arr = cv.resize(face_img, (160,160))
test_img = GET_EMBEDDING(face_img_arr)


test_img = [test_img]
ypreds = model.predict(test_img)
probs = model.predict_proba(test_img)
confidence = float(np.max(probs))
person_name = encoder.inverse_transform(ypreds)




# # displaying imgage -----------
# cv.rectangle(display_img, (x,y), (x+w,y+h), (0,255,0),3)
# cv.putText(display_img, str(person_name[0]), (x,y-10), cv.FONT_HERSHEY_COMPLEX, 1.5, (0,255,0),2)
# display_img = cv.resize(display_img, (1000,1000))
# cv.imshow("Face Recognized Image", display_img)
# cv.waitKey(0)
# cv.destroyAllWindows()


#-------X---------X----------X---------------X-------------
print(f"name value_index: {ypreds}")
print(f"Identified Person: {person_name}")
print(f"confidence Level: {confidence}")
"""







#=======================================================================================

#-----------Initialization-----------------------
detector  = MTCNN()
embedder = FaceNet()


#-------opening trained_face model file-----------
with open('face_artifacts.pkl', 'rb') as f:
    artifacts = pickle.load(f)
model = artifacts['svm']
encoder = artifacts['encoder']


#-----------------------------------------------
def GET_EMBEDDEING(face_img):
    face_img = face_img.astype('float32')
    # face_img = (face_img - 127.5) / 128.0
    face_img =  np.expand_dims(face_img, axis=0)
    embedding = embedder.embeddings(face_img)
    return embedding[0]


#-------------------------------------------------
def recognize_from_url(img_url):
    try:
        response = requests.get(img_url, timeout=10)
        img_bytes = np.asarray(bytearray(response.content), dtype=np.uint8)
        img = cv.imdecode(img_bytes, cv.IMREAD_COLOR)

        if img is None:
            raise ValueError('Invalid Image URl')
        
        img_RGB = cv.cvtColor(img, cv.COLOR_BGR2RGB)
        faces = detector.detect_faces(img_RGB)

        if len(faces) == 0:
            return{
                "Name": "no face",
                "Relation": "None",
                "Recognized": False
            }

        x,y,w,h = faces[0]['box']
        x,y = abs(x), abs(y)
        face_img = img_RGB[y:y+h, x:x+w]
        face_img_res = cv.resize(face_img, (160,160))
        test_img = GET_EMBEDDEING(face_img_res)

        test_img = [test_img]
        ypreds = model.predict(test_img)
        probs = model.predict_proba(test_img)
        confidence = float(np.max(probs))

        
        Relation = "UNKNOWN"

        if confidence < 0.8 :
            return{
                "Name": "UNKNOWN",
                "Relation": " ",
                "Recognized": False
            }
        
        person = encoder.inverse_transform(ypreds)
        name = str(person[0])

        # if name == "Divyansh kumar":
        #     Relation = "Brother"
        # elif name == "Rohit Singh":
        #     Relation = "myself"
        
        Relation_Map = {
            "Divyansh Kumar": "Brother",
            "Rohit Singh": "Myself"
        }

        Relation = Relation_Map.get(name, "UNKNOWN")

        return {
            "Name": name,
            "Relation": Relation,
            "Recognized": True
        }
    except Exception as e:
        return{
            "Name": "ERROR",
            "Relation" : "",
            "Recognized" : False,
            "ERROR": str(e)
        }


