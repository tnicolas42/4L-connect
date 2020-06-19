import serial

arduino = serial.Serial('/dev/tty.usbmodem14201', 9600, timeout=.1)
while True:
	data = arduino.readline()[:-2]
	if data:
		data = data.decode("utf-8")
		print(data)