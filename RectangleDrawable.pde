class RectangleDrawable extends Drawable {
  color rectColor;
  int fadeInTime;
  int fadeInTimeCounter;
  
  RectangleDrawable(color rectColor_, PVector loc_, PVector extents_, int fadeInTime_) {
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
  
  void render() {
    // If we are fading in, do that.
    if (fadeInTimeCounter > -1) {
      int fade = int(255.0*(fadeInTime - fadeInTimeCounter)/fadeInTime);
      fadeInTimeCounter -= 1;
      
      fill(rectColor, fade);
      noStroke();
      rect(loc.x, loc.y, extents.x, extents.y);
    }
  }
}
