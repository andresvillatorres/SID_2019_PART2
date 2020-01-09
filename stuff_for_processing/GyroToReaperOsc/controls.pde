//	custom classes for control fader and button
//	ndr3s -v -t (Andrés Villa Torres)
//	November 2019

class ControlFader{
	float lowLimit = 37.5;
	float mapValue= 0.0;
	float topLimit = 400;
	float mapLow, mapTop;
	PVector speedCtrlPos= new PVector(lowLimit,200);
	boolean grab = false;
	String messageTag;
	String tag;
	color colorKnob;
	color smoothCKnob;

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

	void display(){
		PVector me = new PVector(mouseX,mouseY);

		smoothCKnob = color(red(colorKnob)*0.15 + red(smoothCKnob)*0.85,green(colorKnob)*0.15+ green(smoothCKnob)*0.85,blue(colorKnob)*0.15+ blue(smoothCKnob)*0.85);
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

	void dynamicMap(float _thisValue, float _mapLow, float _mapTop){
		_thisValue = map(_thisValue, _mapLow,_mapTop, 0,1);
		mapValue = mapValue*0.15 + _thisValue*0.85;

		speedCtrlPos.x = map(mapValue,0,1.0,lowLimit,topLimit);
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

	void display(){
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

	void keyPressed(){
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