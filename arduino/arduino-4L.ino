#include "voltmeter.hpp"  // ln -s ../includes/voltmeter.hpp voltmeter.hpp

#define FPS 20
#define TIME_LOOP_MS 1000 / FPS

int voltPin = A0;
Volt::Voltmeter voltmeter(voltPin);

struct Info {
	float voltage;
};
struct Info info;

void setup() {
    Serial.begin(9600);

	/* write a voltage //! to delete */
	pinMode(7, OUTPUT);
}

int val;
void update() {
	/* write a voltage //! to delete */
	val = random() % 2;
	digitalWrite(7, val);

	/* get the voltage */
	info.voltage = voltmeter.getVoltage();
}

void send() {
	Serial.println("<<<");
    Serial.println(val);
    Serial.println(info.voltage);
	Serial.println(">>>");
}


int lastLoop = 0;
void loop() {
	update();
	send();

	/* run as a certain rate */
	int timeElapsed = millis() - lastLoop;
	if (timeElapsed < TIME_LOOP_MS) {
		delay(TIME_LOOP_MS - timeElapsed);
	}
	lastLoop = millis();
}
