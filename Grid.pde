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
  
  Grid(int gridColumns_, int gridRows_, float imageAspectRatio_, int minLifetime_, int fadeInTime_, int cellSpacing_) {
    images = new ArrayList();
    
    imageAspectRatio = imageAspectRatio_;
    
    gridSize = new PVector(gridColumns_, gridRows_);
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
    Drawable newAsset = new DrawableImage( bitmap,
                                           getCellLocation(cell),
                                           imageSize,
                                           fadeInTime);
    replaceAsset(cell, newAsset);
  }

  // Replace an existing asset with a new one, killing the old one
  void replaceAsset(int cell, color rectColor) {
    Drawable newAsset = new DrawableRectangle( rectColor,
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
      
        if ((objectName == "processing_slideshow$RectangleDrawable") && (images.size() > 0)) {
          int newImageIndex = int(random(int(images.size())));
          replaceAsset( cellToExpire, (PImage)images.get(newImageIndex) );
        }
        else {
          int newColorIndex = int(random(int(colors.length)));
          replaceAsset( cellToExpire, colors[newColorIndex] );
        }
            
        timeTillNextReplacement = fadeInTime;
        timeTillNextReplacement = fadeInTime/2;
      }
    }
  }
  
  void draw() {
    noStroke();  
    fill(color(238, 242, 255));
    rect(gridOffset.x, gridOffset.y, gWidth, gHeight);
  }
}
