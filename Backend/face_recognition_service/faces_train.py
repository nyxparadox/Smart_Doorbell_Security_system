#------IMPORTS-----------
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '2'
import pickle
import cv2 as cv
import numpy as np
from mtcnn.mtcnn import MTCNN
from keras_facenet import FaceNet




#-------FUNCTIONS--------
class FACELOADINGS:
    def __init__(self, directory):
        self.directory = directory
        self.target_size =  (160, 160)    # mtcnn use this 160x160 size for  batter performance
        self.detector = MTCNN()
        self.X = []
        self.Y = []

    def Face_Extraction(self, img_path):
        img = cv.imread(img_path)
        img = cv.cvtColor(img, cv.COLOR_BGR2RGB)
        x,y,w,h = self.detector.detect_faces(img)[0]['box']
        x,y = abs(x), abs(y)
        face_img = img[y:y+h,x:x+w]
        face_img_arr = cv.resize(face_img, self.target_size)
        return face_img_arr
    
    def Load_Faces(self,dir):
        FACES = []
        for img_name in os.listdir(dir):
            try:
                img_path = dir + img_name
                single_faces = self.Face_Extraction(img_path)
                FACES.append(single_faces)
            except Exception as e:
                print(f"[Skipped] {img_path} -> {e}")
        return FACES
        
    def Load_classes(self):
        for sub_dir in os.listdir(self.directory):
            path = self.directory + '/' + sub_dir + '/'
            FACES = self.Load_Faces(path)
            LABELS = [sub_dir for _ in range(len(FACES))]
            print(f"Succesfully Loaded {len(LABELS)}")
            self.X.extend(FACES)
            self.Y.extend(LABELS)
        return np.asarray(self.X), np.asarray(self.Y)
    

faceloadings = FACELOADINGS('/home/paradox/Documents/FLUTTER PROJECTS/Smart Doorbell Security System/Smart_Doorbell_Security_system/Backend/face_recognition_service/Faces_Dataset/train')
X,Y = faceloadings.Load_classes()
#------FACENET ---------------
embedder = FaceNet()

def GET_EMBEDDING(face_img):
    face_img= face_img.astype('float32')    # convert image in 3D vector
    # face_img = (face_img - 127.5) / 128.0
    face_img = np.expand_dims(face_img , axis=0)
    embedding =  embedder.embeddings(face_img)
    return embedding[0]

EMBEDDED_X = []
for img in X:
    EMBEDDED_X.append(GET_EMBEDDING(img))
EMBEDDED_X = np.asarray(EMBEDDED_X)


#--------------------------------------------------------
# saving Embedings file for future use 
np.savez_compressed('Faces_Embedding.npz', EMBEDDED_X,Y)
#--------------------------------------------------------


#------SVM MODEL--------------
from sklearn.preprocessing import LabelEncoder
encoder = LabelEncoder()
encoder.fit(Y)                       # we can say it tranform into unique string list 
Y = encoder.transform(Y)             # transformed string into numerical value 


from sklearn.model_selection import train_test_split
X_train, X_test, Y_train, Y_test = train_test_split(EMBEDDED_X, Y, shuffle=True, random_state= 17)

from sklearn.svm import SVC 
model = SVC(kernel='linear', probability=True)
model.fit(X_train,Y_train)

ypreds_train = model.predict(X_train)
ypreds_test =  model.predict(X_test)

from sklearn.metrics import accuracy_score
accuracy_score(Y_train, ypreds_train)
accuracy_score(Y_test, ypreds_test)


# we will save these svm model and ecodings for face recognization in face_artifacts.pkl file
with open('face_artifacts.pkl', 'wb') as f :
    pickle.dump(
        {
            'svm': model,
            'encoder': encoder
        }, f
    )
