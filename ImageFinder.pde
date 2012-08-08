// Some helper functions and a class to continuously scan a directory for new images, load them,
// then scale to an appropriate resolution and pass them to a display consumer.

// File functions are from:
// http://processing.org/learning/topics/directorylist.html


// Get a list of all files located in a directory
// @param dir Directory to search (relative to the data/ directory)
// @return Array of files in the directory
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

// Image finder load all available images, then periodically searches for new ones.
// It then passes them to the grid for display.
class ImageFinder implements Runnable {

  String path;                             // Directory that we should be scanning for new images
  LinkedBlockingQueue<PImage> readyQueue;  // Queue holding the images that are ready to shove out the door
  
  // Init a new Image Finder
  // @param path_ directory scan for images (note: this is relative to the data/ directory of the sketch)
  ImageFinder(String path_) {
    path = path_;
    readyQueue = new LinkedBlockingQueue<PImage>();
  }


  // Preprocess the image, and add it to the ready queue.
  // @param bitmap Image to load
  void addImage(PImage bitmap) {
    PVector imageSize = grid.getImageSize();
    
    // TODO: Crop to match the aspect ratio...
    
    // Resize the image
    bitmap.resize(int(imageSize.x), int(imageSize.y));
    
    // Apply a mask to fade the edge of the bitmap
    PGraphics msk;
    msk = createGraphics(bitmap.width,bitmap.height, P2D);

    msk.beginDraw();
    msk.noStroke();
    msk.background(0);
    drawFuzzyRectangle(0,0,bitmap.width,bitmap.height,
                       grid.fadeWidth, color(255,255,255), msk);
    msk.endDraw();
    bitmap.mask(msk);
//    bitmap.blend(msk, 0,0,bitmap.width, bitmap.height, 0,0,bitmap.width,bitmap.height,MULTIPLY);

    
    // Add some sample images
    try{ 
      readyQueue.put(bitmap);
    } catch( InterruptedException e ) {
      println("Interrupted Exception caught");
    }
  }
  
  
  public void run() {
    
    // Find anything in the directory that looks like an image, and open it.
    File[] files = listFiles(path);
    for (int i = 0; i < files.length; i++) {
      String fileName = files[i].getName();

      if (fileName.toLowerCase().endsWith(".jpg")) {
        addImage(loadImage(fileName));
      }
    }
    
    Date lastChecked = new Date();
    
    while(true) {
      // We should be polling for new images here, and adding them
      
      try{ 
        Thread.sleep(10000); // sleep for 10 seconds
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
        
        if (lastChecked.before(new Date(f.lastModified()))) {
          if (fileName.toLowerCase().endsWith(".jpg")) {
            addImage(loadImage(fileName));
          }
        }
      }
      
      lastChecked = newLastChecked;
    }
  }
  
  // Test if a new image is available
  // @return True if an image is available, otherwise false.
  public boolean imageAvailable() {
    return (readyQueue.size() > 0);
  }
  
  // Get an image from the queue. Potentially blocks if none are available.
  // @return Pimage containing the image.
  public PImage getNextImage() {
    return readyQueue.poll(); 
  }
}
