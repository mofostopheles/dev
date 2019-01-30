import os

def rename(path,old,new):
    for f in os.listdir(path):
        os.rename(os.path.join(path, f), 
                  os.path.join(path, f.replace(old, new)))



rename(os.getcwd(), "H_1", "H")
# rename(os.getcwd(), "__1_1_1_1.wav", ".wav")