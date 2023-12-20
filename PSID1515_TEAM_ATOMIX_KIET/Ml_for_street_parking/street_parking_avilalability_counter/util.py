import pickle

from skimage.transform import resize
import numpy as np
import cv2


EMPTY_STATUS = True
NOT_EMPTY_STATUS = False

MODEL = pickle.load(open("model.p", "rb"))


def check_empty_status(spot_bgr):
    flat_data = []

    img_resized = resize(spot_bgr, (15, 15, 3))
    flat_data.append(img_resized.flatten())
    flat_data = np.array(flat_data)

    y_output = MODEL.predict(flat_data)

    if y_output == 0:
        return EMPTY_STATUS
    else:
        return NOT_EMPTY_STATUS


def get_parking_spots_bounding_boxes(connected_components):
    (totalLabels, label_ids, values, centroid) = connected_components

    parking_spots = []
    coef = 1
    for i in range(1, totalLabels):

        # Extract the coordinate points
        x1 = int(values[i, cv2.CC_STAT_LEFT] * coef)
        y1 = int(values[i, cv2.CC_STAT_TOP] * coef)
        w = int(values[i, cv2.CC_STAT_WIDTH] * coef)
        h = int(values[i, cv2.CC_STAT_HEIGHT] * coef)

        parking_spots.append([x1, y1, w, h])

    return parking_spots

