#include "voltmeter.hpp"  // ln -s ../includes/voltmeter.hpp voltmeter.hpp

#define FPS 2
#define TIME_LOOP_MS 1000 / FPS

Volt::Voltmeter mainBatteryVoltmetter(A0);
Volt::Voltmeter secondaryBatteryVoltmetter(A1);
Volt::Voltmeter essenceVoltmetter(A2);

struct Info {
	float mainBatteryVolt;
	float secondaryBatteryVolt;
	float essenceVolt;
};
struct Info info;

void setup() {
    Serial.begin(9600);
}

int val;
void update() {
	/* get the voltage */
	info.mainBatteryVolt = mainBatteryVoltmetter.getVoltage();
	info.secondaryBatteryVolt = secondaryBatteryVoltmetter.getVoltage();
	info.essenceVolt = essenceVoltmetter.getVoltage();
}

void sendFloat(String name, float value) {
	Serial.print(name);
	Serial.print(":");
	Serial.println(value);
}

void send() {
    sendFloat("mainBattery", info.mainBatteryVolt);
    sendFloat("secondaryBattery", info.secondaryBatteryVolt);
    sendFloat("essence", info.essenceVolt);
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
