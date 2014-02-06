// Draw an overlay (probably just a hashtag) on top of the image
class OverlayText {
  String m_title;
  PFont m_font;
  color m_textColor;
  
  OverlayText(String title, float textSize, color textColor) {
    m_title = title;
    m_font = createFont("Helvetica", textSize);
    m_textColor = textColor;
  }
  
  void draw() {
    textFont(m_font);
    fill(m_textColor);
    text(m_title, width - textWidth(m_title) - textDescent(), textAscent()); //height - textDescent());
  }
}
