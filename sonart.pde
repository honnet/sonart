/////////////////////////////////
// apli dev by TangibleDisplay //
/////////////////////////////////
// objective : detect 3 distances (CALL / INFO / ALERT)
// CALL : displays general information about a piece of art, this device, etc.
// INFO : displays pictures depending on a visitor position (left, center, right)
// ALERT : triggers an alarm to protect protect a piece of art
// https://github.com/honnet/sonart

// original developpers : Daniel Shiffman & Dan O'Sullivan
// http://www.shiffman.net
// https://github.com/shiffman/libfreenect/tree/master/wrappers/java/processing

import org.openkinect.*;
import org.openkinect.processing.*;

//sound
import ddf.minim.*;
Minim minim; 
AudioSample alarm;

//text scrolling
PFont controlFont;
PFont afficheur;
// Showing how we can farm all the kinect stuff out to a separate class
KinectTracker tracker;
// Kinect Library object
Kinect kinect;

boolean affichInterface = false;
boolean zone_Alert = false; 
boolean zone_Info = false;
boolean zone_Appel = false;
PImage rhinoMiddle, rhinoFerme;
PImage rhinoRight1, rhinoRight2;
PImage rhinoLeft1, rhinoLeft2;
PImage myImage;
PImage logo_0, logo_1, logo_2, logo_3, logo_4;

// manage logos diplay
final int NBLOGO = 5; 
final int DISPLAY_TIME = 2000;  // 2000 ms = 2 seconds
int counter;                    // Automatically initialized at 0
int lastTimeAlert, lastTimeLogo;// When the current image was first displayed
PImage[] logos = new PImage[NBLOGO];

/////////////////////////////////////////////////////////
void setup() {
  noCursor();
  size(1280,800);
  smooth();
  kinect = new Kinect(this);
  tracker = new KinectTracker();

  //TEXT STUFF 
  controlFont = createFont("Monospaced", 10);
  afficheur = loadFont("Astronaut-48.vlw");
  /////SOUND STUFF
  minim = new Minim(this);

  alarm = minim.loadSample("rhinoceros_try.wav",512);

  //RHINO
  //LEFT
  rhinoLeft1 = loadImage("rhino_left_open_mid.png");
  rhinoLeft2 = loadImage("rhino_left_open_up.png");
  //RIGHT
  rhinoRight1 = loadImage("rhino_right_open_mid.png");
  rhinoRight2 = loadImage("rhino_right_open_up.png");
  //CENTER
  rhinoMiddle = loadImage ("rhino_center_opened.png");

  rhinoFerme = loadImage("rhino_all_closed.png"); 
  myImage = rhinoFerme;

  lastTimeAlert = millis();
  lastTimeLogo = millis();
  for (int i =0 ; i < NBLOGO ; i++) { 
    logos[i]= loadImage("logo_"+i+".jpg");
  }

  imageMode(CORNER);
  kinect.tilt(tracker.deg);
}

/////////////////////////////////////////////////////////
void draw() {
  background(255);
  tint(255,255,255);

  tracker.checkDistance();
  tracker.checkZone();

  if (zone_Alert) tracker.zoneAlert();
  else if (zone_Info)  tracker.zoneInfo();
  else if (zone_Appel) tracker.zoneAppel();


  //DEBUG INFO
  if (key == 'i' || key =='I') affichInterface = true;
  if (key == 'o' || key =='O') affichInterface = false;
  if (affichInterface) tracker.controlView();
}

/////////////////////////////////////////////////////////
void keyPressed() {
  //ajust le seuil de l'Alarme avec les touches +/- 
  int dM = tracker.getdistAlarm();
  if (key == '='|| key=='+') {
    dM+=1;
    tracker.setdistAlarm(dM);
  } 
  else if (key== '-') {
    dM-=1;
    tracker.setdistAlarm(dM);
  }
  int dAppel = tracker.getdistCall();
  if (key == 'p'|| key=='P') {
    dAppel+=1;
    tracker.setdistCall(dAppel);
  } 
  else if (key== 'm'|| key== 'M') {
    dAppel-=1;
    tracker.setdistCall(dAppel);
  }

  int tT = tracker.gettoleranceTime();
  if (key == 't'|| key=='T') {
    tT+=5;
    tracker.settoleranceTime(tT);
  } 
  if (key == 'y'|| key=='Y') {
    tT+=-5;
    tracker.settoleranceTime(tT);
  }
}

/////////////////////////////////////////////////////////
void stop() {
  tracker.quit();
  super.stop();
}

