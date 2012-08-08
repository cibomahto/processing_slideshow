class DrawableRectangle extends Drawable {
  color rectColor;
  int fadeInTime;
  int fadeInTimeCounter;
  int fadeWidth;
  PVector loc = new PVector();             // x,y coordinates of top left corner
  PVector extents = new PVector();         // height, width of object  
  
  DrawableRectangle(color rectColor_, PVector loc_, PVector extents_, int fadeInTime_, int fadeWidth_) {
    rectColor = rectColor_;
    loc = loc_;
    extents = extents_;
    
    fadeInTime = fadeInTime_;
    fadeInTimeCounter = fadeInTime_;
    fadeWidth = fadeWidth_;
  }
  
  void draw() {
    int fade = 0;
    
    if (fadeInTimeCounter > -1) {
      fade = int(255.0*(fadeInTime - fadeInTimeCounter)/fadeInTime);
      fadeInTimeCounter -= 1;
    }
    else if(timeToDie > -1) {      
      fade = int(255.0*(timeToDie)/fadeInTime);
    }
    else {
      fade = 255;
    }

    drawFuzzyRectangle(loc.x, loc.y, extents.x, extents.y,
                        fadeWidth, color(red(rectColor), green(rectColor), blue(rectColor), fade), g);
  }
}
