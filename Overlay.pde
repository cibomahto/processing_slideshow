// Draw an overlay (probably just a hashtag) on top of the image
class OverlayText {
  String m_title;
  PFont m_font;
  color m_color;
  
  OverlayText(String title) {
    m_title = title;
    m_font = createFont("Helvetica", 80);
    m_color = color(255,255,255);
  }
  
  void draw() {
    textFont(m_font);
    fill(m_color);
    text(m_title, width - textWidth(m_title) - textDescent(), height - textDescent()); //width - textWidth(m_title));
  }
}
