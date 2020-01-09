
//	Interaction Desgin, ZHdK
//	Sonic Interaction
//	ndr3s -v -t (Andrés Villa Torres)
//	Research Associate
//	November 2019

//	This sketch shows an example on how to send signals through OSC from Processing to Reaper DAW
import oscP5.*;
import netP5.*;

import ddf.minim.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

OscP5 			oscP5;
NetAddress 		myRemoteLocation;
Minim       	minim;
AudioOutput 	out;
Oscil       	wave;
LowPassSP 		lpf;




ControlFader tempoControl;
ControlFader volumeControl;
ControlFader track1Vol;
ControlFader track2Vol;
ControlFader track1FXWet;
ControlFader track1FXWet2;
ControlFader track2FXWet;

ControlFader track1Pan;
ControlFader track2Pan;
ControlButton track1Mute;
ControlButton track2Mute;
ControlButton playStopButton;

// HELP : : : : some tags to control reaper. 
// YOU CAN CHANGE THIS ACCESSING THE *.ReaperOSC file inside reaper preferences>control/osc/web>add or edit >
// choosing OSC (open sound control)> open config directory and make a copy of the Defaul.ReaperOSC file rename edit it and link it
// to your working audio project

// TAGS:::::::
// f/tempo/raw
// n/master/volume
// t/play
// t/stop
// n/track/@/volume
// n/track/@/pan
// t/track/@/mute/toggle
// n/track/@/fx/@/fxparam/@/value


void setup()
{
  size(600, 850, FX2D);
  // frameRate(30);
  pixelDensity(2);

  oscP5 = new OscP5(this,12000);

  myRemoteLocation = new NetAddress("127.0.0.1", 11000);  //  speak to

// ControlFader(String _msgTag, String _tag,float _lLimit, float _tLimit, float _mapLow, float _mapTop,float _pX, float _pY)
  tempoControl = new ControlFader("f/tempo/raw", "Tempo",37.5, 550,20.0,60.0, 37.5, 200);
  volumeControl = new ControlFader("n/master/volume", "MASTER VOLUME",37.5,300,0,1,37.5,250);

  track1Vol = new ControlFader("n/track/1/volume", "TRACK ONE VOLUME",37.5,300,0,1,37.5,300);
  track2Vol = new ControlFader("n/track/2/volume", "TRACK TWO VOLUME",37.5,300,0,1,37.5,350);
  track1Pan = new ControlFader("n/track/1/pan", "TRACK ONE PAN",37.5,300,0,1,37.5,400);
  track2Pan = new ControlFader("n/track/2/pan", "TRACK TWO PAN",37.5,300,0,1,37.5,450);
  track1FXWet = new ControlFader("n/track/1/fx/1/fxparam/1/value", "TRACK ONE FX WET REVERB",37.5,300,0,1,37.5,500);
  track1FXWet2 = new ControlFader("n/track/1/fx/2/fxparam/1/value", "TRACK ONE FX WET PITCH",37.5,300,0,1,37.5,550);

  track2FXWet = new ControlFader("n/track/2/fx/1/fxparam/1/value", "TRACK TWO FX WET",37.5,300,0,1,37.5,600);

 
// ControlButton(String _msgTagOn, String _msgTagOff, String _tag, PVector _location)
  playStopButton = new ControlButton("t/play","t/stop","MASTER Play/Stop", new PVector(37.5,100));
  track1Mute = new ControlButton("t/track/1/mute/toggle","t/track/1/mute/toggle", "TRACK ONE MUTE", new PVector(37.5, 600));
  track2Mute = new ControlButton("t/track/2/mute/toggle","t/track/2/mute/toggle", "TRACK TWO MUTE", new PVector(37.5, 650));

}

void draw()
{
	background(0);
	displayInformation();
	tempoControl.display();
	volumeControl.display();
	playStopButton.display();
	track1Mute.display();
	track1Pan.display();
	track1Vol.display();
	track2Mute.display();
	track2Pan.display();
	track2Vol.display();
	track1FXWet.display();
	track2FXWet.display();
	track1FXWet2.display();

	track1Pan.dynamicMap(compasRotation,0,360);
	track1FXWet.dynamicMap(pitch,0,1.8);
	track1FXWet2.dynamicMap(roll,0,1.8);
	if(debugInfo){debuggingInformation();}
}





void displayInformation(){

	fill(220,220,255);
	textSize(10);
	text("press P to PLAY, S to STOP or press the BUTTON bellow" , 25,50);
	text("|" , 35,67);
	text("V" , 33,77);

}

void debuggingInformation(){
	fill(255,220,220);
	textSize(12);
	text("fps -> " + frameRate,25,25);
	stroke(255,220,220);
	strokeWeight(0.5);
	line(0,mouseY,width,mouseY);
	line(mouseX,0,mouseX,height);
	fill(255,220,220);
	text(mouseX + " , " + mouseY,mouseX+15,mouseY+15);
}

// debugging
boolean debugInfo=false;
void keyPressed()
{ 
	playStopButton.keyPressed();
	if(key == 'd' || key == 'D'){
		debugInfo=!debugInfo;
	}
}



void oscEventSend(String tag){
		OscMessage myMessage = new OscMessage(tag);
		myMessage.add(1); /* add an int to the osc message */
		oscP5.send(myMessage, myRemoteLocation); 
}


