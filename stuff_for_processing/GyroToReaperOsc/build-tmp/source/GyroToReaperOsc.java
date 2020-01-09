import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import oscP5.*; 
import netP5.*; 
import ddf.minim.*; 
import ddf.minim.ugens.*; 
import ddf.minim.effects.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class GyroToReaperOsc extends PApplet {


//	Interaction Desgin, ZHdK
//	Sonic Interaction
//	ndr3s -v -t (Andrés Villa Torres)
//	Research Associate
//	November 2019

//	This sketch shows an example on how to send signals through OSC from Processing to Reaper DAW







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


public void setup()
{
  
  // frameRate(30);
  

  oscP5 = new OscP5(this,12000);

  myRemoteLocation = new NetAddress("127.0.0.1", 11000);  //  speak to

// ControlFader(String _msgTag, String _tag,float _lLimit, float _tLimit, float _mapLow, float _mapTop,float _pX, float _pY)
  tempoControl = new ControlFader("f/tempo/raw", "Tempo",37.5f, 550,20.0f,60.0f, 37.5f, 200);
  volumeControl = new ControlFader("n/master/volume", "MASTER VOLUME",37.5f,300,0,1,37.5f,250);

  track1Vol = new ControlFader("n/track/1/volume", "TRACK ONE VOLUME",37.5f,300,0,1,37.5f,300);
  track2Vol = new ControlFader("n/track/2/volume", "TRACK TWO VOLUME",37.5f,300,0,1,37.5f,350);
  track1Pan = new ControlFader("n/track/1/pan", "TRACK ONE PAN",37.5f,300,0,1,37.5f,400);
  track2Pan = new ControlFader("n/track/2/pan", "TRACK TWO PAN",37.5f,300,0,1,37.5f,450);
  track1FXWet = new ControlFader("n/track/1/fx/1/fxparam/1/value", "TRACK ONE FX WET REVERB",37.5f,300,0,1,37.5f,500);
  track1FXWet2 = new ControlFader("n/track/1/fx/2/fxparam/1/value", "TRACK ONE FX WET PITCH",37.5f,300,0,1,37.5f,550);

  track2FXWet = new ControlFader("n/track/2/fx/1/fxparam/1/value", "TRACK TWO FX WET",37.5f,300,0,1,37.5f,600);

 
// ControlButton(String _msgTagOn, String _msgTagOff, String _tag, PVector _location)
  playStopButton = new ControlButton("t/play","t/stop","MASTER Play/Stop", new PVector(37.5f,100));
  track1Mute = new ControlButton("t/track/1/mute/toggle","t/track/1/mute/toggle", "TRACK ONE MUTE", new PVector(37.5f, 600));
  track2Mute = new ControlButton("t/track/2/mute/toggle","t/track/2/mute/toggle", "TRACK TWO MUTE", new PVector(37.5f, 650));

}

public void draw()
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
	track1FXWet.dynamicMap(pitch,0,1.8f);
	track1FXWet2.dynamicMap(roll,0,1.8f);
	if(debugInfo){debuggingInformation();}
}





public void displayInformation(){

	fill(220,220,255);
	textSize(10);
	text("press P to PLAY, S to STOP or press the BUTTON bellow" , 25,50);
	text("|" , 35,67);
	text("V" , 33,77);

}

public void debuggingInformation(){
	fill(255,220,220);
	textSize(12);
	text("fps -> " + frameRate,25,25);
	stroke(255,220,220);
	strokeWeight(0.5f);
	line(0,mouseY,width,mouseY);
	line(mouseX,0,mouseX,height);
	fill(255,220,220);
	text(mouseX + " , " + mouseY,mouseX+15,mouseY+15);
}

// debugging
boolean debugInfo=false;
public void keyPressed()
{ 
	playStopButton.keyPressed();
	if(key == 'd' || key == 'D'){
		debugInfo=!debugInfo;
	}
}



public void oscEventSend(String tag){
		OscMessage myMessage = new OscMessage(tag);
		myMessage.add(1); /* add an int to the osc message */
		oscP5.send(myMessage, myRemoteLocation); 
}


//	custom classes for control fader and button
//	ndr3s -v -t (Andrés Villa Torres)
//	November 2019

class ControlFader{
	float lowLimit = 37.5f;
	float mapValue= 0.0f;
	float topLimit = 400;
	float mapLow, mapTop;
	PVector speedCtrlPos= new PVector(lowLimit,200);
	boolean grab = false;
	String messageTag;
	String tag;
	int colorKnob;
	int smoothCKnob;

	ControlFader(String _msgTag, String _tag,float _lLimit, float _tLimit, float _mapLow, float _mapTop,float _pX, float _pY){
		lowLimit = _lLimit;
		topLimit = _tLimit;
		mapLow = _mapLow;
		mapTop = _mapTop;
		messageTag = _msgTag;
		speedCtrlPos = new PVector(_pX,_pY);
		tag=_tag;
		colorKnob = color(220,220,255);
		smoothCKnob = color (220,220,255);
	}

	public void display(){
		PVector me = new PVector(mouseX,mouseY);

		smoothCKnob = color(red(colorKnob)*0.15f + red(smoothCKnob)*0.85f,green(colorKnob)*0.15f+ green(smoothCKnob)*0.85f,blue(colorKnob)*0.15f+ blue(smoothCKnob)*0.85f);
		float size=25;
		stroke(220,220,255);
		strokeWeight(2);
		line(lowLimit,speedCtrlPos.y,topLimit,speedCtrlPos.y);
		fill(smoothCKnob);

		ellipse(speedCtrlPos.x,speedCtrlPos.y,size,size);
		float val =map(speedCtrlPos.x, lowLimit, topLimit ,mapLow,mapTop);
		fill(220,220,255);
		text(tag + " : " +  val,speedCtrlPos.x-25,speedCtrlPos.y+25);
		if(speedCtrlPos.dist(me)<size && mousePressed && me.x>lowLimit && me.x<topLimit && !grab){
			grab=true;
		}else{
			if(mousePressed && grab){
				colorKnob=color(220,255,220);
				speedCtrlPos.x = map(mouseX,lowLimit,topLimit,lowLimit,topLimit);
				speedCtrlPos.x = constrain(speedCtrlPos.x, lowLimit, topLimit);
				OscMessage myMessage = new OscMessage(messageTag);
				myMessage.add(val); /* add an int to the osc message */
				oscP5.send(myMessage, myRemoteLocation); 
			}else{
				if(!mousePressed && grab){
					grab=false;
					colorKnob=color(220,220,255);
				}else{
					if(speedCtrlPos.dist(me)<size){
						colorKnob=color(120,120,255);
					}else{
						colorKnob=color(220,220,255);
					}
				}
			}
		}
	}

	public void dynamicMap(float _thisValue, float _mapLow, float _mapTop){
		_thisValue = map(_thisValue, _mapLow,_mapTop, 0,1);
		mapValue = mapValue*0.15f + _thisValue*0.85f;

		speedCtrlPos.x = map(mapValue,0,1.0f,lowLimit,topLimit);
		OscMessage myMessage = new OscMessage(messageTag);
		myMessage.add(mapValue); /* add an int to the osc message */
		oscP5.send(myMessage, myRemoteLocation); 

	}
}

class ControlButton{

	boolean onOff=false;
	boolean play=false;
	PVector location;
	String msgTagOn;
	String msgTagOff;
	String tag;

	ControlButton(String _msgTagOn, String _msgTagOff, String _tag, PVector _location){
		tag = _tag;
		msgTagOn = _msgTagOn;
		msgTagOff = _msgTagOff;
		location = _location;
	}

	public void display(){
		PVector me = new PVector(mouseX,mouseY);
		stroke(220,220,255);
		strokeWeight(2);
		float size=25;
		if(location.dist(me)< size){
			if(play){
				fill(200,255,220);
			}else{
				fill(150,205,150);
			}
			if(mousePressed && !onOff){
				onOff=true;
				play=!play;
				if(play){oscEventSend(msgTagOn);}else{oscEventSend(msgTagOff);}
			}else{
				if(!mousePressed && onOff){
					onOff=false;
				}
			}
		}else{
			if(play){
				fill(255,200,200);
			}else{
				fill(200,200,255);
			}
		}
		ellipse(location.x,location.y,size,size);
		fill(220,220,255);
		text(tag, location.x-25, location.y+25);
	}

	public void keyPressed(){
		if(key == 'p' || key == 'P'){
			oscEventSend("t/play");
			println("play was sent");
			play=true;
		}
		if(key == 's' || key == 'S'){
			oscEventSend("t/stop");
			println("stop was sent");
			play=false;
		}
	}
}

float compasRotation=0.0f;
float lastCompasRotation=0.0f;
float addRotation=0.0f;
float pitch = 0.0f;
float roll  = 0.0f;
float yaw   = 0.0f;
float magx  = 0.0f;
float smooth_compasRotation=0.0f;
float smooth_pitch=0.0f;
float smooth_roll=0.0f;
float smooth_yaw=0.0f;
float smooth_magx=0.0f;
public void oscEvent(OscMessage theOscMessage) {
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/gyro")==true){
    //pitch == 0 , roll == 1 , yaw == 2
    pitch=theOscMessage.get(0).floatValue();
    // println("picth : " + pitch);
    roll = theOscMessage.get(1).floatValue();
    yaw = theOscMessage.get(2).floatValue();
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/comp")==true){
    // println();

    compasRotation=theOscMessage.get(0).floatValue();
      // println(compasRotation);
    // println(,theOscMessage.get(1).floatValue(),theOscMessage.get(2).floatValue());
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/gps")==true){
    // println(theOscMessage.get(0).floatValue(),theOscMessage.get(1).floatValue(),theOscMessage.get(2).floatValue(),theOscMessage.get(3).floatValue(),theOscMessage.get(4).floatValue(),theOscMessage.get(5).floatValue() );
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/mag")==true){
    // println(theOscMessage.get(0).floatValue(),theOscMessage.get(1).floatValue(),theOscMessage.get(2).floatValue());
    // magx=theOscMessage.get(0).floatValue();
  }
  if(theOscMessage.checkAddrPattern("/gyrosc/gyrotest/alt")==true){
    // println(theOscMessage.get(0).floatValue());
  }
}
  public void settings() {  size(600, 850, FX2D);  pixelDensity(2); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "--present", "--window-color=#666666", "--stop-color=#cccccc", "GyroToReaperOsc" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
