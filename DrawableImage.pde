class DrawableImage extends Drawable {
  PImage m_bitmap;                     // Image to draw
  int m_fadeInTime;                    // Amount of fade in time
  int m_fadeInTimeCounter;             // Counter to fade in
  PVector m_loc = new PVector();       // x,y coordinates of top left corner
  PVector m_extents = new PVector();   // height, width of object
  
  DrawableImage(PImage bitmap, PVector loc, PVector extents, int fadeInTime) {
    m_bitmap = bitmap;
    m_loc = loc;
    m_extents = extents;
    
    m_fadeInTime = fadeInTime;
    m_fadeInTimeCounter = fadeInTime;
  }
  
  void draw() {
    // If we are fading in, do that.
    if (m_fadeInTimeCounter > -1) {
      int fade = int(255.0*(m_fadeInTime - m_fadeInTimeCounter)/m_fadeInTime);
      m_fadeInTimeCounter -= 1;
      
      tint(255, fade);
      image(m_bitmap, m_loc.x, m_loc.y, m_extents.x, m_extents.y);
      tint(255);
    }
    else if(m_timeToDie > -1) {
      int fade = int(255.0*(m_timeToDie)/m_fadeInTime);
      
      tint(255, fade);
      image(m_bitmap, m_loc.x, m_loc.y, m_extents.x, m_extents.y);
      tint(255);
    }
    else {
      image(m_bitmap, m_loc.x, m_loc.y, m_extents.x, m_extents.y);
    }
  }
}
