import cc.arduino.*;
import org.firmata.*;

import processing.serial.*;
import processing.sound.*;

Arduino myArduino;

float knobValue;
int buttonPin = 10;
float buttonState;

SinOsc[] sineWaves; // Array of sines
float[] sineFreq; // Array of frequencies
int numSines = 5; // Number of oscillators to use

int num = 50;
int[] x = new int[num];
int[] y = new int[num];

PImage smile;
PImage purpleSmile;
PFont f;

//---------------------setup--------------------------
//----------------------------------------------------
void setup() {  
  size(1280, 720);
  background(255);


  println(Arduino.list());
  myArduino = new Arduino(this, Arduino.list()[1], 57600);
  myArduino.pinMode(buttonPin, Arduino.INPUT);


  sineWaves = new SinOsc[numSines]; // Initialize the oscillators
  sineFreq = new float[numSines]; // Initialize array for Frequencies

  for (int i = 0; i < numSines; i++) {
    // Calculate the amplitude for each oscillator
    float sineVolume = (1.0 / numSines) / (i + 1);
    // Create the oscillators
    sineWaves[i] = new SinOsc(this);
    // Start Oscillators
    sineWaves[i].play();
    // Set the amplitudes for all oscillators
    sineWaves[i].amp(sineVolume);
  }

  smile = loadImage("smile.png");
  purpleSmile = loadImage("purpleSmile.png");

  fill(234, 28, 166);
  noStroke();
  rect(0, 0, 1280, 30);
  rect(1250, 0, 1280, 720);
  rect(0, 690, 1280, 720);
  rect(0, 0, 30, 720);


  for (int i = 0; i<1250; i+=70) {
    for (int j = 0; j<690; j +=70) {
      image(smile, i, 0, 30, 30);
      image(smile, i, 690, 30, 30);
      image(smile, 0, j, 30, 30);
      image(smile, 1250, j, 30, 30);
      image(smile, 1250, 690, 30, 30);
    }
  }

  f = createFont("Arial", 16, true);
}//end steup


//-------------------draw-----------------------------
//----------------------------------------------------
void draw() {

  textFont(f, 20);
  fill(0);
  text(" DRAW THE SOUND!", 50, 60);



  knobValue = myArduino.analogRead(0);
  println(knobValue);
  buttonState = myArduino.digitalRead(buttonPin);
  println(buttonState);

  float mappedKnobValue = map(knobValue, 0, 331, -0.5, 10);
  float mappedKnobValueAlpha = map(knobValue, 0, 331, 0, 255); 


  //Map mouseY from 0 to 1
  float yoffset = map(mouseY, 0, height, 0, 1);
  //  float yoffset = mappedKnobValue;
  //Map mouseY logarithmically to 150 - 1150 to create a base frequency range
  float frequency = pow(1000, yoffset) + 150;
  //Use mouseX mapped from -0.5 to 0.5 as a detune argument
  //float detune = map(mouseX, 0, width, -0.5, 0.5);
  float detune = mappedKnobValue;

  for (int i = 0; i < numSines; i++) { 
    sineFreq[i] = frequency * (i + 1 * detune);
    // Set the frequencies for all oscillators
    sineWaves[i].freq(sineFreq[i]);
  }


  //draw line
  strokeWeight(3);
  stroke(random(255), random(255), random(255));
  line(pmouseX, pmouseY, mouseX, mouseY);


  //draw circles
  noStroke();
  fill(random(255), random(255), random(255), mappedKnobValueAlpha);

  if (mousePressed) {
    //rectMode(CENTER);
    //rect(mouseX, mouseY, mappedKnobValueAlpha/2, mappedKnobValueAlpha/2);

    //// Shift the values to the right
    for (int i = num-1; i > 0; i--) {
      x[i] = x[i-1];
      y[i] = y[i-1];
    }
    // Add the new values to the beginning of the array
    x[0] = mouseX;
    y[0] = mouseY;
    // Draw the circles
    for (int i = 0; i < num; i++) {
      rectMode(CENTER);
      rect(x[i], y[i], mappedKnobValueAlpha/2, mappedKnobValueAlpha/2);
    } 
    myArduino.digitalWrite(13, Arduino.HIGH);
  } else {
    // Shift the values to the right
    for (int i = num-1; i > 0; i--) {
      x[i] = x[i-1];
      y[i] = y[i-1];
    }
    // Add the new values to the beginning of the array
    x[0] = mouseX;
    y[0] = mouseY;
    // Draw the circles
    for (int i = 0; i < num; i++) {
      ellipse(x[i], y[i], mappedKnobValueAlpha/2, mappedKnobValueAlpha/2);
      //ellipse(mouseX, mouseY, i/2.0, i/2.0);
    }
    myArduino.digitalWrite(13, Arduino.LOW);
  }


  if (buttonState == 1) {
    background(255);
    fill(234, 28, 166);
  noStroke();
  rect(0, 0, 1280, 30);
  rect(1250, 0, 1280, 720);
  rect(0, 690, 1280, 720);
  rect(0, 0, 30, 720);


  for (int i = 0; i<1250; i+=70) {
    for (int j = 0; j<690; j +=70) {
      image(smile, i, 0, 30, 30);
      image(smile, i, 690, 30, 30);
      image(smile, 0, j, 30, 30);
      image(smile, 1250, j, 30, 30);
      image(smile, 1250, 690, 30, 30);
    }
  }
  }
  
}//end draw