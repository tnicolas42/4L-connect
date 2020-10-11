import cv2
import serial
import json
from djangoWebsite import logging as log
from django.http import HttpRequest, HttpResponseRedirect, JsonResponse

IO_MAIN_LED = 17
CAMERA_ID = 0

#ARDUINO_PORT = '/dev/tty.usbmodem14201'
ARDUINO_PORT = '/dev/arduinobase'
ARDUINO_BAUD_RATE = 9600

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
            log.err("cannot import RPi.GPIO")

    @staticmethod
    def setup(channel, inOut):
        log.info("setup", channel, "as",  "INPUT" if inOut == GPIO.IN else "OUTPUT")
        if asGPIO:
            GPIO.setup(channel, inOut)

    @staticmethod
    def input(channel):
        log.info("read input", channel)
        if asGPIO:
            GPIO.input(channel)

    @staticmethod
    def output(channel, state):
        log.info("write", "HIGH" if state == GPIO.HIGH else "LOW", "on", channel)
        if asGPIO:
            GPIO.output(channel, state)

    @staticmethod
    def exit():
        log.info("cleanup GPIO")
        if asGPIO:
            GPIO.cleanup()


class Arduino:
    arduino = None
    allFloatValues = {
        'mainBattery': 0,
        'secondaryBattery': 0,
        'essence': 0,
    }
    errCount = 0

    @staticmethod
    def init():
        if Arduino.isInit():
            return  # init already called
        try:
            Arduino.arduino = serial.Serial(ARDUINO_PORT, ARDUINO_BAUD_RATE, timeout=.1)
        except:
            log.err("unable to open arduino on port %s, baud rate = %d" % (ARDUINO_PORT, ARDUINO_BAUD_RATE))

    @staticmethod
    def isInit():
        return Arduino.arduino is not None

    @staticmethod
    def read():
        if Arduino.errCount >= 5:
            log.info("trying to restart arduino")
            Arduino.errCount = 0
            Arduino.arduino = None
            Arduino.init()
        log.info("reading arduino data")
        if Arduino.arduino is None:
            log.err("arduino is not connected")
            Arduino.errCount += 1
            return
        try:
            data = 1
            i = 0
            while data and i < 10:
                i += 1
                try:
                    data = Arduino.arduino.readline()[:-2]
                    Arduino.errCount = 0
                except:
                    log.err("error when reading arduino data")
                    Arduino.errCount += 1
                if data is None:
                    continue
                data = data.decode("utf-8")
                if data is '':
                    continue
                data = data.split(":")
                if len(data) != 2:
                    log.err("invalid format in arduino data: '" + ":".join(data) + "'")
                else:
                    if data[0] in Arduino.allFloatValues:
                        try:
                            Arduino.allFloatValues[data[0]] = float(data[1])
                        except:
                            log.err("in arduino parsing -> unable to convert %s to float" % (data[1]))
            if i == 10:
                try:
                    Arduino.arduino.readlines()
                except:
                    log.err("error when reading arduino data")
        except:
            log.err("unexpected error in arduino parsing")

    @staticmethod
    def getFloat(name):
        if name in Arduino.allFloatValues:
            return Arduino.allFloatValues[name]
        else:
            log.err("invalid name %s (reading arduino values)" % (name))

##### CONTROLS #####

def runAtStartup():
    IO.init()
    IO.setup(IO_MAIN_LED, GPIO.OUT)
    IO.output(IO_MAIN_LED, GPIO.HIGH)
    Arduino.init()

def runAtExit():
    IO.exit()

def percentFromVoltage(voltage):
    percent = 0
    if voltage <= 10.5:
        percent = 0
    elif voltage <= 11.31:
        percent = 10
    elif voltage <= 11.58:
        percent = 20
    elif voltage <= 11.75:
        percent = 30
    elif voltage <= 11.9:
        percent = 40
    elif voltage <= 12.06:
        percent = 50
    elif voltage <= 12.20:
        percent = 60
    elif voltage <= 12.32:
        percent = 70
    elif voltage <= 12.42:
        percent = 80
    elif voltage <= 12.5:
        percent = 90
    elif voltage <= 12.6:
        percent = 100
    elif voltage >= 12.6:
        percent = 100
    return percent

### getter ###
def getInfo(request: HttpRequest):
    Arduino.read()
    data = {
        'mainBatteryVolt': Arduino.getFloat('mainBattery'),
        'mainBatteryPercent': percentFromVoltage(Arduino.getFloat('mainBattery')),
        'secondaryBatteryVolt': Arduino.getFloat('secondaryBattery'),
        'secondaryBatteryPercent': percentFromVoltage(Arduino.getFloat('secondaryBattery')),
        'essence': Arduino.getFloat('essence'),
    }
    print(data)
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
        log.info("start camera stream")
        self.video = cv2.VideoCapture(CAMERA_ID)
        # self.video = cv2.VideoCapture('video.mp4')

    def __del__(self):
        log.info("stop camera stream")
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
