class DrawableImage extends Drawable {
  PImage bitmap;                     // Image to draw
  int fadeInTime;                    // Amount of fade in time
  int fadeInTimeCounter;             // Counter to fade in
  PVector loc = new PVector();             // x,y coordinates of top left corner
  PVector extents = new PVector();         // height, width of object
  
  DrawableImage(PImage bitmap_, PVector loc_, PVector extents_, int fadeInTime_) {
    bitmap = bitmap_;
    loc = loc_;
    extents = extents_;
    
    fadeInTime = fadeInTime_;
    fadeInTimeCounter = fadeInTime_;
  }
  
  void draw() {
    // If we are fading in, do that.
    if (fadeInTimeCounter > -1) {
      int fade = int(255.0*(fadeInTime - fadeInTimeCounter)/fadeInTime);
      fadeInTimeCounter -= 1;
      
      tint(255, fade);
      image(bitmap, loc.x, loc.y, extents.x, extents.y);
      tint(255);
    }
    else if(timeToDie > -1) {
      int fade = int(255.0*(timeToDie)/fadeInTime);
      
      tint(255, fade);
      image(bitmap, loc.x, loc.y, extents.x, extents.y);
      tint(255);
    }
    else {
      image(bitmap, loc.x, loc.y, extents.x, extents.y);
    }
  }
}
