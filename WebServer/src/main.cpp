#include <Arduino.h>
#include "WiFi.h"
#include "ESPAsyncWebServer.h"
#include "WebSocketsServer.h"
#include "SPIFFS.h"
#include <iostream>
#include <string>
#include <deque>

#define POT_PIN 36
#define BUTTON_PIN 0

const char *ssid = "";     // Name for websocket
const char *password = ""; // Password for websocket
const char *msg_data_state = "toggleData";
const char *msg_get_data = "getDataState";

// AsyncWebServer server(80);
WebSocketsServer webSocket = WebSocketsServer(81);
char msg_v1[15];
char msg_v2[15];
char msg_dist[15];
int data_state = 0;

std::deque<float> voltageQueue;

float initialVolt = 0;
float finalVolt = 0;
float deltaVolt = 0;
float dist = 0;
uint8_t num;

float floatMap(float x, float in_min, float in_max, float out_min, float out_max)
{
  return (x - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

void speakValue(float value, char introText[], char unit[])
{
  Serial.println(introText);
  Serial.print(value);
  Serial.print(unit);
  Serial.println();
}

float analogToDistance(float deltaV)
{
  float distance = (0.1278 * pow(deltaV, 0.9427));
  speakValue(distance, "The Measure Distance is: ", " mm");
  return distance;
}

void getData()
{
  float tempVoltage = 0;
  for (int i = 0; i < 30; i++)
  {
    tempVoltage += analogRead(POT_PIN);
    delay(1);
  }
  tempVoltage = floatMap(tempVoltage / 30, 0, 4095, 0, 3300.0);
  voltageQueue.push_back(tempVoltage);
  initialVolt = voltageQueue.front();
  if (voltageQueue.size() == 2)
  {
    voltageQueue.pop_front();
    finalVolt = voltageQueue.front();
    voltageQueue.pop_front();
    deltaVolt = finalVolt - initialVolt;
    //    speakValue(deltaVolt, "Delta V: ", " mV");
    dist = (0.1278 * pow(deltaVolt, 0.9427));
    delay(100);
  }
}
void measure()
{
  float tempVoltage = 0;
  float distance = 0;

  if (digitalRead(BUTTON_PIN) == 0)
  {
    while (!digitalRead(BUTTON_PIN))
    {
    }
    for (int i = 0; i < 30; i++)
    {
      tempVoltage += analogRead(POT_PIN);
      delay(1);
    }
    tempVoltage = floatMap(tempVoltage / 30, 0, 4095, 0, 3300.0);
    speakValue(tempVoltage, "Measurement Recorded: ", " mV");
    voltageQueue.push_back(tempVoltage);
  }
  if (voltageQueue.size() == 2)
  {
    float v1 = voltageQueue.front();
    voltageQueue.pop_front();
    float v2 = voltageQueue.front();
    voltageQueue.pop_front();
    float deltaV = v2 - v1;
    sprintf(msg_v1, "Vi:%.4f\n", v1);
    Serial.print("Sending: ");
    Serial.println(msg_v1);
    webSocket.sendTXT(num, msg_v1);
    sprintf(msg_v2, "Vf:%.2f\n", v2);
    Serial.print("Sending: ");
    Serial.println(msg_v2);
    webSocket.sendTXT(num, msg_v2);
    speakValue(deltaV, "Delta V: ", " mV");
    distance = analogToDistance(deltaV);
    delay(300);
  }
}

void onWebSocketEvent(uint8_t client_num,
                      WStype_t type,
                      uint8_t *payload,
                      size_t length)
{

  // Figure out the type of WebSocket event
  switch (type)
  {

  // Client has disconnected
  case WStype_DISCONNECTED:
    Serial.printf("[%u] Disconnected!\n", client_num);
    break;

  // New client has connected
  case WStype_CONNECTED:
  {
    IPAddress ip = webSocket.remoteIP(client_num);
    Serial.printf("[%u] Connection from ", client_num);
    Serial.println(ip.toString());
    webSocket.sendTXT(client_num, "connected");
  }
  break;

  // Handle text messages from client
  case WStype_TEXT:

    // Print out raw message
    Serial.printf("[%u] Received text: %s\n", client_num, payload);
    num = client_num;
    // Toggle LED
    if (strcmp((char *)payload, "toggleData") == 0)
    {
      data_state = voltageQueue.size();
      getData();
      if (data_state == 0)
      {
        sprintf(msg_v1, "Vi:%.4f\n", initialVolt);
        Serial.print("Sending: ");
        Serial.println(msg_v1);
        webSocket.sendTXT(client_num, msg_v1);
      }
      else
      {
        sprintf(msg_v2, "Vf:%.2f\n", finalVolt);
        sprintf(msg_dist, "di:%.3f\n", dist);
        Serial.print("Sending: ");
        Serial.println(msg_v2);
        Serial.print("Sending: ");
        Serial.println(msg_dist);
        webSocket.sendTXT(client_num, msg_v2);
        webSocket.sendTXT(client_num, msg_dist);
      }
      // Message not recognized
    }
    else
    {
      Serial.println("[%u] Message not recognized");
    }
    break;

  // For everything else: do nothing
  case WStype_BIN:
  case WStype_ERROR:
  case WStype_FRAGMENT_TEXT_START:
  case WStype_FRAGMENT_BIN_START:
  case WStype_FRAGMENT:
  case WStype_FRAGMENT_FIN:
  default:
    break;
  }
}

void setup()
{
  Serial.begin(115200);
  pinMode(BUTTON_PIN, INPUT);

  Serial.println("Connecting to wifi");

  IPAddress apIP(192, 168, 0, 1);                             // Static IP for wifi gateway
  WiFi.softAPConfig(apIP, apIP, IPAddress(255, 255, 255, 0)); // set Static IP gateway on NodeMCU
  WiFi.softAP(ssid, password);                                // turn on WIFI

  // Print our IP address
  Serial.println();
  Serial.println("AP running");
  Serial.print("My IP address: ");
  Serial.println(WiFi.softAPIP());

  webSocket.begin();
  webSocket.onEvent(onWebSocketEvent);
  Serial.println("Websocket is started");
}

void loop()
{
  measure();
  webSocket.loop();
}
