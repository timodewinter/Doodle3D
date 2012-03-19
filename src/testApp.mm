#include "testApp.h"

bool ofxFileExists(string filename) {
    ofFile f(filename);
    return f.exists();
}

// trim trailing spaces
string ofxTrimStringRight(string str) {
    size_t endpos = str.find_last_not_of(" \t\r\n");
    return (string::npos != endpos) ? str.substr( 0, endpos+1) : str;
}

// trim trailing spaces
string ofxTrimStringLeft(string str) {
    size_t startpos = str.find_first_not_of(" \t\r\n");
    return (string::npos != startpos) ? str.substr(startpos) : str;
}

string ofxTrimString(string str) {
	return ofxTrimStringLeft(ofxTrimStringRight(str));;
}

vector<string> ofxLoadStrings(string filename) {
    vector<string> lines;
    filename = ofxiPhoneGetDocumentsDirectory() + filename;
    if (!ofxFileExists(filename)) {
        cout << "WARNING: ofxLoadStrings: File not found: " << filename << endl;
        return lines;
    }
    ifstream f(filename.c_str(),ios::in);
    string line;
    while (getline(f,line)) lines.push_back(ofxTrimStringRight(line));
    f.close();
    return lines;
}

void ofxSaveStrings(string filename, vector<string> lines) {
    ofFile file(ofxiPhoneGetDocumentsDirectory() + filename,ofFile::WriteOnly);
    for (int i=0; i<lines.size(); i++) file << lines[i] << endl;
    file.close();
}

//--------------------------------------------------------------
void testApp::setup() {	
    ofRegisterTouchEvents(this);
    ofxAccelerometer.setup();
    ofxiPhoneAlerts.addListener(this);
    iPhoneSetOrientation(OFXIPHONE_ORIENTATION_LANDSCAPE_RIGHT);
    ofBackground(0);
    path.setStrokeColor(0);
    path.setFilled(false);
    counter = 0;
    path.setStrokeWidth(3);
    ofEnableAlphaBlending();
    
    bg.loadImage("bg.jpg");
    
    action_url = "http://doodle3d.nl";
    ofAddListener(httpUtils.newResponseEvent,this,&testApp::newResponse);
    httpUtils.start();
    
    btnMake.set(ofPoint(910,100,90));
    btnLoad.set(ofPoint(910,263,50));
    btnSave.set(ofPoint(920,411,50));
    btnUndo.set(ofPoint(930,536,50));
    btnClear.set(ofPoint(920,680,50));
    
    bounds.set(145,155,650,460);
}

//--------------------------------------------------------------
void testApp::update(){
    
}

//--------------------------------------------------------------
void testApp::draw(){
    ofSetColor(255);
    bg.draw(0,0);
    
    if (path.getSubPaths().size()>0) {
        path.draw();        
    }
    
//    ofSetColor(255, 0, 0, 50);
//    btnMake.draw();
//    btnLoad.draw();
//    btnSave.draw();
//    btnUndo.draw();
//    btnClear.draw();
//    ofRect(bounds);

    ofSetColor(0);
    //ofDrawBitmapString("request: " + requestStr,20,20);
    ofDrawBitmapString(responseStr,20,60);

}

//--------------------------------------------------------------
void testApp::newResponse(ofxHttpResponse & response){
	responseStr = ofToString(response.status) + ": " + (string)response.responseBody;
}

//--------------------------------------------------------------
void testApp::exit(){

}

//--------------------------------------------------------------
void testApp::touchDown(ofTouchEventArgs &touch){
    
    cout << touch.x << "," << touch.y << endl;
    
    if (btnMake.hitTest(touch.x,touch.y)) make();
    else if (btnLoad.hitTest(touch.x,touch.y)) load();
    else if (btnSave.hitTest(touch.x,touch.y)) save();
    else if (btnUndo.hitTest(touch.x,touch.y)) undo();
    else if (btnClear.hitTest(touch.x,touch.y)) clear();
    else if (bounds.inside(touch.x, touch.y)) {
        if (touch.id!=0) return;
        path.moveTo(touch.x, touch.y);
    }
}

void testApp::make() {
    save();
    
    ofxHttpForm form;
    form.action = action_url;
    form.method = OFX_HTTP_POST;
    //form.addFormField("number", ofToString(counter));
    form.addFile("file",ofxiPhoneGetDocumentsDirectory() + "doodle.txt");
    //form.addFormField("data", text);
    httpUtils.addForm(form);
    requestStr = "message sent: " + ofToString(counter);
    counter++;
}
    
void testApp::load(string filename) {
    path.clear();
    vector<string> lines = ofxLoadStrings(filename);
    for (int i=0; i<lines.size(); i++) {
        vector<string> coords = ofSplitString(lines[i], " ");
        for (int j=0; j<coords.size(); j++) {
            vector<string> tuple = ofSplitString(coords[j], ",");
            if (tuple.size()!=2) return; //error in textfile
            float x = ofToFloat(tuple[0]);
            float y = ofToFloat(tuple[1]);
            if (j==0) path.moveTo(x,y);
            else path.lineTo(x,y);
        }
    }
}

void testApp::load() {
    load("doodle.txt");
    cout << "loaded?" << endl;
}

void testApp::save() {
    vector<string> lines;
    
    vector<ofSubPath> subpaths = path.getSubPaths();
    for (int i=0; i<subpaths.size(); i++) {
        vector<ofSubPath::Command> cmds = subpaths[i].getCommands();
        string line;
        for (int j=0; j<cmds.size(); j++) {
            line += ofToString(cmds[j].to.x) + "," + ofToString(cmds[j].to.y) + " ";
        }
        lines.push_back(line);
    }
    ofxSaveStrings("doodle.txt",lines);
    cout << "saved" << endl;
}

void testApp::undo() {
    if (path.getSubPaths().size()==0) return;
    path.getSubPaths().back().getCommands().erase(path.getSubPaths().back().getCommands().end());
    if (path.getSubPaths().back().getCommands().size()==0) path.getSubPaths().erase(path.getSubPaths().end());
    path.flagShapeChanged();
}

void testApp::clear() {
    path.clear();
}
             

//--------------------------------------------------------------
void testApp::touchMoved(ofTouchEventArgs &touch) {
    if (touch.id!=0) return;
    
    if (bounds.inside(touch.x, touch.y)) {
        path.lineTo(touch.x, touch.y);
    }    
}

//--------------------------------------------------------------
void testApp::touchUp(ofTouchEventArgs &touch){
    
}

//--------------------------------------------------------------
void testApp::touchDoubleTap(ofTouchEventArgs &touch){

}

//--------------------------------------------------------------
void testApp::lostFocus(){

}

//--------------------------------------------------------------
void testApp::gotFocus(){

}

//--------------------------------------------------------------
void testApp::gotMemoryWarning(){

}

//--------------------------------------------------------------
void testApp::deviceOrientationChanged(int newOrientation){

}


//--------------------------------------------------------------
void testApp::touchCancelled(ofTouchEventArgs& args){

}

