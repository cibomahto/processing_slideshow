class DrawableRectangle extends Drawable {
  color rectColor;
  int fadeInTime;
  int fadeInTimeCounter;
  PVector loc = new PVector();             // x,y coordinates of top left corner
  PVector extents = new PVector();         // height, width of object  
  
  DrawableRectangle(color rectColor_, PVector loc_, PVector extents_, int fadeInTime_) {
    rectColor = rectColor_;
    loc = loc_;
    extents = extents_;
    
    fadeInTime = fadeInTime_;
    fadeInTimeCounter = fadeInTime_;
  }
  
  void update() {
    if (timeToDie > 0) {
      timeToDie -= 1;
    }
    
    if (timeToDie == 0) {
      dead = true;
    }
  }
  
  void draw() {
    int fade = int(255.0*(fadeInTime - fadeInTimeCounter)/fadeInTime);
    fill(rectColor, fade);
    noStroke();
    rect(loc.x, loc.y, extents.x, extents.y);
    
    // If we are fading in, do that.
    if (fadeInTimeCounter > -1) {
      fadeInTimeCounter -= 1;
    }
  }
}
