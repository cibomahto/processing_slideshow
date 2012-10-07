/**
 * Grid-based screensaver thingy
 * looks for new photos and displays them
 */
import processing.opengl.*;
import java.util.concurrent.*;


/////////////////////////  Configuration options  /////////////////////////
int cols = 4;                     // Number of columns
int rows = 3;                     // Number of rows
//float assetAspectRatio = 3.0/2;   // Aspect ratio of the image assets
float assetAspectRatio = 1.0;   // Aspect ratio of the image assets

int cellSpacing = 3;              // Spacing between images, in pixels
int fadeWidth = 5;                // Amount of blur at image edges, in pixels

int transitionSpeed = 150;        // How long an image transition takes (frames)
int assetLifetime = 300;          // Length of time (frames) that an image will last.

color gridColors[] = new color[] {
      color(10,10,10),
    };

/////////////////////////  Configuration options  /////////////////////////

Grid grid;                        // Grid displays images in a random order
OverlayText overlayText;          // Text watermark
XmlImageFinder imageFinder;          // Imagefinder keeps looking for new images

void setup() {
//  size(screen.width, screen.height, OPENGL);
  size(640, 480, OPENGL);
  noCursor();

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
  imageFinder = new XmlImageFinder("http://dev.canalmercer.com/index.php/moderate/feed", dataPath("feed.xml"));
  imageFinder.start();
  
  overlayText = new OverlayText("#coolphotosbro");
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
  fill(color(0));
  rect(0, 0, width, height);

  grid.draw();
  
  overlayText.draw();
}

