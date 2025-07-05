#include <Arduino.h>
#include <WiFi.h>
#include <WiFiClient.h>
#include <esp_wifi.h>
#include <SPI.h>
#include <optional>

const int EN_PIN = 9;  // Reset pin
const int SS_PIN = 10; // Chip Select pin

IPAddress local_IP(192, 168, 4, 22);
IPAddress gateway(192, 168, 4, 9);
IPAddress subnet(255, 255, 255, 0);
WiFiServer server(80);

#define BUFFER_SIZE 30
char read_buffer[BUFFER_SIZE] = {0};

void clear_buffer()
{
  memset(read_buffer, 0, BUFFER_SIZE); 
}

const char *ssid = "NorthTrafficLightAP";
const char *password = "COGmvTFXNOvCcnIc79Z9OFFMIvOWLuNCQOdVlPDhHCp"; // 256-bit secure

void wifi_setup()
{
  Serial.print("Setting soft-AP configuration ... ");
  Serial.println(WiFi.softAPConfig(local_IP, gateway, subnet) ? "Success" : "Failed");

  Serial.print("Starting soft-AP ... ");
  Serial.println(WiFi.softAP(ssid, password) ? "Success" : "Failed");

  Serial.print("Soft-AP IP address = ");
  Serial.println(WiFi.softAPIP());

  server.begin();
}

void spi_setup()
{
  pinMode(SS_PIN, OUTPUT);
  digitalWrite(SS_PIN, HIGH);
  SPI.begin(6, 2, 7, SS_PIN); // SCLK, MISO, MOSI, SS

  Serial.println("ESP32-C3 SPI Master is set.");
}

void spi_write(uint16_t data)
{
  SPI.beginTransaction(SPISettings(20000000, MSBFIRST, SPI_MODE0));
  digitalWrite(SS_PIN, LOW);
  SPI.transfer16(data);
  digitalWrite(SS_PIN, HIGH);
  SPI.endTransaction();

  Serial.print("Sent: 0x");
  Serial.println(data, HEX);
}

void send_client_data(uint8_t carid, uint8_t speed, uint8_t power)
{
  spi_write(32768 + 512 + 128 + carid);
  delay(1);
  spi_write(32768 + 768 + speed);
  delay(1);
  spi_write(32768 + 1024 + power);
  delay(1);
}

void remove_car(uint8_t carid)
{
  spi_write(32768 + 512 + 0 + carid);
  delay(1);
  Serial.printf("Client %d disconnected\n", carid);
}

#define MAX_CARS 4
std::optional<WiFiClient> clients[MAX_CARS]; // Array of clients
int clients_ids[MAX_CARS];                   // Array of clients

void setup()
{
  Serial.begin(115200);
  delay(100); // Let Serial stabilize

  wifi_setup();
  spi_setup();
}

void loop()
{
  for (size_t i = 0; i < MAX_CARS; ++i)
  {
    std::optional<WiFiClient> &client = clients[i];
    if (!client.has_value())
    {
      client = server.available();
      if (!client.value())
      {
        client = std::nullopt;
      } 
      else {
        clients_ids[i] = random(32) * MAX_CARS + i;
        Serial.printf("Client [id:%d] connected\n", clients_ids[i]);
      }
    }
    else if (!client->connected())
    {
      Serial.printf("Client [id:%d] disconnected\n", clients_ids[i]);
      remove_car(clients_ids[i]);
      client->stop();
      client = std::nullopt;
    }
    else if (client->available())
    {
      clear_buffer();
      client->read((uint8_t *)(read_buffer), sizeof(read_buffer) - 1);
      int speed = 0, rssi = 0;
      sscanf(read_buffer, "%d %d", &rssi, &speed);
      Serial.printf("Got from client [id:%d]: speed=%d rssi=%d\n", clients_ids[i], speed, rssi);
      send_client_data(clients_ids[i], speed, rssi);
    }
    delay(10);
  }
}
