/*
  void checkDistance() 
  PVector getLerpedPos() 
  PVector getPos() {
  int getdistAlarm() {
  void setdistAlarm(int dM) {
  int gettempsTolerance() {
  void settempsTolerance(int tT) {
  int getdistAppel() {
  int gettempsToAppel() {
  void setdistAppel(int dAppel) {
  void checkAlarm() {
  void checkInfo() {


*/
class KinectTracker {

  // Size of kinect image
  int kw = 640;
  int kh = 480;

  int posImageX = 120;
  int posImageY = -25;

  int sizeImageX = 1080;
  int sizeImageY = 720;

  // zoneAlerte
  int tempsAlerte ;
  int tempsTolerance = 9;       //valeur à ajuster    
  int positX = width/2;
  int positY = 250;

  float move = 0;                //alerteVisu()

  //int distAlarm= 954;         //zoneAlarmART DECO580;
  //int distAppel = 978;        //zone d'appel ART DECOv920;
  int distAlarm = 580;
  int distAppel = 876;          //zone d'appel ART DECOv920;

  //Zone Appel
  int tempsAppel ;
  int tempsToAppel = 50;        //VALEUR à ajuster SUR SITE

  int tempsObservation = 47;
  int antiJitter = 10;
  int visuGauche = 0;           //timer Position visuGauche
  int visuDroite = 0;
  int visuCentre = 0;

  // Interpolated location
  PVector loc;
  PVector lerpedLoc;

  //zoneInfo
  int tempsInfo ;
  int tempsToInfo = 10;         //valeur à ajuste
  //distance Depth data
  int[] depth;
  //control orientation camera 
  float deg = -26;

  boolean affichCam = false; 
  // Raw location
  boolean gauche,droite,centre;

  PImage display;

//////////////////////////////////////////////////////////////
  // constructor
  KinectTracker() {
    kinect.start();
    kinect.enableDepth(true);
    // kinect.processDepthImage(true);
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

    float count = 0;
    float posX = 0;
    float posY = 0;
    float pos = 0;
    float appel = 0;

    for(int x = 0; x < kw; x++) {                                   // x+=2 ??
      for(int y = 0; y < kh; y++) {                                 // y+=2 ??
        int offset = kw-x-1+y*kw;    // Mirroring the image      
        int rawDepth = depth[offset];// Grabbing the raw depth
        // Testing against threshold

        //ZONE ALERTE ALARM
        if (rawDepth < distAlarm) {
          count++;
          //utile ?
        }
        //ZONE INFORMATION
        else if (rawDepth > distAlarm && rawDepth <= distAppel) {
          posX += x; // ???
          posY += y; // ???
          pos++;
          //utile ?
        }
        //ZONE APPEL
        else if (rawDepth >distAppel ) {
          appel++;
          //utile ?
        }
      }
    }

    // As long as we found something
    if (count != 0) {
      tempsAlerte += 1;  
      tempsAppel = 0;
      tempsInfo = 0;
    }
    else if (pos != 0) {//INFO
      loc = new PVector(posX/pos, posY/pos); //affiche la position
      tempsInfo += 1;
      tempsAlerte = 0;
      tempsAppel = 0;
    }
    else if (appel != 0) {//APPEL
      tempsAppel += 1;
      tempsAlerte = 0;
      tempsInfo=0;
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

  // ALARM
  int getdistAlarm() {
    return distAlarm;
  }

  void setdistAlarm(int dM) {
    distAlarm=  dM;
  }

  int gettempsTolerance() {
    return tempsTolerance;
  }

  void settempsTolerance(int tT) {
    tempsTolerance=  tT;
  }

  // INFO
  int getdistAppel() {
    return distAppel;
  }

  int gettempsToAppel() {
    return tempsToAppel;
  }

  void setdistAppel(int dAppel) {
    distAppel=  dAppel;
  }

/////////////////////////////////////////////////////////////////////
  void checkAlarm() {
    if (tempsAlerte > tempsTolerance ) {
      zone_Alerte = true;
      zone_Appel = false;
      zone_Info = false;
      alarm.trigger();
    }
  }

/////////////////////////////////////////////////////////////////////
  void checkInfo() {
    if (tempsInfo > tempsToInfo ) {
      zone_Info = true; 
      zone_Appel = false;
      zone_Alerte = false;
    }
  }

/////////////////////////////////////////////////////////////////////
  void checkAppel() { //ZONE APPEL text intro//lOGOS
    if (tempsAppel > tempsToAppel ) { 
      zone_Appel = true; 
      zone_Info = false;
      zone_Alerte = false;
    }
  }

/////////////////////////////////////////////////////////////////////
  void zoneAlerte() {//ALEEERRTE
    pixelizImage(); //infamous trick , too much trouble with the audio buffer 
    alerteVisu();   
  }

/////////////////////////////////////////////////////////////////////
  void alerteVisu() {
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

    ///LIMITE LE TEMPS DE L ALERTE
    if (millis() - lastTime >= 3000) // Time to display next image //
    {
      // Increment counter, then compute its modulo, ie. reset it at zero when reaching images.length   
      lastTime = millis();
      // zone_Info = true;
      zone_Alerte = false;
    }
  }

  /////////////////////////////////////////////////////////////////////
  void pixelizImage() {
    noStroke();
    for ( int i = 0; i < width; i += pixel ) {
      for ( int j = 0; j < height; j += pixel) {
        color c = rhinoFerme.get(i,j);
        fill(0);
        rect(i, j, pixel, pixel);
      }
    }
    if (pixel < pixelMin) {
      pixel = pixelMin;
      blur = 1;
    }
    if (pixel > pixelMax) {
      pixel = pixelMax;
      blur = -1;
    }
    pixel += blur;
    //check Pixelate example http://processing.org/discourse/yabb2/YaBB.pl?num = 1195520410
  }
  // FIN ALERTE FUNCTIONS 

/////////////////////////////////////////////////////////////////////
  void zoneInfo() {//ZONE INFOS
    PVector v1 = tracker.getPos();

    if (v1.x <= kw*.43) {//GAUCHE position visiteur à gauche
      visuGauche  += 1;
      visuDroite  = 0;
      visuCentre  = 0;
      gauche = true;
    }

    if (v1.x >= kw*.66) {//DROITE
      visuDroite += 1;
      visuGauche = 0;
      visuCentre = 0;
      droite = true;
    }

    if (v1.x > kw*.43 && v1.x < kw*.66) {//CENTRE
      centre = true ; 
      visuCentre += 1;
      visuGauche = 0;
      visuDroite = 0;
    }

    VizCentre();
    VizDroite();
    VizGauche();
  }

/////////////////////////////////////////////////////////////////////
  void VizGauche() {
    if (gauche == true && visuGauche>antiJitter ) {
      droite = false;
      centre = false;
      if (visuGauche < tempsObservation) {
        image(rhinoLeft1,posImageX,posImageY,sizeImageX,sizeImageY);
      }
      else if (visuGauche > tempsObservation) {
        image(rhinoLeft2,posImageX,posImageY,sizeImageX,sizeImageY);
      } 

      if (visuGauche >= 2*tempsObservation) visuGauche = antiJitter+1;
    }
  }

/////////////////////////////////////////////////////////////////////
  void VizDroite() {
    if  (droite == true &&visuDroite > antiJitter) {
      gauche = false;
      centre = false;
      if ( visuDroite <tempsObservation) {
        image(rhinoRight1,posImageX,posImageY,sizeImageX,sizeImageY);
      }
      else if (visuDroite > tempsObservation) {
        image(rhinoRight2,posImageX,posImageY,sizeImageX,sizeImageY);
      }
      if (visuDroite >= (2*tempsObservation)) visuDroite = antiJitter+1;  //re initialise le compteur AntiJitter
    }
  }

/////////////////////////////////////////////////////////////////////
  void VizCentre() {
    if  (centre == true  &&visuCentre>antiJitter) {
      droite = false;
      gauche = false;
      if ( visuCentre<tempsObservation) {
        image(rhinoMiddle,posImageX,posImageY,sizeImageX,sizeImageY);
      }
      else if (visuCentre > tempsObservation ) {
        image(rhinoFerme,posImageX,posImageY,sizeImageX,sizeImageY);
      }
      if (visuCentre > 2*tempsObservation) visuCentre = antiJitter+1;
    }
  }

/////////////////////////////////////////////////////////////////////
  void zoneAppel() { 
    tempsAppel += 1;    

    textFont(afficheur);
    String titre = " Regards Augmentés 'SONART' ";
    String sujet = " Le toucher à l'ère du numérique ";

    image(rhinoFerme,posImageX,posImageY,sizeImageX,sizeImageY);

    fill(0);
    textSize(48);
    text(titre,300, 190);
    textSize(36);
    text(sujet,xText-50, 230);
    fill(50,50,200);
    xText -= 1;

    if(xText < 205) {
      xText = 700 + sujet.length();
    }

    //AFFICHE UN LOGO TOUT les ....
    if (millis() - lastTime >= DISPLAY_TIME) // Time to display next image
    {
      // Increment counter, then compute its modulo, ie. reset it at zero when reaching images.length
      counter = ++counter % nbLogo;
      lastTime = millis();
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
    int nbControl = 3;
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
    text ("Alerte DistAlarm   " + distAlarm      +   "   Press +/-",controlViewPosX,controlViewPosY + 5*esp );
    text ("Alerte Tolerance   " + tempsTolerance + "     Press t/y",controlViewPosX,controlViewPosY + 6*esp );
    text ("Appel DistAppel    " + distAppel      +   "   Press P/M",controlViewPosX,controlViewPosY + 7*esp);
    text ("Camera Angle       " + deg            +     " Press UP/DOWN",controlViewPosX,controlViewPosY + 8*esp);
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
  void affichePosition() {
    // Let's draw the raw location
    PVector v1 = tracker.getPos();
    fill(50,100,250,200);
    noStroke();
    ellipse(v1.x,v1.y,20,20);
    fill(255);
    text("posX = " + int(v1.x) + "\nposY = " + int(v1.y), v1.x,v1.y);
    // Let's draw the "lerped" location
    PVector v2 = tracker.getLerpedPos();
    fill(100,250,50,200);
    noStroke();
    ellipse(v2.x,v2.y,20,20);
  }

/////////////////////////////////////////////////////////////////////
  void quit() {
    kinect.quit();
  }
}

