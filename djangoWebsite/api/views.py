import cv2
import json
from django.http import HttpRequest, HttpResponseRedirect, JsonResponse

IO_MAIN_LED = 17
CAMERA_ID = 0

asGPIO = False
try:
    import RPi.GPIO as GPIO
    asGPIO = True
except ImportError:
    class GPIO:
        BCM = None
        BOARD = None
        IN = None
        OUT = None
        HIGH = True
        LOW = False

class IO:
    @staticmethod
    def init():
        if asGPIO:
            GPIO.setmode(GPIO.BCM)
        else:
            print("[ERROR]: cannot import RPi.GPIO")

    @staticmethod
    def setup(channel, inOut):
        print("[INFO]: setup", channel, "as",  "INPUT" if inOut == GPIO.IN else "OUTPUT")
        if asGPIO:
            GPIO.setup(channel, inOut)

    @staticmethod
    def input(channel):
        print("[INFO]: read input", channel)
        if asGPIO:
            GPIO.input(channel)

    @staticmethod
    def output(channel, state):
        print("[INFO]: write", "HIGH" if state == GPIO.HIGH else "LOW", "on", channel)
        if asGPIO:
            GPIO.output(channel, state)

    @staticmethod
    def exit():
        print("[INFO]: cleanup GPIO")
        if asGPIO:
            GPIO.cleanup()

def runAtStartup():
    IO.init()
    IO.setup(IO_MAIN_LED, GPIO.OUT)
    IO.output(IO_MAIN_LED, GPIO.HIGH)

def runAtExit():
    IO.exit()

##### CONTROLS #####

### getter ###
def getInfo(request: HttpRequest):
	print("[WARN]: getInfo to do")  # TODO
	data = {
		'mainBattery': 45,
		'secondaryBattery': 93,
		'essence': 22,
	}
	return JsonResponse(data)

### setter ###
def setLed(request: HttpRequest):
    try:
        enable = int(request.GET['enable'])
    except Exception:
        enable = 0
    IO.output(IO_MAIN_LED, GPIO.LOW if enable else GPIO.HIGH)
    return HttpResponseRedirect(request.META.get('HTTP_REFERER'))

##### CAMERA #####
class VideoCamera(object):
    def __init__(self):
        print("[INFO]: start camera stream")
        self.video = cv2.VideoCapture(CAMERA_ID)
        # self.video = cv2.VideoCapture('video.mp4')

    def __del__(self):
        print("[INFO]: stop camera stream")
        self.video.release()

    def get_frame(self):
        success, image = self.video.read()
        ret, jpeg = cv2.imencode('.jpg', image)
        return jpeg.tobytes()


def cameraStream():
    camera = VideoCamera()
    while True:
        frame = camera.get_frame()
        yield (b'--frame\r\n'
               b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n\r\n')
