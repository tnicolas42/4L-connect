#include "voltmeter.hpp"  // ln -s ../includes/voltmeter.hpp voltmeter.hpp

#define FPS 2
#define TIME_LOOP_MS 1000 / FPS

Volt::Voltmeter voltmeterA0(A0);  // main battery
Volt::Voltmeter voltmeterA1(A1);  // 12V alimentation
Volt::Voltmeter voltmeterA2(A2);  // essence

struct Info {
	float voltA0;
	float voltA1;
	float voltA2;
};
struct Info info;

void setup() {
    Serial.begin(9600);
}

int val;
void update() {
	/* get the voltage */
	info.voltA0 = voltmeterA0.getVoltage();
	info.voltA1 = voltmeterA1.getVoltage();
	info.voltA2 = voltmeterA2.getVoltage();
}

void sendFloat(String name, float value) {
	Serial.print(name);
	Serial.print(":");
	Serial.println(value);
}

void send() {
    sendFloat("A0", info.voltA0);
    sendFloat("A1", info.voltA1);
    sendFloat("A2", info.voltA2);
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
