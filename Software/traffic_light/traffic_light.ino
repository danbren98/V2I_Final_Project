#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClient.h>
#include <esp_wifi.h> 
#include <SPI.h>

const int EN_PIN = 9;   // Reset pin
const int SS_PIN = 10;  // Chip Select pin

IPAddress local_IP(192, 168, 4, 22);
IPAddress gateway(192, 168, 4, 9);
IPAddress subnet(255, 255, 255, 0);
WiFiServer server(80);

#define BUFFER_SIZE 30
char read_buffer[BUFFER_SIZE] = {0};

void clear_buffer() {
  memset(read_buffer, 0, BUFFER_SIZE);  // ✅ FIXED this line
}

const char *ssid = "TrafficLightAP";
const char *password = "COGmvTFXNOvCcnIc79Z9OFFMIvOWLuNCQOdVlPDhHCp"; // 256-bit secure

void wifi_setup() {
  Serial.print("Setting soft-AP configuration ... ");
  Serial.println(WiFi.softAPConfig(local_IP, gateway, subnet) ? "Success" : "Failed");

  Serial.print("Starting soft-AP ... ");
  Serial.println(WiFi.softAP(ssid, password) ? "Success" : "Failed");

  Serial.print("Soft-AP IP address = ");
  Serial.println(WiFi.softAPIP());

  server.begin();
}

void spi_setup() {
	pinMode(SS_PIN, OUTPUT);
	digitalWrite(SS_PIN, HIGH);
	SPI.begin(6, 2, 7, SS_PIN);  // SCLK, MISO, MOSI, SS

	Serial.println("ESP32-C3 SPI Master is set.");
}

void spi_write(uint16_t data) {
  SPI.beginTransaction(SPISettings(20000000, MSBFIRST, SPI_MODE0));
	digitalWrite(SS_PIN, LOW);
	SPI.transfer16(data);
	digitalWrite(SS_PIN, HIGH);
	SPI.endTransaction();

  Serial.print("Sent: 0x");
	Serial.println(data, HEX);
}


void send_client_data(uint8_t carid, uint8_t speed, uint8_t power) {
  spi_write(32768 + 512 + 128 + carid);
  delay(1);
  spi_write(32768 + 768 + speed);
  delay(1);
  spi_write(32768 + 1024 + power);
  delay(1);
}

void remove_car(uint8_t carid) {
  spi_write(32768 + 512 + 0 + carid);
  delay(1);
  Serial.printf("Client %d disconnected\n", carid);
}

void setup() {
  Serial.begin(115200);
  delay(100);  // Let Serial stabilize

  wifi_setup();
  spi_setup();
}

void loop() {
  delay(1000);

  WiFiClient client = server.available();
  if (!client) {
    return;
  }

  Serial.println("Connected to client");
  while (client.connected()) {
    delay(100);
    if(!client.available()) {
      continue;
    }
    clear_buffer();
    client.read((uint8_t*)(read_buffer), sizeof(read_buffer) - 1);
    int speed = 0, rssi = 0;
    sscanf(read_buffer, "%d %d", &rssi, &speed);
    Serial.printf("Got from client: %d %d\n", speed, rssi);
    send_client_data(1, speed, rssi);
  }

  remove_car(1);
  client.stop();
}
