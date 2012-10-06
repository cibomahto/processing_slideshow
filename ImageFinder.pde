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
class ImageFinder extends Thread {

  String m_path;                             // Directory that we should be scanning for new images
  LinkedBlockingQueue<PImage> readyQueue;    // Queue holding the images that are ready to shove out the door
  
  // Init a new Image Finder
  // @param path_ directory scan for images (note: this is relative to the data/ directory of the sketch)
  ImageFinder(String path) {
    m_path = path;
    readyQueue = new LinkedBlockingQueue<PImage>();
  }
  
  public void run() {
    
    // Find anything in the directory that looks like an image, and open it.
    File[] files = listFiles(m_path);
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
      
      // Find anything in the directory that looks like an image, and open it.
      files = listFiles(m_path);
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

  // Preprocess the image, and add it to the ready queue.
  // @param bitmap Image to load
  void addImage(PImage bitmap) {
    PVector imageSize = grid.m_imageSize;
    
    // Center crop the image so that the aspect ratio is correct
    if(abs(float(bitmap.width)/bitmap.height - imageSize.x/imageSize.y) > .005) {
      
      int targetWidth;
      int targetHeight;
      
      if (1.0*bitmap.width/bitmap.height > imageSize.x/imageSize.y) {
        targetWidth = int(bitmap.height/imageSize.y*imageSize.x);
        targetHeight = bitmap.height;
      }
      else {
        targetWidth = bitmap.width;
        targetHeight = int(bitmap.width/imageSize.x*imageSize.y);
      }

      bitmap = bitmap.get((bitmap.width-targetWidth)/2, (bitmap.height-targetHeight)/2, targetWidth, targetHeight);
    }
    
    // Then resize to fit on the screen
    bitmap.resize(int(imageSize.x), int(imageSize.y));
    
    
    // Apply a mask to fade the edge of the bitmap
    PGraphics msk;
    msk = createGraphics(bitmap.width,bitmap.height, P2D);
    msk.beginDraw();
    msk.noStroke();
    msk.background(0);
    drawFuzzyRectangle(0,0,bitmap.width,bitmap.height,
                       grid.m_fadeWidth, color(255,255,255), msk);
    msk.endDraw();
    bitmap.mask(msk);
    
    // Add some sample images
    try{
      readyQueue.put(bitmap);
    } catch( InterruptedException e ) {
      println("Interrupted Exception caught");
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
