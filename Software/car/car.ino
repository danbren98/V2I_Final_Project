#include <WiFi.h>

// Wi-Fi credentials
const char *ssid = "TrafficLightAP";
const char *password = "COGmvTFXNOvCcnIc79Z9OFFMIvOWLuNCQOdVlPDhHCp"; // 256-bit secure

IPAddress server(192, 168, 4, 22);  // IP of server (e.g., ESP32 AP)
WiFiClient client;

int carid;

void connect_ap() {
  Serial.print("Connecting to ");
  Serial.println(ssid);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED){
    delay(500);
    Serial.println(".");
  }

  Serial.println("\nConnected to WiFi!");

  Serial.println("Waiting for server ...");
  while (!client.connect(server, 80)) {
    delay(100);
  }

  Serial.println("Connected to server");
  
}

int get_speed() {
  return random(20, 150);
}

void car(){
  int speed = get_speed();
  byte rssiByte = abs(WiFi.RSSI());

  // Send HTTP-like data
  Serial.printf("Sending from client: rssi=%d speed=%d\n", rssiByte, speed);
  client.printf("%d %d\n", rssiByte, speed);
  delay(10000);

  client.stop();
  Serial.println("Disconnected from server");
}

void setup() {
  Serial.begin(115200);
  delay(100);  // Give serial some time

  connect_ap();
  car();
}

void loop() {

}
