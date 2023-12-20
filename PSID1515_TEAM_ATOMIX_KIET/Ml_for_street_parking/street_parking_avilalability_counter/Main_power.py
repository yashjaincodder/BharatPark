import cv2
import matplotlib.pyplot as plt
import numpy as np

from util import get_parking_spots_bboxes, empty_or_not

def calculate_difference(img1, img2):
    return np.abs(np.mean(img1) - np.mean(img2))

mask_path = '../masking_image_for_grid/mask_uppp.png'
video_path = '../masking_image_for_grid/samples/parking_1920_1080_loop.mp4'

mask_img = cv2.imread(mask_path, 0)
cap = cv2.VideoCapture(video_path)

connected_components = cv2.connectedComponentsWithStats(mask_img, 4, cv2.CV_32S)
parking_spots = get_parking_spots_bboxes(connected_components)
spot_statuses = [None for _ in parking_spots]
differences = [None for _ in parking_spots]

previous_frame = None
frame_number = 0
ret = True
step = 30

while ret:
    ret, current_frame = cap.read()

    if not ret:
        break

    if frame_number % step == 0 and previous_frame is not None:
        for spot_index, spot in enumerate(parking_spots):
            x, y, w, h = spot

            if 0 <= y < current_frame.shape[0] and 0 <= x < current_frame.shape[1]:
                spot_crop = current_frame[y:y + h, x:x + w, :]
                differences[spot_index] = calculate_difference(spot_crop, previous_frame[y:y + h, x:x + w, :])
            else:
                differences[spot_index] = 0

    if frame_number % step == 0:
        if previous_frame is None:
            selected_spots = range(len(parking_spots))
        else:
            selected_spots = [j for j in np.argsort(differences) if differences[j] / np.amax(differences) > 0.4]

        for spot_index in selected_spots:
            spot = parking_spots[spot_index]
            x, y, w, h = spot

            if 0 <= y < current_frame.shape[0] and 0 <= x < current_frame.shape[1]:
                spot_crop = current_frame[y:y + h, x:x + w, :]
                spot_status = empty_or_not(spot_crop)
                spot_statuses[spot_index] = spot_status

    if frame_number % step == 0:
        previous_frame = current_frame.copy()

    for spot_index, spot in enumerate(parking_spots):
        spot_status = spot_statuses[spot_index]
        x, y, w, h = parking_spots[spot_index]

        if spot_status:
            current_frame = cv2.rectangle(current_frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
        else:
            current_frame = cv2.rectangle(current_frame, (x, y), (x + w, y + h), (0, 0, 255), 2)

    cv2.rectangle(current_frame, (80, 20), (550, 80), (0, 0, 0), -1)
    cv2.putText(current_frame, 'Available spots: {} / {}'.format(str(sum(spot_statuses)), str(len(spot_statuses))), (100, 60),
                cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 255, 255), 2)

    cv2.namedWindow('current_frame', cv2.WINDOW_NORMAL)
    cv2.imshow('current_frame', current_frame)
    if cv2.waitKey(25) & 0xFF == ord('q'):
        break

    frame_number += 1

cap.release()
cv2.destroyAllWindows()

