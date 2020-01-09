import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class msgOSCtoSC extends PApplet {



OscP5 oscP5;
NetAddress myRemoteLocationSC;// supercollider
public void setup() { 
   
  frameRate(120);
  oscP5 = new OscP5(this, 12000);
  myRemoteLocationSC = new NetAddress("127.0.0.1", 57120); // SuperCollider
}

float shiftSpeed=1.0f;
public void draw(){
	background(0);

	if(mousePressed){
		shiftSpeed=map(mouseX,0,width,-25,25);
		soundContinuous_SC(shiftSpeed);
	}
	fill(255);
	textAlign(CENTER,CENTER);
	text("press mouse to change speed of loop (from -25 to 25)",width/2,height/2-25);
	text("also while pressing you produce a single 'note' ",width/2,height/2);
	text(shiftSpeed,width/2,height/2+25);
}

public void mousePressed(){
	soundDiscrete_SC(mouseX);
}
public void soundDiscrete_SC(float _value){
  OscMessage newMessage = new OscMessage("/sound");  
  newMessage.add(_value); 
  oscP5.send(newMessage, myRemoteLocationSC);
}

public void soundContinuous_SC(float _value){
  OscMessage newMessage = new OscMessage("/soundContinuous");  
  newMessage.add(_value); 
  oscP5.send(newMessage, myRemoteLocationSC);	
}
  public void settings() {  size(640, 200,FX2D); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "msgOSCtoSC" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
