/**
 * Simple grid-based screensaver thingy
 * looks for new photos and displays them
 */

import java.util.concurrent.*;


/////////////////////////  Configuration options  /////////////////////////
int cols = 4;                     // Number of columns
int rows = 3;                     // Number of rows
float assetAspectRatio = 3.0/2;   // Aspect ratio of the image assets

int cellSpacing = 6;              // Spacing between images, in pixels

int transitionSpeed = 150;        // How long an image transition takes (frames)
int assetLifetime = 300;          // Length of time (frames) that an image will last.
/////////////////////////  Configuration options  /////////////////////////

Grid grid;                        // Grid object

ImageFinder imageFinder;
Thread loadThread;


void setup() {
  size(screen.width, screen.height);
//  size(640,480);

  grid = new Grid(
    cols, rows,
    assetAspectRatio, 
    assetLifetime,
    transitionSpeed,
    cellSpacing
  );
  
  imageFinder = new ImageFinder(sketchPath + "/data");
  loadThread = new Thread(imageFinder);
  loadThread.start();
}


void draw() {
  // If we have any new images available, add them
  if(imageFinder.imageAvailable()) {
    println("Found new file");
    grid.addImage(imageFinder.getNextImage());
  }
  
  // Update the grid
  grid.update();
  
  // Re-draw the display
  noStroke();
  fill(color(0));
  rect(0,0,width,height);
  
  grid.draw();
}


