// Image finder load all available images, then periodically searches for new ones.
// It then passes them to the grid for display.
class ImageFinder implements Runnable {

  String path;          // Directory that we should be scanning for new images
  Date lastChecked;    // Last time we scanned the directory

  // Queue holding the enemies that are ready to shove out the door
  private LinkedBlockingQueue readyQueue;
  
  ImageFinder(String path_) {
    path = path_;
    
    readyQueue = new LinkedBlockingQueue();
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
