#pragma once
#include "ofMain.h"


class RoundButton {
public:
    
    void set(ofPoint pos) {
        this->pos = ofPoint(pos.x,pos.y);
        this->radius = pos.z; //used as Radius
    }
    
    void draw() {
        ofCircle(pos,radius);
    }
    
    bool hitTest(int x, int y) {
        return pos.distance(ofPoint(x,y))<=radius;
    }
    
    ofPoint pos;
    float radius;
};