#pragma once

#include "ofMain.h"
#include "ofxiPhone.h"
#include "ofxiPhoneExtras.h"
#include "ofxHttpUtils.h"
#include "RoundButton.h"

class testApp : public ofxiPhoneApp {
	
public:
	void setup();
	void update();
	void draw();
	void exit();
	
	void touchDown(ofTouchEventArgs &touch);
	void touchMoved(ofTouchEventArgs &touch);
	void touchUp(ofTouchEventArgs &touch);
	void touchDoubleTap(ofTouchEventArgs &touch);
	void touchCancelled(ofTouchEventArgs &touch);

	void lostFocus();
	void gotFocus();
	void gotMemoryWarning();
	void deviceOrientationChanged(int newOrientation);

    void newResponse(ofxHttpResponse & response);
    
    void make();
    void load();
    void save();
    void undo();
    void clear();
    void load(string filename);
    
    int counter;
    string requestStr,responseStr,action_url;
    ofPath path;
    ofxHttpUtils httpUtils;
    ofImage bg;
    
    RoundButton btnMake,btnLoad,btnSave,btnUndo,btnClear;
    ofRectangle bounds;
};


