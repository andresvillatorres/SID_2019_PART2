/*

  This example connects to an unencrypted WiFi network.
  Then it pri nts the  MAC address of the WiFi shield,
  the IP address obtained, and other network details.

  Circuit:
   WiFi shield attached arduino mk1000 or similar

  created 13 July 2010
  by dlf (Metodo2 srl)
  modified 31 May 2012
  by Tom Igoe

  extended  Nov - Jan 2019/20
  by Andrés Villa Torres
  ************************
  ************************
  ************************
  example to connect to an arduino mk1000 sending IMU Sensor Data (HMC5883L)
  with Adafruit Library and opening a wifi server
  Written for Sonic Interaction Design HS2019 - Mapping Gestures
  Interaction Design
  ZHdK
  By ndr3s -v -t (Andrés Villa Torres)

*/
#include <SPI.h>
#include <WiFi101.h>

#include <CapacitiveSensor.h>


CapacitiveSensor   cs_4_8 = CapacitiveSensor(4, 8);

#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_HMC5883_U.h>


#include "arduino_secrets.h"

/* Assign a unique ID to this sensor at the same time */
Adafruit_HMC5883_Unified mag = Adafruit_HMC5883_Unified(12345);

///////please enter your sensitive data in the Secret tab/arduino_secrets.h
char ssid[] = SECRET_SSID;        // your network SSID (name)
char pass[] = SECRET_PASS;    // your network password (use for WPA, or use as key for WEP)
int status = WL_IDLE_STATUS;     // the WiFi radio's status

WiFiServer server(80); // define server

void displaySensorDetails()
{
  sensor_t sensor;
  mag.getSensor(&sensor);
  Serial.println("------------------------------------");
  Serial.print  ("Sensor:       "); Serial.println(sensor.name);
  Serial.print  ("Driver Ver:   "); Serial.println(sensor.version);
  Serial.print  ("Unique ID:    "); Serial.println(sensor.sensor_id);
  Serial.print  ("Max Value:    "); Serial.print(sensor.max_value); Serial.println(" uT");
  Serial.print  ("Min Value:    "); Serial.print(sensor.min_value); Serial.println(" uT");
  Serial.print  ("Resolution:   "); Serial.print(sensor.resolution); Serial.println(" uT");
  Serial.println("------------------------------------");
  Serial.println("");
  delay(50);
}



void setup() {
  //Initialize serial and wait for port to open:
  Serial.begin(9600);


  //  cs_4_8.set_CS_AutocaL_Millis(0xFFFFFFFF);     // turn off autocalibrate on channel 1 - just as an example

  Serial.println("HMC5883 Magnetometer Test + Connect to WPA"); Serial.println("");

  /* Initialise the sensor */
  mag.begin();
  if (!mag.begin())
  {
    /* There was a problem detecting the HMC5883 ... check your connections */
    Serial.println("Ooops, no HMC5883 detected ... Check your wiring!");
    while (1);
  }

  /* Display some basic information on this sensor */
  displaySensorDetails();

  //  while (!Serial) {
  //    ; // wait for serial port to connect. Needed for native USB port only
  //  }

  // check for the presence of the shield:
  if (WiFi.status() == WL_NO_SHIELD) {
    Serial.println("WiFi shield not present");
    // don't continue:
    while (true);
  }
  

  // attempt to connect to WiFi network:
  while ( status != WL_CONNECTED) {
    Serial.print("Attempting to connect to WPA SSID: ");
    Serial.println(ssid);
    // Connect to WPA/WPA2 network:
    status = WiFi.begin(ssid, pass);

    // wait 10 seconds for connection:
    delay(500);
  }

  /* you're connected now, so print out the data: */
  server.begin();           /* start server at port 888 */
  Serial.print("You're connected to the network");
  printCurrentNet();

  printWiFiData();
  delay(5000);
}

void tryToConnect() {
  // attempt to connect to WiFi network:
  while ( status != WL_CONNECTED) {
    Serial.print("Attempting to connect to WPA SSID: ");
    Serial.println(ssid);
    // Connect to WPA/WPA2 network:
    status = WiFi.begin(ssid, pass);

    // wait 10 seconds for connection:
    delay(500);
  }
}

void loop() {


  int testVal = 0;
  WiFiClient client = server.available();
  if (client) {
    //    cs_4_8.set_CS_AutocaL_Millis(0xFFFFFFFF);
    cs_4_8.reset_CS_AutoCal();
    Serial.println("new client connected !!!!!");
    String currentLine = "";
    while (client.connected()) {

      long total3 =  cs_4_8.capacitiveSensor(80);
      /*
        mapping for 13 mOhm :
      */
      /*
        total3 = constrain(total3, 0, 20000);
        float totCS = map(total3, 0, 20000, 0, 512);
      */
      /* mapping for 10 mOhm*/
      total3 = constrain(total3, 0, 5000);
      float totCS = map(total3, 0, 5000, 0, 512);

      sensors_event_t event;
      mag.getEvent(&event);


      client.print(event.magnetic.x);
      client.print(",");
      client.print(event.magnetic.y);
      client.print(",");
      client.print(event.magnetic.z);
      client.print(",");
      client.print(totCS);
//      client.print(",");
//      client.print(anotherValue); // another value and so on...
      client.println("!");
      delay(50);




    }
  } else {
    magnetometerRead();
    //    capacitiveRead();
  }
  client.stop();
  Serial.println("client disconnected");

  /* check the network connection information once every 500 miliseconds: */


  printCurrentNet();
  delay(500);

}


void magnetometerRead() {
  /* all this is for reading the magnetometer */
  /* Display the results (magnetic vector values are in micro-Tesla (uT)) */

  sensors_event_t event;
  mag.getEvent(&event);
  Serial.print("X: "); Serial.print(event.magnetic.x); Serial.print("  ");
  Serial.print("Y: "); Serial.print(event.magnetic.y); Serial.print("  ");
  Serial.print("Z: "); Serial.print(event.magnetic.z); Serial.print("  "); Serial.println("uT");

  // Hold the module so that Z is pointing 'up' and you can measure the heading with x&y
  // Calculate heading when the magnetometer is level, then correct for signs of axis.
  float heading = atan2(event.magnetic.y, event.magnetic.x);

  // Once you have your heading, you must then add your 'Declination Angle', which is the 'Error' of the magnetic field in your location.
  // Find yours here: http://www.magnetic-declination.com/
  // Mine is: -13* 2' W, which is ~13 Degrees, or (which we need) 0.22 radians
  // If you cannot find your Declination, comment out these two lines, your compass will be slightly off.
  float declinationAngle = 0.22;
  heading += declinationAngle;

  // Correct for when signs are reversed.
  if (heading < 0)
    heading += 2 * PI;

  // Check for wrap due to addition of declination.
  if (heading > 2 * PI)
    heading -= 2 * PI;

  // Convert radians to degrees for readability.
  float headingDegrees = heading * 180 / M_PI;

  Serial.print("Heading (degrees): "); Serial.println(headingDegrees);

}

void capacitiveRead() {
  long total3 =  cs_4_8.capacitiveSensor(60);
}


void printWiFiData() {
  // print your WiFi shield's IP address:
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);
  Serial.println(ip);

  // print your MAC address:
  byte mac[6];
  WiFi.macAddress(mac);
  Serial.print("MAC address: ");
  printMacAddress(mac);

}

void printCurrentNet() {
  // print the SSID of the network you're attached to:
  Serial.print("SSID: ");
  Serial.println(WiFi.SSID());
  IPAddress ip = WiFi.localIP();
  Serial.print("IP Address: ");
  Serial.println(ip);
  // print the MAC address of the router you're attached to:
  byte bssid[6];
  WiFi.BSSID(bssid);
  Serial.print("BSSID: ");
  printMacAddress(bssid);

  // print the received signal strength:
  long rssi = WiFi.RSSI();
  Serial.print("signal strength (RSSI):");
  Serial.println(rssi);

  // print the encryption type:
  byte encryption = WiFi.encryptionType();
  Serial.print("Encryption Type:");
  Serial.println(encryption, HEX);
  Serial.println();
}



void printMacAddress(byte mac[]) {
  for (int i = 5; i >= 0; i--) {
    if (mac[i] < 16) {
      Serial.print("0");
    }
    Serial.print(mac[i], HEX);
    if (i > 0) {
      Serial.print(":");
    }
  }
  Serial.println();
}
