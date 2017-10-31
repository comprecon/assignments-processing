import cc.arduino.*;
import processing.serial.*;



Arduino myArduino;

float knobValue1;
float knobValue2;
float knobValue3;


void setup() {
  size(500,500);
  
  println(Arduino.list());
  
  myArduino = new Arduino(this, Arduino.list()[2], 57600);

}
  
  void draw() {
   
    
    knobValue1 = myArduino.analogRead(0);
    knobValue2 = myArduino.analogRead(1);
    knobValue3 = myArduino.analogRead(2);
    
    if (mousePressed) {
    println(knobValue1);
    println(knobValue2);
    println(knobValue3);
    
    }
    
    background(0);
    fill (knobValue3, knobValue2, knobValue1);
    ellipse(250, 250, 300, 300); 
    
  }