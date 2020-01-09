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


/*
key combinations:

"cmnd" + "return"  compiling lines  //on windows "ctrl" + "."
another useful hint is the key combination "cmnd" + "d" which opens the help browser while selecting valid objects or classes
"cmnd" + "." stops all runing processes

other comands

s.scope();  opens an audio osciloscope ( stereo )
s.scope(8); opens an audio osciloscope with eight tracks/channels
s.meter(); opens an audio meter ( stereo )
s.meter(8,8); opens an audio meter with eight Inputs and eight Outputs

*/

// booting the server

s.boot;

// loading sound
// the path to the sound file
p=thisProcess.nowExecutingPath.dirname +/+"bell.wav";
// loading the file into buffer
b = Buffer.read(s, p);
// free buffer in case something went wrong or want to get rid of the allocated object
b.free


// Defining a Synth ( sound program ) which is in charge of playing the loaded audio sample
(
SynthDef(\playBell, {
	arg out = 0, bufnum,speed=1,length;
	var signal,env;
	env=EnvGen.ar(Env.perc(0.25,length*2),doneAction:2);
	signal= (PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) *speed)) ;
	signal=signal*env;
	Out.ar( [0,1],signal);
	Out.ar( [5,6],signal);
}).send(s);
)

// testing the example
~test=Synth(\playBell,[\bufnum,b,\speed,4.25,\length,0.5]);

// this is optional creating a reverb for adding room
(
SynthDef(\rev,{
	arg gate=1;
	var signal, evelope;
	signal=In.ar([5,6],2);
	signal=FreeVerb.ar(signal,0.99,0.99,0.5,1.0);
	Out.ar([0,1],signal);
}).send(s);
);

// this line opens the reverb
~reverb=Synth(\rev);

// create the osc listener object for receiving messages from another environment
(
OSCdef.new(
		\bang,
		{
			arg msg, time, addr, port;
			msg[1].postln;

		~test=Synth(\playBell,[\bufnum,b,\speed,0.5,\length,msg[1] *0.495]);

		},
		'/sound'
		)
);

/*create another synth based on the same sample but this time with a continous sound (check the Env type , instead of being a perc which stands for percusive, it is an adsr - which stands for attack decay sustain release*/

(
SynthDef(\playBellContinuous, {
	arg out = 0, bufnum,speed=1,length,gate=1;
	var signal,env;
	env=EnvGen.ar(Env.adsr(0.25,1,1,length*2),gate,doneAction:2);
	signal= (PlayBuf.ar(2, bufnum, BufRateScale.kr(bufnum) *speed,1.0,0,1)) ;
	signal=signal*env;
	Out.ar( [0,1],signal);
	Out.ar( [5,6],signal);
}).send(s);
)
// test the synth - sound program by compiling the following line and leave it running
~test2=Synth(\playBellContinuous,[\bufnum,b,\speed,14.25,\length,0.5]);

// create the osc listener object for receiving messages from another environment
(
OSCdef.new(
		\bang2,
		{
			arg msg, time, addr, port;
			msg[1].postln;
		~test2.set(\speed,msg[1]);
		// x=Synth(\test,[\freq,msg[1]*14]);
		/*~test=Synth(\playBell,[\bufnum,b,\speed,0.5,\length,msg[1] *0.495]);*/

		},
		'/soundContinuous'
		)
);
