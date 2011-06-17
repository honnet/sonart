class KinectTracker {

  // Size of kinect image
  int kw = 640;
  int kh = 480;

  int posImageX = 100;
  int posImageY = 150;

  // zoneAlert
  int alertTime;
  int toleranceTime = 15;

  final int positX = width/2;
  final int positY = 250;
  final int TOUCH_SURFACE = 3;
  final int HUMAN_SURFACE = 30;

  float move = 0;

  int distAlarm= 952;         //zoneAlarmART 952
  int distCall = 995;         //call zone 977

    //Call zone
  int callTime;
  final int MAXCALLTIME = 40;

  final int OBSERVTIME = 60;
  final int ANTIJITTER = 10;
  int visuLeft = 0;
  int visuRight = 0;
  int visuCenter = 0;

  // Interpolated location
  PVector loc;
  PVector lerpedLoc;

  //zoneInfo
  int infoTime;
  final int TIMETOINFO = 10;
  //zoneAlert
  int displayAlert = 0;
  final int DISPLAY_ALERT_MAX = 50;
  //distance Depth data
  int[] depth;
  //control orientation camera 
  int deg = -26;///29

  PImage display;
  int posX = 600;
  //////////////////////////////////////////////////////////////
  // constructor
  KinectTracker() {
    kinect.start();
    kinect.enableDepth(true);
    display = createImage(kw,kh,PConstants.RGB);
    loc = new PVector(-50,-50);
    lerpedLoc = new PVector(-50,-50);
  }

  //////////////////////////////////////////////////////////////
  void checkDistance() {
    // Get the raw depth as array of integers
    depth = kinect.getRawDepth();
    // Being overly cautious here
    if (depth == null) return;

    int posX = 0;
    int posY = 0;
    int count = 0;
    int pos = 0;
    int appel = 0;

    for(int x = 0; x < kw; x++) {
      for(int y = 0; y < kh; y++) {
        int offset = kw-x-1 + y*kw;    // Mirroring the image      
        int rawDepth = depth[offset];  // Grabbing the raw depth
        // Testing against threshold

        //ZONE ALERT ALARM
        if (rawDepth < distAlarm) {
          count++;
        }
        //ZONE INFORMATION
        else if (rawDepth > distAlarm && rawDepth <= distCall) {
          if (x>kw/5 && x<kw-kw/5) {
            posX += x;
            posY += y;
            pos++;
          }
        }
        //ZONE CALL
        else {
          appel++;
        }
      }
    }

    // As long as we found something
    if (count > TOUCH_SURFACE) {    // ALARM
      alertTime += 1; 
      callTime = 0;
      infoTime = 0;
    }
    else if (pos > HUMAN_SURFACE) { // INFO
      loc = new PVector(posX/pos, posY/pos);
      infoTime += 1;
      alertTime = 0;
      callTime = 0;
    }
    else {                          // CALL
      callTime += 1;
      alertTime = 0;
      infoTime = 0;
    }

    // Interpolating the location, doing it arbitrarily for now
    lerpedLoc.x = PApplet.lerp(lerpedLoc.x, loc.x, 0.3f);
    lerpedLoc.y = PApplet.lerp(lerpedLoc.y, loc.y, 0.3f);
  }

  /////////////////////////////////////////////////////////////////////
  PVector getLerpedPos() {
    return lerpedLoc;
  }

  PVector getPos() {
    return loc;
  }

  int getdistAlarm() {
    return distAlarm;
  }

  void setdistAlarm(int dM) {
    distAlarm=  dM;
  }

  int gettoleranceTime() {
    return toleranceTime;
  }

  void settoleranceTime(int tT) {
    toleranceTime=  tT;
  }

  int getdistCall() {
    return distCall;
  }

  void setdistCall(int dAppel) {
    distCall = dAppel;
  }

  /////////////////////////////////////////////////////////////////////
  void checkZone() {
    if (alertTime > toleranceTime) {
      zone_Alert = true;
      zone_Appel = false;
      zone_Info = false;
      alarm.trigger();
      delay(300);
    }
    else if (zone_Alert == true)
    {
      if (++displayAlert > DISPLAY_ALERT_MAX) // Time to display 
      {
        displayAlert = 0;
        zone_Alert = false;
      }
    }
    else if (infoTime > TIMETOINFO ) {
      zone_Info = true; 
      zone_Appel = false;
      zone_Alert = false;
    }
    else if (callTime > MAXCALLTIME ) { 
      zone_Appel = true; 
      zone_Info = false;
      zone_Alert = false;
    }
  }

  /////////////////////////////////////////////////////////////////////
  void zoneAlert() {
    noStroke();
    fill(0);
    rect(0,0, width, height);

    int arcSize = 150;
    strokeWeight(7);
    stroke(250,0,0);
    move += 0.8;
    if (move>TWO_PI) move = -1;
    noFill();
    arc (positX,positY,arcSize+30,arcSize+50,0,TWO_PI*move);
    arc (positX,positY,arcSize+50+move,arcSize+70+move,0,move);
    arc (positX,positY,arcSize+70+move,arcSize+100+move,0,TWO_PI-move);

    textSize(48);
    textFont(afficheur);
    fill(250,0,0,200);
    text(" Ce secrétaire Rhinoceros est ",width/2-310,height/2+50);//ajouter italique
    text(" SENSIBLE ",width/2-100,height/2+118);
    text(" 'SONART' vous révèle l'oeuvre ",width/2-310,height/2+208);
  }

  /////////////////////////////////////////////////////////////////////
  void zoneInfo() { //ZONE INFOS
    PVector v1 = tracker.getPos();

    if (v1.x <= kw*.43) { //left position visitor
      visuRight = 0;
      visuCenter = 0;
      visuLeft = updateMyImage(++visuLeft, 'L');
    }
    else if (v1.x >= kw*.70) { //right
      visuLeft = 0;
      visuCenter = 0;
      visuRight = updateMyImage(++visuRight, 'R');
    }
    else { //centre
      visuLeft = 0;
      visuRight = 0;
      visuCenter = updateMyImage(++visuCenter, 'C');
    }
    image(myImage,posImageX,posImageY);
  }

  /////////////////////////////////////////////////////////////////////
  int updateMyImage(int visuCount, char pos)
  {
    if (visuCount > ANTIJITTER ) {
      if (visuCount < OBSERVTIME) {
        switch (pos) {
        case 'L':
          myImage = rhinoLeft1;
          break;
        case 'R':
          myImage = rhinoRight1;
          break;
        default:
          myImage = rhinoMiddle;
        }
      }
      else {
        switch (pos) {
        case 'L':
          myImage = rhinoLeft2;
          break;
        case 'R':
          myImage = rhinoRight2;
          break;
        default:
          myImage = rhinoFerme;
        }
        if (visuCount >= 2*OBSERVTIME - ANTIJITTER)
          visuCount = ANTIJITTER+1;
      }
    }
    return visuCount;
  }

  /////////////////////////////////////////////////////////////////////
  void zoneAppel() { 
    textFont(afficheur);
    String titre = "Regards Augmentés : 'SONART' ";
    String sujet = "APPROCHEZ-VOUS ...COME CLOSER...";
    String complement = "Le toucher à l'ère du numérique";
    image(rhinoFerme,posImageX,posImageY);

    fill(0);
    textSize(56);

    text(titre, 300, 200);
    text(titre, 300, 200);
    posX--;

    textSize(43);
    text(sujet, posX, 250);
    if (posX<190) {
      posX= 600;
    }

    textSize(38);
    text(complement,365,135);
    text(complement,365,135);
    text(complement,365,135);
    text(complement,365,135);
    text(complement,365,135);
    //AFFICHE UN LOGO TOUT les ....
    if (millis() - lastTimeLogo >= DISPLAY_TIME) // Time to display next image
    {
      // Increment counter, then compute its modulo, ie. reset it at zero when reaching images.length
      counter = ++counter % NBLOGO;
      lastTimeLogo = millis();
    }

    image(logos[counter], 130,650);
  }

  /////////////////////////////////////////////////////////////////////
  void controlView() {
    displayKinectIR();//showCam
    mouvementCamera();//allow MovCam
    noStroke();
    textSize(36);
    textAlign(LEFT);
    fill(0);
    rect(30,30,290,280);
    textSize(12);
    textFont(controlFont);

    int controlViewPosX = 50;
    int controlViewPosY = 50; 
    int sizecontrolViewX = 260;
    int sizecontrolViewY = 200;
    int esp = 20; 
    noFill();
    strokeWeight(1);
    stroke(250);
    rect(controlViewPosX+110,controlViewPosX,35,sizecontrolViewY);
    noStroke();
    fill(250, 250,200,140);//colonne numero
    rect(controlViewPosX+110,controlViewPosX,35,sizecontrolViewY);
    noFill();
    strokeWeight(1);
    stroke(250);
    rect(controlViewPosX+110,controlViewPosX,35,sizecontrolViewY);
    fill(0,200);//rect interface
    rect(controlViewPosX-10,controlViewPosX,sizecontrolViewX+10,sizecontrolViewY); 
    fill(250);
    text("Kinect FrRate:      "  + (int) kinect.getDepthFPS(),controlViewPosX, controlViewPosY +esp);
    text("P5 FrRate:          "  + (int) frameRate, controlViewPosX, controlViewPosY+2*esp);

    text ("ZONES  ", controlViewPosX,controlViewPosY + 4*esp);
    text ("Alert DistAlarm    " + distAlarm      +   "   Press +/-",controlViewPosX,controlViewPosY + 5*esp );
    text ("Alert Tolerance    " + toleranceTime  + "     Press t/y",controlViewPosX,controlViewPosY + 6*esp );
    text ("Appel distCall     " + distCall       +   "   Press P/M",controlViewPosX,controlViewPosY + 7*esp);
    text ("Camera Angle       " + deg            +   "   Press UP/DOWN",controlViewPosX,controlViewPosY + 8*esp);
    text ("INTERFACE ON/OFF         Press I/O ",controlViewPosX,controlViewPosY + 12*esp);
  }  

  /////////////////////////////////////////////////////////////////////
  void mouvementCamera() {
    if (keyPressed==true) {
      if (key == CODED) {
        if (keyCode == UP) {
          deg++;
        } 
        else if (keyCode == DOWN) {
          deg--;
        }
      }
      deg = constrain(deg,-30,30);
      kinect.tilt(deg);
    }
  }

  /////////////////////////////////////////////////////////////////////
  void displayKinectIR() {
    PImage img = kinect.getDepthImage();
    // Being overly cautious here
    if (depth == null || img == null) return;
    // Going to rewrite the depth image to show which pixels are in threshold
    // A lot of this is redundant, but this is just for demonstration purposes
    display.loadPixels();
    for(int x = 0; x < kw; x++) {
      for(int y = 0; y < kh; y++) {

        int offset = kw-x-1+y*kw;// mirroring image
        int rawDepth = depth[offset];// Raw depth

        int pix = x+y*display.width;
        if (rawDepth < distAlarm) {
          // A red color instead
          display.pixels[pix] = color(150,50,50);
        } 
        else {
          display.pixels[pix] = img.pixels[offset];
        }
      }
    }
    display.updatePixels();
    noStroke();
    fill(0);
    rect(280,30,360,280);
    // Draw the image
    image(display,300,50,320,240);//resize la video pour debug
  }

  /////////////////////////////////////////////////////////////////////
  void quit() {
    kinect.quit();
  }
}

