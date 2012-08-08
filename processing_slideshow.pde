/**
 * Simple grid-based screensaver thingy
 * looks for new photos and displays them
 */
import processing.opengl.*;
import java.util.concurrent.*;


/////////////////////////  Configuration options  /////////////////////////
int cols = 4;                     // Number of columns
int rows = 3;                     // Number of rows
float assetAspectRatio = 3.0/2;   // Aspect ratio of the image assets

int cellSpacing = 0;              // Spacing between images, in pixels
int fadeWidth = 10;                // Amount of blur at image edges, in pixels

int transitionSpeed = 150;        // How long an image transition takes (frames)
int assetLifetime = 300;          // Length of time (frames) that an image will last.

color gridColors[] = new color[] {
      color(240),
      color(220),
      color(200),
      color(180),
    };

/////////////////////////  Configuration options  /////////////////////////

Grid grid;                        // Grid displays images in a random order
ImageFinder imageFinder;          // Imagefinder keeps looking for new images
Thread loadThread;

void setup() {
//  size(screen.width, screen.height, OPENGL);
  size(640, 480, OPENGL);

  grid = new Grid(
    cols, rows, 
    assetAspectRatio, 
    assetLifetime, 
    transitionSpeed, 
    cellSpacing,
    fadeWidth
  );

  for(int i = 0; i < gridColors.length; i++) {
    grid.addColor(gridColors[i]);
  }

  imageFinder = new ImageFinder(sketchPath + "/data");
  loadThread = new Thread(imageFinder);
  loadThread.start();
}


void draw() {
  // If we have any new images available, add them
  if (imageFinder.imageAvailable()) {
    println("Found new file");
    grid.addImage(imageFinder.getNextImage());
  }

  // Update the grid
  grid.update();

  // Re-draw the display
  noStroke();
  fill(color(0));
  rect(0, 0, width, height);

  grid.draw();
}

