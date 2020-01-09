void noteON(int _note, int _channel){
	// custom midi channel via variable "channel"
	// > be aware that in reaper the midi channels are shifted by 1
	// i. e. if you send channel 0 it will be 1 in reaper, 1 will be 2 in reaper and so on
    OscMessage myMessage = new OscMessage("i/vkb_midi/"+_channel+"/note/"+_note);
    myMessage.add(50.0); 
    oscP5.send(myMessage, myRemoteLocation);
}

void noteOFF(int _note){
	// fixed midi channel 0
    OscMessage myMessage = new OscMessage("i/vkb_midi/0/note/"+_note);
    myMessage.add(0); 
    oscP5.send(myMessage, myRemoteLocation);
}

void noteON_SC(float _value){
  OscMessage newMessage = new OscMessage("/sound");  
  newMessage.add(_value); 
  oscP5.send(newMessage, myRemoteLocationSC);
}