import cv2
import glob
import os

dirpath = os.path.join(os.getcwd(), "test_metricImg")
imgs = glob.glob(os.path.join(dirpath, '*.exr'))    
    
imgs = sorted(imgs)


for img_path in imgs:
    
    # input rgb
    hdr = cv2.imread(img_path, -1)
    cv2.imwrite(os.path.join(dirpath, os.path.split(img_path)[-1][:-3]+'hdr'), hdr) # rgb output