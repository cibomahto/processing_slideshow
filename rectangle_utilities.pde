// Draw a rectangle which can have differently colored edges
// @param x X coordinate of the top-left corner of the rectangle (pixels)
// @param y X coordinate of the top-left corner of the rectangle (pixels)
// @param widt Width of the rectangle (pixels)
// @param heigh Height of the rectangle (pixels)
// @param tlcolor Color of the top-left rectangle corner
// @param trcolor Color of the top-right rectangle corner
// @param brcolor Color of the bottom-right rectangle corner
// @param blcolor Color of the bottom-left rectangle corner
// @param context PGraphics object to draw on
void makeRectangle(float x, float y, float widh, float heigh,
                   color tlcolor, color trcolor,
                   color brcolor, color blcolor,
                   PGraphics context) {
  context.beginShape(POLYGON);
    context.fill(tlcolor);
      context.vertex(x, y);
    context.fill(trcolor);
      context.vertex(x+widh, y);
    context.fill(brcolor);
      context.vertex(x+widh, y+heigh);
    context.fill(blcolor);
      context.vertex(x, y+heigh);
  context.endShape(CLOSE);
}

// Draw a gradient corner by making triangles
// TODO: do this directly somehow; a shader?
// @param x X coordinate of the center of the semicircle (pixels)
// @param y Y coordinate of the center of the semicircle (pixels)
// @param rad Radius of the semicircle (pixels)
// @param divisions Number of triangle divisions to make (more=smoother)
// @param quadrant Which quadrant to draw in 
// @param insideColor Color to use for the center of the semicircle
// @param outsideColor Color to use for the outside of the semicircle
// @param context PGraphics object to draw on
void makeGradientCorner(float x, float y, float rad,
                float divisions, float quadrant,
                color insideColor, color outsideColor,
                PGraphics context) {
  context.beginShape(TRIANGLES); 
    for(float angle = quadrant*PI/2;
        angle < (quadrant + 1)*PI/2 - .001;
        angle += PI/divisions/2) {
      context.fill(insideColor);
        context.vertex(x, y);
      context.fill(outsideColor);
        context.vertex(x+cos(angle)*rad,                y-sin(angle)*rad);
        context.vertex(x+cos(angle+PI/divisions/2)*rad, y-sin(angle+PI/divisions/2)*rad);
    }
  context.endShape(CLOSE);
}

// Draw a fuzzy rectangle at the specified position
// @param x X coordinate of the top-left corner of the rectangle (pixels)
// @param y X coordinate of the top-left corner of the rectangle (pixels)
// @param widt Width of the rectangle (pixels)
// @param heigh Height of the rectangle (pixels)
// @param radius Radius of the fuzzing (pixels)
// @param fgcolor color of the rectangle
// @param context PGraphics object to draw on
void drawFuzzyRectangle(float x, float y, float widt, float heigh,
                        float rad, color fgcolor,
                        PGraphics context) {
  // Handle the case where the radius is too big, by clipping it to 1/2 the max height or width.
  float max_rad = min(widt/2, heigh/2);
  rad = min(rad, max_rad);
  color bgcolor = color(red(fgcolor),green(fgcolor),blue(fgcolor),0);
  
  makeRectangle(x+rad, y+rad,        widt-2*rad, heigh-2*rad, fgcolor, fgcolor, fgcolor, fgcolor, context);
  makeRectangle(x+rad, y,            widt-2*rad, rad,         bgcolor, bgcolor, fgcolor, fgcolor, context);
  makeRectangle(x, y+rad,            rad, heigh-2*rad,        bgcolor, fgcolor, fgcolor, bgcolor, context);
  makeRectangle(x+rad, y+rad+heigh-2*rad,  widt-2*rad, rad,   fgcolor, fgcolor, bgcolor, bgcolor, context);
  makeRectangle(x+widt-rad, y+rad,   rad, heigh-2*rad,        fgcolor, bgcolor, bgcolor, fgcolor, context);
  makeGradientCorner(x+widt-rad, y+rad,       rad, 9,  0,   fgcolor, bgcolor, context);
  makeGradientCorner(x+rad, y+rad,            rad, 9,  1,   fgcolor, bgcolor, context);
  makeGradientCorner(x+rad, y+heigh-rad,      rad, 9,  2,   fgcolor, bgcolor, context);
  makeGradientCorner(x+widt-rad, y+heigh-rad, rad, 9,  3,   fgcolor, bgcolor, context);
}
