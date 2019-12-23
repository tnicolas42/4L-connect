from django.shortcuts import render
from django.http import HttpRequest, HttpResponseRedirect

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


IO_MAIN_LED = 17

def runAtStartup():
	IO.init()
	IO.setup(IO_MAIN_LED, GPIO.OUT)
	IO.output(IO_MAIN_LED, GPIO.LOW)

def home(request: HttpRequest):
	return render(request, 'mainApp/home.html')

def setLed(request: HttpRequest):
	try:
		enable = int(request.GET['enable'])
	except Exception:
		enable = 0
	IO.output(IO_MAIN_LED, GPIO.HIGH if enable else GPIO.LOW)
	return HttpResponseRedirect(request.META.get('HTTP_REFERER'))
