// Arduino library
// also look at examples that came with the library

// import arduino library and serial library
import processing.serial.*;
import cc.arduino.*;

Arduino arduino; // initialize arduino

float waterValue;
int sensorPin = 0;

float r = 0;
float x = 300;
float y = 300;
int i =0 ;

void setup() {
  

  size(600,600);
  
  // ARDUINO STUFF -------------------------- //
  // Prints out the available serial ports.
  println(Arduino.list());
  
  // initialize arduino object
  // IMPORTANT -- [0] should match the correct port in the list
  arduino = new Arduino(this, Arduino.list()[2], 57600);  
  arduino.pinMode(sensorPin, Arduino.INPUT); 
}

void draw() {
    background(0);

  waterValue = arduino.analogRead(sensorPin);
  
  println(waterValue);
  delay(100);
 
 r = r + 1;
  if (r > 700) {
    r =  0;
  } // end r 
  
  if (waterValue > 200){
    for ( i = -600; i <= 700; i += 40) { 
      ellipseMode(CENTER);
      noFill();
      stroke(0,0,255);
      strokeWeight(2);
      ellipse(x, y, r+i, r+i);
    }
       for ( i = -600; i <= 600; i += 70) { 
      ellipseMode(CENTER);
      noFill();
      stroke(255);
      strokeWeight(2);
      ellipse(x, y, r+i, r+i);
 
    } // for loop
  } else {
    for ( i = -600; i <= 600; i += 70) { 
      ellipseMode(CENTER);
      noFill();
      stroke(255);
      strokeWeight(2);
      ellipse(x, y, r+i, r+i);
    } // for loop
  }
 
}