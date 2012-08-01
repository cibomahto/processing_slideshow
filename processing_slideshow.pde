/**
 * Simple grid-based screensaver thingy
 * looks for new photos and displays them
 */

import java.util.concurrent.*;
//import fullscreen.*; 

//FullScreen fs;

int cols = 4;
int rows = 3;

int cellSpacing = 6;

int screenWidth = 1366;
int screenHeight = 768;
float assetAspectRatio = 3.0/2;

Boolean doFullScreen = false;

int transitionSpeed = 150;
int assetLifetime = 300;

// List of things we are drawing
ArrayList drawables;

Grid grid;

ImageFinder imageFinder;
Thread loadThread;

void setup() {
  size(screenWidth, screenHeight);

  colorMode(RGB, 255, 255, 255, 255);
  
  drawables = new ArrayList();

  grid = new Grid(new PVector(cols, rows), assetAspectRatio, 
                  assetLifetime, transitionSpeed, cellSpacing);
  
//  imageFinder = new ImageFinder("/Users/matthewmets/Desktop/Untitled");
  imageFinder = new ImageFinder(sketchPath + "/data");
  loadThread = new Thread(imageFinder);

  loadThread.start();

  noStroke();  
  fill(color(0));
  rect(0,0,width,height);
  
  grid.render();

  if (doFullScreen) {
    // Create the fullscreen object
//    fs = new FullScreen(this); 
  
    // enter fullscreen mode
//    fs.enter();
  }
}


void draw() {

  // If we have any new images available, add them
  if(imageFinder.imageAvailable()) {
    println("adding image");
    grid.addImage(imageFinder.getNextImage());
  }
  
  // Update the grid
  grid.update();

  // Handle all of the drawables
  for (int i = 0; i < drawables.size(); i++) {
    Drawable drawable = (Drawable) drawables.get(i);
    
    drawable.update();
    drawable.render();  
  }
  
  // Remove dead drawables
  for (int i = drawables.size() - 1; i >= 0; i-- ) {
    if( ((Drawable) drawables.get(i)).isdead() ) {
      drawables.remove(i);
    }
  }
}


// File functions are from:
// http://processing.org/learning/topics/directorylist.html


// This function returns all the files in a directory as an array of Strings  
String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    // If it's not a directory
    return null;
  }
}

// This function returns all the files in a directory as an array of File objects
// This is useful if you want more info about the file
File[] listFiles(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    File[] files = file.listFiles();
    return files;
  } else {
    // If it's not a directory
    return null;
  }
}

// Function to get a list ofall files in a directory and all subdirectories
ArrayList listFilesRecursive(String dir) {
   ArrayList fileList = new ArrayList(); 
   recurseDir(fileList,dir);
   return fileList;
}

// Recursive function to traverse subdirectories
void recurseDir(ArrayList a, String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    // If you want to include directories in the list
    a.add(file);  
    File[] subfiles = file.listFiles();
    for (int i = 0; i < subfiles.length; i++) {
      // Call this function on all files in this directory
      recurseDir(a,subfiles[i].getAbsolutePath());
    }
  } else {
    a.add(file);
  }
}

