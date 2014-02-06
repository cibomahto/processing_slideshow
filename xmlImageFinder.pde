import java.util.Map;
import java.util.Iterator;

// Image finder load all available images, then periodically searches for new ones.
// It then passes them to the grid for display.
class XmlImageFinder extends Thread {

  String m_updateURL;                          // URL to hit for new images
  String m_historyFile;                        // URL to store history (must be writable)
  LinkedBlockingQueue<PImage> m_readyQueue;    // Queue holding the images that are ready to shove out the door
  
  
  // Init a new Image Finder
  // @param path_ directory scan for images (note: this is relative to the data/ directory of the sketch)
  XmlImageFinder(String updateURL, String historyFile) {
    m_updateURL = updateURL;
    m_historyFile = historyFile;
    
    m_readyQueue = new LinkedBlockingQueue<PImage>();
  }
  
  public void run() {
    Map<Integer, String> currentImages = readImageList(m_historyFile);
    Iterator it = currentImages.entrySet().iterator();
    while (it.hasNext()) {
      Map.Entry pairs = (Map.Entry)it.next();
      addImage((String)pairs.getValue());
    }
    
    while(true) {
      // Poll for new images, and add them to the queue.
      Map<Integer, String> newImages = updateImageList(m_historyFile, m_updateURL);
      it = newImages.entrySet().iterator();
      while (it.hasNext()) {
        Map.Entry pairs = (Map.Entry)it.next();
        println("Found new image! " + pairs.getValue());
        addImage((String)pairs.getValue());
      }
      
      try{ 
        Thread.sleep(2000); // sleep for 2 seconds
      } catch( InterruptedException e ) {
        println("Interrupted Exception caught");
      }
      
    }
  }

  // Preprocess the image, and add it to the ready queue.
  // @param bitmap Image to load
  void addImage(String imageURL) {
    // TODO: Attempt to cache the image locally, or use the cache if it already exists.
    
    PImage bitmap = loadImage(imageURL);
    if (bitmap == null) {
      println("Bad image from " + imageURL + ", skipping.");
      return;
    }
    println("Adding image from " + imageURL);
    
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
    msk = createGraphics(bitmap.width,bitmap.height);
    msk.beginDraw();
    msk.noStroke();
    msk.background(0);
    drawFuzzyRectangle(0,0,bitmap.width,bitmap.height,
                       grid.m_fadeWidth, color(255,255,255), msk);
    msk.endDraw();
    bitmap.mask(msk);
    
    // Add some sample images
    try{
      m_readyQueue.put(bitmap);
    } catch( InterruptedException e ) {
      println("Interrupted Exception caught");
    }
  }
  
  
  // Test if a new image is available
  // @return True if an image is available, otherwise false.
  public boolean imageAvailable() {
    return (m_readyQueue.size() > 0);
  }
  
  // Get an image from the queue. Potentially blocks if none are available.
  // @return Pimage containing the image.
  public PImage getNextImage() {
    return m_readyQueue.poll(); 
  }
}
