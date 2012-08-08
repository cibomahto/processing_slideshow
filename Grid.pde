// Grid asset store, that manages the dispaly of all gridded objects
class Grid {
  int gridColumns;                   // Number of drawable columns in the grid
  int gridRows;                      // Number of drawable rows in the grid

  int gridWidth;                     // Width of the grid, in pixels
  int gridHeight;                    // Height of the grid, in pixels
  
  int cellCount;                     // Number of positions in the grid
  
  ArrayList<Drawable> drawables;     // List of things we are drawing (todo: wtf)
  
  ArrayList<PImage> images;          // Images we could potentially draw
  ArrayList<Integer> colors;           // Rectangle colors we could draw
  Drawable[] cellAssets;             // objects that we are currently displaying
  
  int[] lifetimes;                   // Lifetimes for each object in the grid
  int minLifetime;                   // Minimum number of frames an asset should be displayed before it can be replaced.
  int fadeInTime;                    // Number of frames it takes to fade in an asset
  int timeTillNextReplacement;       // Counter so that we don't replace more than one asset at a time
  
  PVector imageSize;                 // Image size, in pixels
  PVector imageSpacing;              // Amount of space from the origin of one image to the next, inpixels
  int fadeWidth;                     // Width of the image fade, in pixels

  PVector gridOffset;                // Offset of grid from origin, used to center grid in letterboxed scenarios
  
  Grid(int gridColumns_, int gridRows_, float imageAspectRatio_, int minLifetime_, int fadeInTime_, int cellSpacing_, int fadeWidth_) {
    images = new ArrayList<PImage>();
    colors = new ArrayList<Integer>();
    drawables = new ArrayList<Drawable>();
    
    gridColumns = gridColumns_;
    gridRows = gridRows_;
    minLifetime = minLifetime_;
    fadeInTime = fadeInTime_;
    fadeWidth = fadeWidth_;
    
    // First, see if we have to letterbox
    gridWidth = width;
    gridHeight = height;
    
    float targetAspectRatio = imageAspectRatio_*gridColumns/gridRows;
    
    if (abs(gridWidth/gridHeight - targetAspectRatio) > .001) {
      if (targetAspectRatio > gridWidth/gridHeight) {
        gridHeight = int(gridWidth/targetAspectRatio);
      }
      else {
        gridWidth = int(gridHeight*targetAspectRatio);
      }
    }

    // Center the grid 
    gridOffset = new PVector(int((width - gridWidth)/2), int((height - gridHeight)/2));
    
    // Force the image to have integer size, rounding up
    imageSize = new PVector(int((gridWidth - cellSpacing_*(gridColumns - 1))/gridColumns +.5),
                            int((gridHeight - cellSpacing_*(gridRows - 1))/gridRows + .5));

    // Leave the spacing as a float, so it will fill evently
    imageSpacing = new PVector(gridWidth/gridColumns + cellSpacing_/gridColumns,
                               gridHeight/gridRows + cellSpacing_/gridRows);

    cellCount = int(gridColumns * gridRows);
    
    cellAssets =  new Drawable[cellCount];
    lifetimes =  new int[cellCount];

    colors.add(color(128,0,0));

    // pre-fill with colors
    for (int cell = 0; cell < cellCount; cell++) {
      int newColorIndex = int(random(int(colors.size())));
      replaceDrawableWithColor( cell, colors.get(newColorIndex) );
    }

    // and randomize starting lifetimes   
    for (int i = 0; i < cellCount; i++) {
      lifetimes[i] = int(random(minLifetime));
    }
    
    timeTillNextReplacement = 0;
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
  
  // Add a new color to the grid
  void addColor(color color_) {
    colors.add(color_);
  }
  
  // Get a PVector pointing to the location of a cell
  PVector getCellLocation(int cell) {
    int assetX = int(int(cell%gridColumns)*imageSpacing.x + gridOffset.x);
    int assetY = int(int(cell/gridColumns)*imageSpacing.y + gridOffset.y);
 
    return new PVector(assetX, assetY);
  }

  void replaceDrawable(int cell, Drawable newAsset) {
    // Kill the old asset
    if (cellAssets[cell] != null) {
      println("killing asset in cell " + cell + ", type=" + cellAssets[cell].getClass().getName());
      cellAssets[cell].scheduleDeath(fadeInTime);
    }
    
    // Add it to our list, and to the world drawing list
    cellAssets[cell] = newAsset;
    lifetimes[cell] = 0;
    drawables.add(newAsset);
  }
  
  // Replace an existing asset with a new one, killing the old one
  void replaceDrawableWithImage(int cell, PImage bitmap) {    
    Drawable newAsset = new DrawableImage( bitmap,
                                           getCellLocation(cell),
                                           imageSize,
                                           fadeInTime);
    replaceDrawable(cell, newAsset);
  }

  // Replace an existing asset with a new one, killing the old one
  void replaceDrawableWithColor(int cell, color rectColor) {
    Drawable newAsset = new DrawableRectangle( rectColor,
                                               getCellLocation(cell),
                                               imageSize,
                                               fadeInTime,
                                               fadeWidth);
    replaceDrawable(cell, newAsset);
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
        // Choose a cell and replace it
        int cellToExpire = (Integer)expired.get(int(random(expired.size())));

        // Replace it with something different than what was there
        // (picture for color and vice versa)
        String objectName = cellAssets[cellToExpire].getClass().getName();
      
        if ((objectName == "processing_slideshow$DrawableRectangle") && (images.size() > 0)) {
          int newImageIndex = int(random(int(images.size())));
          replaceDrawableWithImage( cellToExpire, images.get(newImageIndex) );
        }
        else {
          int newColorIndex = int(random(int(colors.size())));
          replaceDrawableWithColor( cellToExpire, colors.get(newColorIndex) );
        }

        timeTillNextReplacement = fadeInTime/2;
      }
    }
  }
  
  void draw() {
    noStroke();  
//    fill(color(238, 242, 255));
//    rect(gridOffset.x, gridOffset.y, gridWidth, gridHeight);
  // Fill the background with a gradient
  color edgeColor = color(220);
  color centerColor =  color(255);

  fill(centerColor);
  rect(gridOffset.x, gridOffset.y, gridWidth, gridHeight);
  makeRectangle(gridOffset.x, gridOffset.y, gridWidth/4, gridHeight,  edgeColor, centerColor, centerColor, edgeColor, g);
  makeRectangle(gridOffset.x + gridWidth*3/4, gridOffset.y, gridWidth/4, gridHeight,  centerColor, edgeColor, edgeColor, centerColor, g);
    
    // Handle all of the drawables
    for (int i = 0; i < drawables.size(); i++) {
      drawables.get(i).update();
      drawables.get(i).draw();
    }
    
    // Remove dead drawables
    for (int i = drawables.size() - 1; i >= 0; i-- ) {
      if(drawables.get(i).isdead() ) {
        drawables.remove(i);
      }
    }
  }
}
