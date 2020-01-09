// very short tutorial for using super collider as sound "engine" receiving osc messages from processing
// for Sonic Interaction Design < > ZHdK
// written by Andrés Vill a Torres ndr3svt jan 2020

//  keep in mind that SC is a livecoding enviornment for sound arts
// it was created two decades ago and it is still alive
// the language is super broad as well as flexible
// more information : https://en.wikipedia.org/wiki/SuperCollider
// as a live coding environment you compile line by  line or section by section
// you can create a self running application with a shell script and platypus https://sveinbjorn.org/platypus
// i'll upload the documentation soon for that !


import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocationSC;// supercollider
void setup() { 
  size(640, 200,FX2D); 
  frameRate(120);
  oscP5 = new OscP5(this, 12000);
  myRemoteLocationSC = new NetAddress("127.0.0.1", 57120); // SuperCollider
}

float shiftSpeed=1.0;
void draw(){
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

void mousePressed(){
	soundDiscrete_SC(mouseX);
}
void soundDiscrete_SC(float _value){
  OscMessage newMessage = new OscMessage("/sound");  
  newMessage.add(_value); 
  oscP5.send(newMessage, myRemoteLocationSC);
}

void soundContinuous_SC(float _value){
  OscMessage newMessage = new OscMessage("/soundContinuous");  
  newMessage.add(_value); 
  oscP5.send(newMessage, myRemoteLocationSC);	
}