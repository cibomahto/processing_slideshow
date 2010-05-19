/**
 * Simple grid-based screensaver thingy
 * looks for new photos and displays them
 */

import java.util.concurrent.*;
import fullscreen.*; 

FullScreen fs;

int cols = 5;
int rows = 4;

int cellSpacing = 6;

int screenWidth = 800;
int screenHeight = 600;
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
  
  imageFinder = new ImageFinder(sketchPath + "/data");
  loadThread = new Thread(imageFinder);

  loadThread.start();

  noStroke();  
  fill(color(0));
  rect(0,0,width,height);
  
  grid.render();

  if (doFullScreen) {
    // Create the fullscreen object
    fs = new FullScreen(this); 
  
    // enter fullscreen mode
    fs.enter();
  }
}


void draw() {

  // If we have any new images available, add them
  if(imageFinder.imageAvailable()) {
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


// Image finder load all available images, then periodically searches for new ones.
// It then passes them to the grid for display.
class ImageFinder implements Runnable {
  String path;
  
  // Last time we scanned the directory
  Date lastChecked;

  // Queue holding the enemies that are ready to shove out the door
  private LinkedBlockingQueue  readyQueue = new LinkedBlockingQueue();
  
  ImageFinder(String path_) {
    path = path_;    
  }

  // Add an image to the queue, presizing it as necessary
  void addImage(PImage bitmap) {
    PVector imageSize = grid.getImageSize();
    bitmap.resize(int(imageSize.x), int(imageSize.y));

    // Add some sample images
    try{ 
      readyQueue.put(bitmap);
    } catch( InterruptedException e ) {
      println("Interrupted Exception caught");
    }
  }
  
  public void run() {
        println(new Date());
    
    // Find anything in the directory that looks like an image, and open it.
    File[] files = listFiles(path);
    for (int i = 0; i < files.length; i++) {
      File f = files[i];
      
      String fileName = f.getName();

      if (fileName.endsWith(".JPG") || fileName.endsWith(".jpg")) {
        addImage(loadImage(fileName));
      }
    }
    
    lastChecked = new Date();
    
    while(true) {
      // We should be polling for new images here, and adding them
      
      try{ 
        Thread.sleep(3600);
      } catch( InterruptedException e ) {
        println("Interrupted Exception caught");
      }
      
      Date newLastChecked = new Date();
      
      println("Checking for files modified after" + lastChecked);
      // Find anything in the directory that looks like an image, and open it.
      files = listFiles(path);
      for (int i = 0; i < files.length; i++) {
        File f = files[i];
      
        String fileName = f.getName();
        
        Date lastModified = new Date(f.lastModified());
        
        if (lastChecked.before(lastModified)) {
          println(fileName);
          if (fileName.endsWith(".JPG") || fileName.endsWith(".jpg")) {
            addImage(loadImage(fileName));
          }
        }
      }
      
      lastChecked = newLastChecked;
    }
  }
  
  public boolean imageAvailable() {
    return (readyQueue.size() > 0);
  }
  
  public int imageCount() {
    return readyQueue.size();
  }
  
  public PImage getNextImage() {
    return (PImage) readyQueue.poll(); 
  }
}


// Grid asset store, that manages the dispaly of all gridded objects
class Grid {
  PVector gridSize;  // rows and colums to make the grid

  int gWidth;
  int gHeight;


  // Number of positions in the grid
  int cellCount;
  
  // Images we could potentially draw
  ArrayList images;
  
  // Rectangle colors we can draw
  color[] colors;
  
  // Images that we are currently displaying
  Drawable[] cellAssets;
  
  // Lifetimes for each object in the grid
  int[] lifetimes;
  
  // Minimum number of frames an asset should be displayed before it can be replaced.
  int minLifetime;
  
  // Number of frames it takes to fade in an asset
  int fadeInTime;
  
  // Counter so that we don't replace more than one asset at a time
  int timeTillNextReplacement = 0;

  // Image size and location
  PVector imageSize;
  
  PVector imageSpacing;

  float imageAspectRatio;

  // Offset of grid from origin, used to center grid in letterboxed scenarios
  PVector gridOffset;
  
  // Border between cells
  int cellSpacing;
  
  Grid(PVector gridSize_, float imageAspectRatio_, int minLifetime_, int fadeInTime_, int cellSpacing_) {
    images = new ArrayList();
    
    imageAspectRatio = imageAspectRatio_;
    
    gridSize = gridSize_;
    minLifetime = minLifetime_;
    fadeInTime = fadeInTime_;

    cellSpacing = cellSpacing_;

    // Precompute the image sizes
    
    // First, see if we have to letterbox
    gWidth = width;
    gHeight = height;
    
    float targetAspectRatio = imageAspectRatio*gridSize.x/gridSize.y;
    
    if (abs(gWidth/gHeight - targetAspectRatio) > .001) {
      if (targetAspectRatio > gWidth/gHeight) {
        gHeight = int(gWidth/targetAspectRatio);
      }
      else {
        gWidth = int(gHeight*targetAspectRatio);
      }
    }

    // Center the grid 
    gridOffset = new PVector(int((width - gWidth)/2), int((height - gHeight)/2));
    
    // Force the image to have integer size, rounding up
    imageSize = new PVector(int((gWidth - cellSpacing*(gridSize.x - 1))/gridSize.x +.5),
                            int((gHeight - cellSpacing*(gridSize.y - 1))/gridSize.y + .5));

    // Leave the spacing as a float, so it will fill evently
    imageSpacing = new PVector(gWidth/gridSize.x + cellSpacing/gridSize.x,
                               gHeight/gridSize.y + cellSpacing/gridSize.y);

    
    cellCount = int(gridSize.x * gridSize.y);
    
    cellAssets =  new Drawable[cellCount];
    lifetimes =  new int[cellCount];

    // Add some MAKE-friendly colors    
    colors = new color[] {color(156, 185, 95),
                          color(235, 169, 85),
                          color(238, 78, 77),
                          color(29, 90, 136),
                          color(47, 178, 189),
                          color(208, 105, 85),
                          color(200, 176, 77) };

    // pre-fill with colors
    for (int cell = 0; cell < cellCount; cell++) {
      int newColorIndex = int(random(int(colors.length)));
      replaceAsset( cell, colors[newColorIndex] );
    }

    // and randomize starting lifetimes   
    for (int i = 0; i < cellCount; i++) {
      lifetimes[i] = int(random(minLifetime));
    }
  }

  // Get the image size, allows a separate thread to resize the image before sending it here
  PVector getImageSize() {
    return imageSize;
  }

  // Add a new image to the grid
  void addImage(PImage bitmap) {
    images.add(bitmap);
      
    // TODO: remove some images if we have a lot of them (?)
  }
  
  // Get a PVector pointing to the location of a cell
  PVector getCellLocation(int cell) {
    int assetX = int(int(cell%gridSize.x)*imageSpacing.x + gridOffset.x);
    int assetY = int(int(cell/gridSize.x)*imageSpacing.y + gridOffset.y);
 
    return new PVector(assetX, assetY);
  }

  void replaceAsset(int cell, Drawable newAsset) {
    // Kill the old asset
    if (cellAssets[cell] != null) {
      cellAssets[cell].scheduleDeath(fadeInTime);
    }
    
    // Add it to our list, and to the world drawing list
    cellAssets[cell] = newAsset;
    lifetimes[cell] = 0;
    drawables.add(newAsset);
  }
  
  // Replace an existing asset with a new one, killing the old one
  void replaceAsset(int cell, PImage bitmap) {    
    Drawable newAsset = new ImageDrawable( bitmap,
                                           getCellLocation(cell),
                                           imageSize,
                                           fadeInTime);
    replaceAsset(cell, newAsset);
  }

  // Replace an existing asset with a new one, killing the old one
  void replaceAsset(int cell, color rectColor) {
    Drawable newAsset = new RectangleDrawable( rectColor,
                                               getCellLocation(cell),
                                               imageSize,
                                               fadeInTime);
    replaceAsset(cell, newAsset);
  }


  void update() {
    for (int cell = 0; cell < cellCount; cell++) {
      lifetimes[cell] += 1;
    }

    if (timeTillNextReplacement > 0) {
      timeTillNextReplacement -= 1;      
    }

    if (timeTillNextReplacement == 0) {
      // Once a cell reaches a certain age, randomly we should replace it

     ArrayList expired = new ArrayList();
      
      // Search for replacable cells
      for (int cell = 0; cell < cellCount; cell++) {
        if (lifetimes[cell] > minLifetime) {
          expired.add((Integer)cell);
        }
      }
      if (expired.size() > 0) {
        
        // If we have fewer than 2/3 images, just load an image
        // Otherwise, swap out an image for a rect, and swap in a new image
        
        // Choose a cell and replace it
        int cellToExpire = (Integer)expired.get(int(random(expired.size())));

        // Replace it with something different than what was there
        // (picture for color and vice versa)
        String objectName = cellAssets[cellToExpire].getClass().getName();
      
        if ((objectName == "Camera_trap_slideshow$RectangleDrawable") && (images.size() > 0)) {
          int newImageIndex = int(random(int(images.size())));
          replaceAsset( cellToExpire, (PImage)images.get(newImageIndex) );
        }
        else {
          int newColorIndex = int(random(int(colors.length)));
          replaceAsset( cellToExpire, colors[newColorIndex] );
        }
            
//        timeTillNextReplacement = fadeInTime;
        timeTillNextReplacement = fadeInTime/2;
      }
    }
  }
  
  void render() {
    noStroke();  
    fill(color(238, 242, 255));
    rect(gridOffset.x, gridOffset.y, gWidth, gHeight);
  }
}


class Drawable {
  PVector loc = new PVector();    // x,y coordinates of top left corner
  PVector extents = new PVector();  // height, width of object  
  boolean dead = false;
  int timeToDie = -1;    // If -1, we are alive.  If > 0, dying.  If 0, dead.
  
  void update() {
    if (timeToDie > 0) {
      timeToDie -= 1;
    }
    if (timeToDie == 0) {
      dead = true;
    }    
  }
  
  void render() {
  }

  // kill the object in n frames
  void scheduleDeath(int timeToDie_) {
    timeToDie = timeToDie_;
  }
    
    
  void kill() {
    dead = true;
  }
  
  boolean isdead() {
    return dead;
  }
}


class RectangleDrawable extends Drawable {
  color rectColor;
  int fadeInTime;
  int fadeInTimeCounter;
  
  RectangleDrawable(color rectColor_, PVector loc_, PVector extents_, int fadeInTime_) {
    rectColor = rectColor_;
    loc = loc_;
    extents = extents_;
    
    fadeInTime = fadeInTime_;
    fadeInTimeCounter = fadeInTime_;
  }
  
  void update() {
    
    if (timeToDie > 0) {
      timeToDie -= 1;
    }
    
    if (timeToDie == 0) {
      dead = true;
    }
  }
  
  void render() {
    // If we are fading in, do that.
    if (fadeInTimeCounter > -1) {
      int fade = int(255.0*(fadeInTime - fadeInTimeCounter)/fadeInTime);
      fadeInTimeCounter -= 1;
      
      fill(rectColor, fade);
      noStroke();
      rect(loc.x, loc.y, extents.x, extents.y);
    }
    else {
//      image(bitmap, loc.x, loc.y, extents.x, extents.y);
    }
  }
}



class ImageDrawable extends Drawable {
  PImage bitmap;  // Image to draw
  int fadeInTime;
  int fadeInTimeCounter;
  
  ImageDrawable(PImage bitmap_, PVector loc_, PVector extents_, int fadeInTime_) {
    bitmap = bitmap_;
    loc = loc_;
    extents = extents_;
    
    fadeInTime = fadeInTime_;
    fadeInTimeCounter = fadeInTime_;
  }
  
  void update() {
    
    if (timeToDie > 0) {
      timeToDie -= 1;
    }
    
    if (timeToDie == 0) {
      dead = true;
    }
  }
  
  void render() {
    // If we are fading in, do that.
    if (fadeInTimeCounter > -1) {
      int fade = int(255.0*(fadeInTime - fadeInTimeCounter)/fadeInTime);
      fadeInTimeCounter -= 1;
      
      tint(255, fade);
      image(bitmap, loc.x, loc.y, extents.x, extents.y);
      tint(255);
    }
    else {
//      image(bitmap, loc.x, loc.y, extents.x, extents.y);
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

