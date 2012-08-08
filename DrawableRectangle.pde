class DrawableRectangle extends Drawable {
  color m_rectColor;
  int m_fadeInTime;
  int m_fadeInTimeCounter;
  int m_fadeWidth;
  PVector m_loc = new PVector();             // x,y coordinates of top left corner
  PVector m_extents = new PVector();         // height, width of object  
  
  DrawableRectangle(color rectColor, PVector loc, PVector extents, int fadeInTime, int fadeWidth) {
    m_rectColor = rectColor;
    m_loc = loc;
    m_extents = extents;
    
    m_fadeInTime = fadeInTime;
    m_fadeInTimeCounter = fadeInTime;
    m_fadeWidth = fadeWidth;
  }
  
  void draw() {
    int fade = 0;
    
    if (m_fadeInTimeCounter > -1) {
      fade = int(255.0*(m_fadeInTime - m_fadeInTimeCounter)/m_fadeInTime);
      m_fadeInTimeCounter -= 1;
    }
    else if(m_timeToDie > -1) {
      fade = int(255.0*(m_timeToDie)/m_fadeInTime);
    }
    else {
      fade = 255;
    }

    drawFuzzyRectangle(m_loc.x, m_loc.y, m_extents.x, m_extents.y,
                        m_fadeWidth, color(red(m_rectColor), green(m_rectColor), blue(m_rectColor), fade), g);
  }
}
