//import libraries
import processing.sound.*;
import processing.serial.*; //import serial library
import cc.arduino.*;  //import arduino library

Arduino myArduino; //declare arduino object

// Declare the processing sound variables 
FFT fft;
AudioDevice device;
AudioIn input;
Amplitude rms;

PFont f;
float theText;

// more fft granularity means more accurate pitch detection.. this number has to be a power of 2, i dont know why because i don't understand the math behind fft
int bands = 2048;

//
float tAmp;
float wBand;

int ledPin = 10;
int buttonPin = 8;

int ledBright;

//variables to help make the button act as a toggle
int buttonPress = 0;
int buttonCheck = 0;
int buttonToggle = 0;
int colorStep = 0;

//different graphics layers
PGraphics textLayer;
PGraphics drawLayer;
PGraphics tempLayer;
PGraphics underLayer;

//color variables
int r, gg, b;

public void setup() {
  size(1080, 720);
  f = createFont("Didot", 72, true);
  // If the Buffersize is larger than the FFT Size, the FFT will fail
  // so we set Buffersize equal to bands
  device = new AudioDevice(this, 44000, bands*2);

  
    input = new AudioIn(this, 0);
    
    // start the Audio Input
    input.start();
    
    // create a new Amplitude analyzer
    rms = new Amplitude(this);
    
    // Patch the input to an volume analyzer
    rms.input(input);
    
    
  // Create and patch the FFT analyzer
  fft = new FFT(this, bands);
  fft.input(input);
  //view available serial ports
  println(Arduino.list());

  //connect to Arduino, initialize object
  myArduino = new Arduino(this, Arduino.list()[0], 57600);
  myArduino.pinMode(buttonPin, Arduino.INPUT);
  
  textLayer = createGraphics(width, height, g.getClass().getName());
  drawLayer = createGraphics(width, height, g.getClass().getName());
  tempLayer = createGraphics(width, height, g.getClass().getName());
  underLayer = createGraphics(width, height, g.getClass().getName());
}      

public void draw() {
  // Set background color, noStroke and fill color

  fft.analyze();

  tAmp = 0;
  wBand = 0;
//this is the pitch detector, the fft object creates an array of amplitudes corresponding to different frequencies
//this for loop checks each amplitude to find the largest one and marks it's position by saving i
//one should be able to calculate the actual frequency, but i don't know the math behind fft so i couldn't figure it out
  for (int i = 0; i < bands; i++) {    
    if (fft.spectrum[i] > tAmp) {
      tAmp = fft.spectrum[i];
      wBand = i;
    }
  }
  wBand = wBand/bands*100; //this is where you could calculate the actual frequency, but right now it's not calibrated
  
  
  buttonPress = myArduino.digitalRead(buttonPin);
  //button toggle code, this code makes the button advance the color picker/draw step you are on, which is useful, since the button usually only has two states on/off
  if (buttonPress == buttonCheck) {
  //do nothing - this is the state that the button is not pushed
  } else {
    //if the button is pushed and then released we advance colorStep which is keeping track of which step we are on, 
    if (buttonPress == 0) {
      if (buttonToggle == 0) {//i think this code might be unnecessary.. but i can't test it right now so i'm leaving it in. button toggle used to do something in a previous iteration of this code
        buttonToggle = 1;
        if (colorStep < 3) {
          colorStep++;
        } else {
          colorStep = 0;
        }
      } else {
        buttonToggle = 0;
        if (colorStep < 3) {
          colorStep++;
        } else {
          colorStep = 0;
        }
      }
    }
    //this prevents this code from running more than once per button push
    buttonCheck = buttonPress;
  }  
  
  //first choose red, r is mapped to how high the loudest frequency is at the time of the button press
  if (colorStep == 0) {
    r = (int)map(wBand, 0, 14, 0, 255);
    underLayer.beginDraw();
    underLayer.background(r,0,0);
    underLayer.endDraw();
    theText = r;
  }
  //choose green
  if (colorStep == 1) {
    gg = (int)map(wBand, 0, 14, 0, 255);
    underLayer.beginDraw();
    underLayer.background(0,gg,0);
    underLayer.endDraw();
    theText = gg;
  }
  //choose blue
  if (colorStep == 2) {
    b = (int)map(wBand, 0, 14, 0, 255);
    underLayer.beginDraw();
    underLayer.background(0,0,b);
    underLayer.endDraw();
    theText = b;
  }
  //now you can draw, the amplitude of the entire input sound determines the size of the "paintbrush"
  if (colorStep == 3) {
    underLayer.beginDraw();
    underLayer.background(0,0,0);
    underLayer.endDraw();
    drawLayer.beginDraw();
    drawLayer.noStroke();
    drawLayer.fill(r,gg,b);
    if (mousePressed) {
      drawLayer.ellipse(mouseX,mouseY, tAmp*1000, tAmp*1000);
      // println(tAmp*1000);
    }
    drawLayer.endDraw();
    
    //tempLayer is the paintbrush, but since we don't want to make a permanent mark unless the mouse is clicked, we keep it separate from the draw layer
    tempLayer.beginDraw();
    tempLayer.loadPixels();
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        int loc = x + y * width;
        tempLayer.pixels[loc] = color(0, 0, 0, 0);
      }
    }
    tempLayer.updatePixels();
    tempLayer.stroke(0);
    tempLayer.fill(r,gg,b);
    tempLayer.ellipse(mouseX,mouseY, tAmp*1000, tAmp*1000);
    tempLayer.endDraw();
    theText = tAmp*1000;
  }
  
  //draw text layer
  textLayer.beginDraw();
  textLayer.loadPixels();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      int loc = x + y * width;
      textLayer.pixels[loc] = color(0, 0, 0, 0);
    }
  }
  textLayer.updatePixels();
  textLayer.textFont(f, 72);
  //the text is the relavent input, the color value, or the paintbrush size depending on if you are in colorpicker mode or draw mode
  textLayer.text(theText, 100, 200);
  textLayer.endDraw();
  
  //draw all the layers
  image(underLayer, 0, 0);
  image(drawLayer, 0, 0);
  image(tempLayer, 0, 0);
  image(textLayer, 0, 0);
  
  //led brightness depends on amplitude
  ledBright = (int)(map(tAmp, 0, .1, 0, 255));
  myArduino.analogWrite(ledPin, ledBright);
}

//this code erases the draw layer upon a key press by drawing black pixels over the entire surface
void keyPressed() {
  drawLayer.beginDraw();
  drawLayer.loadPixels();  
  // Loop through every pixel column
  for (int x = 0; x < width; x++) {
    // Loop through every pixel row
    for (int y = 0; y < height; y++) {
      // Use the formula to find the 1D location
      int loc = x + y * width;
      drawLayer.pixels[loc] = color(0, 0, 0, 0);
    }
  }
  drawLayer.updatePixels();
}