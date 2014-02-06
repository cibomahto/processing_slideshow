import fullscreen.*;
import japplemenubar.*;

/**
 * Grid-based screensaver thingy
 * looks for new photos and displays them
 */
import processing.opengl.*;
import java.util.concurrent.*;


/////////////////////////  Configuration options  /////////////////////////

int cols = 5;                     // Number of columns
int rows = 3;                     // Number of rows
//float assetAspectRatio = 3.0/2;   // Aspect ratio of the imdage assets
float assetAspectRatio = 1;   // Aspect ratio of the image assets

int cellSpacing = 3;              // Spacing between images, in pixels
int fadeWidth = 5;                // Amount of blur at image edges, in pixels

int transitionSpeed = 150;        // How long an image transition takes (frames)
int assetLifetime = 300;          // Length of time (frames) that an image will last.

color gridColors[] = new color[] {
  color(10,10,10),
};

String overlayTextTitle = "Instagram #sweet5";
float overlayTextSize = 80;
color overlayTextColor = color(255,255,255);

color backgroundColor = color(0,0,0);

//String serverAddress = "http://dev.canalmercer.com/index.php/moderate/feed";
String serverAddress = "http://192.168.1.179/index.php/moderate/feed";

/////////////////////////  Configuration options  /////////////////////////



Grid grid;                        // Grid displays images in a random order
OverlayText overlayText;          // Text watermark
XmlImageFinder imageFinder;          // Imagefinder keeps looking for new images

SoftFullScreen fs; 

void setup() {
  size(displayWidth, displayHeight);
//  size(640, 480, OPENGL);
  noCursor();
  
  fs = new SoftFullScreen(this,1);
  fs.enter();

  grid = new Grid(
    cols, rows, 
    assetAspectRatio, 
    assetLifetime, 
    transitionSpeed, 
    cellSpacing,
    fadeWidth,
    gridColors
  );

//  imageFinder = new ImageFinder(sketchPath + "/data");
  imageFinder = new XmlImageFinder(serverAddress, dataPath("feed.xml"));
  imageFinder.start();
  
  overlayText = new OverlayText(overlayTextTitle, overlayTextSize, overlayTextColor);
}


void draw() {
  // If we have any new images available, add them
  if (imageFinder.imageAvailable()) {
    grid.addImage(imageFinder.getNextImage());
  }

  // Update the grid
  grid.update();

  // Re-draw the display
  noStroke();
  fill(backgroundColor);
  rect(0, 0, width, height);

  grid.draw();
  
  overlayText.draw();
}

