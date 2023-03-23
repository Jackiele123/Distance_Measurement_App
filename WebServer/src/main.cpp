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

const char* ssid = "Jackie";  //replace
const char* password =  "mte201device"; //replace
const int dns_port = 53;
const int http_port = 80;
const int ws_port = 1337;


AsyncWebServer server(80);
AsyncWebSocket ws("/ws");

std::deque<float> voltageQueue;

int distance = 0;

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

int analogToDistance(float deltaV) {
  float distance = (0.1278* pow(deltaV,0.9427));
  speakValue(distance, "The Measure Distance is: ", " mm");
  return distance;
}

std::deque<float> voltageQueue;

int distance = 0;

void measure(){
 // read the input on analog pin GIOP36:
  int analogValue = analogRead(POT_PIN);
  // Rescale to potentiometer's voltage (from 0V to 3.3V):
  float voltage = floatMap(analogValue, 0, 4095, 0, 3300.0);

  // read the state of the pushbutton value:
  int buttonState = digitalRead(BUTTON_PIN);

  float tempVoltage = 0;
  if (buttonState == 0)
  {
    while(!digitalRead(BUTTON_PIN)){}
    for (int i = 0; i < 30; i++) {
      tempVoltage += analogRead(POT_PIN);
      delay(1);
    }
    tempVoltage = floatMap(tempVoltage/30, 0, 4095, 0, 3300.0);
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
    speakValue(deltaV, "Delta V: ", " mV");
    distance = analogToDistance(deltaV);
    delay(300);
  }
}

void setup()
{
  Serial.begin(115200);
  pinMode(BUTTON_PIN, INPUT);
 
  WiFi.begin(ssid, password);
 
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi..");
  }

  Serial.println(WiFi.localIP()); // 192.168.70.5
 
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request){
    request->send_P(200, "text/html", index_html, processor);
  });
  
  server.begin();
}



void loop(){}
