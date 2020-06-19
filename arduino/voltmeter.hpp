namespace Volt {
    class Voltmeter {
        // one analog pin
        public:
            Voltmeter(int voltPin) : _voltPin(voltPin), _maxVoltage(25) {}
            virtual ~Voltmeter() {}

            float getVoltage() {
                return analogRead(_voltPin) / 1023.0 * _maxVoltage;
            }

            void setMaxVoltage(float maxVoltage) {
                _maxVoltage = maxVoltage;
            }

        private:
            int _voltPin;
            float _maxVoltage;
    };
}

// Example /////////////////////////////////////////////////

/*
int voltPin = A0;
Volt::Voltmeter voltmeter(voltPin);

void setup() {
    Serial.begin(9600);
}

void loop() {
    Serial.println(voltmeter.getVoltage());
}
*/
