// Grid asset store, that manages the dispaly of all gridded objects
class Grid {
  int m_gridColumns;                   // Number of drawable columns in the grid
  int m_gridRows;                      // Number of drawable rows in the grid

  int m_gridWidth;                     // Width of the grid, in pixels
  int m_gridHeight;                    // Height of the grid, in pixels
  
  int m_cellCount;                     // Number of positions in the grid
  
  ArrayList<Drawable> m_drawables;     // List of things we are drawing (todo: wtf)
  
  ArrayList<PImage> m_images;          // Images we could potentially draw
  ArrayList<Integer> m_colors;         // Rectangle colors we could draw
  Drawable[] m_cellAssets;             // objects that we are currently displaying
  
  int[] m_lifetimes;                   // Lifetimes for each object in the grid
  int m_minLifetime;                   // Minimum number of frames an asset should be displayed before it can be replaced.
  int m_fadeInTime;                    // Number of frames it takes to fade in an asset
  int m_timeTillNextReplacement;       // Counter so that we don't replace more than one asset at a time
  
  PVector m_imageSize;                 // Image size, in pixels
  PVector m_imageSpacing;              // Amount of space from the origin of one image to the next, inpixels
  int m_fadeWidth;                     // Width of the image fade, in pixels

  PVector m_gridOffset;                // Offset of grid from origin, used to center grid in letterboxed scenarios
  
  Grid(int gridColumns, int gridRows, float imageAspectRatio_, int minLifetime, int fadeInTime, int cellSpacing, int fadeWidth) {
    m_images = new ArrayList<PImage>();
    m_colors = new ArrayList<Integer>();
    m_drawables = new ArrayList<Drawable>();
    
    m_gridColumns = gridColumns;
    m_gridRows = gridRows;
    m_minLifetime = minLifetime;
    m_fadeInTime = fadeInTime;
    m_fadeWidth = fadeWidth;
    
    // First, see if we have to letterbox
    m_gridWidth = width;
    m_gridHeight = height;
    
    float targetAspectRatio = imageAspectRatio_*m_gridColumns/m_gridRows;
    
    if (abs(m_gridWidth/m_gridHeight - targetAspectRatio) > .001) {
      if (targetAspectRatio > m_gridWidth/m_gridHeight) {
        m_gridHeight = int(m_gridWidth/targetAspectRatio);
      }
      else {
        m_gridWidth = int(m_gridHeight*targetAspectRatio);
      }
    }

    // Center the grid 
    m_gridOffset = new PVector(int((width - m_gridWidth)/2), int((height - m_gridHeight)/2));
    
    // Force the image to have integer size, rounding up
    m_imageSize = new PVector(int((m_gridWidth - cellSpacing*(m_gridColumns - 1))/m_gridColumns +.5),
                            int((m_gridHeight - cellSpacing*(m_gridRows - 1))/m_gridRows + .5));

    // Leave the spacing as a float, so it will fill evently
    m_imageSpacing = new PVector(m_gridWidth/m_gridColumns + cellSpacing/m_gridColumns,
                               m_gridHeight/m_gridRows + cellSpacing/m_gridRows);

    m_cellCount = int(m_gridColumns * m_gridRows);
    
    m_cellAssets =  new Drawable[m_cellCount];
    m_lifetimes =  new int[m_cellCount];

    m_colors.add(color(128,0,0));

    // pre-fill with colors
    for (int cell = 0; cell < m_cellCount; cell++) {
      int newColorIndex = int(random(int(m_colors.size())));
      replaceDrawableWithColor( cell, m_colors.get(newColorIndex) );
    }

    // and randomize starting lifetimes   
    for (int i = 0; i < m_cellCount; i++) {
      m_lifetimes[i] = int(random(m_minLifetime));
    }
    
    m_timeTillNextReplacement = 0;
  }

  // Add a new image to the grid
  void addImage(PImage bitmap) {
    m_images.add(bitmap);
      
    // TODO: remove some images if we have a lot of them (?)
  }
  
  // Add a new color to the grid
  void addColor(color color_) {
    m_colors.add(color_);
  }
  
  // Get a PVector pointing to the location of a cell
  PVector getCellLocation(int cell) {
    int assetX = int(int(cell%m_gridColumns)*m_imageSpacing.x + m_gridOffset.x);
    int assetY = int(int(cell/m_gridColumns)*m_imageSpacing.y + m_gridOffset.y);
 
    return new PVector(assetX, assetY);
  }

  void replaceDrawable(int cell, Drawable newAsset) {
    // Kill the old asset
    if (m_cellAssets[cell] != null) {
      println("killing asset in cell " + cell + ", type=" + m_cellAssets[cell].getClass().getName());
      m_cellAssets[cell].scheduleDeath(m_fadeInTime);
    }
    
    // Add it to our list, and to the world drawing list
    m_cellAssets[cell] = newAsset;
    m_lifetimes[cell] = 0;
    m_drawables.add(newAsset);
  }
  
  // Replace an existing asset with a new one, killing the old one
  void replaceDrawableWithImage(int cell, PImage bitmap) {    
    Drawable newAsset = new DrawableImage( bitmap,
                                           getCellLocation(cell),
                                           m_imageSize,
                                           m_fadeInTime);
    replaceDrawable(cell, newAsset);
  }

  // Replace an existing asset with a new one, killing the old one
  void replaceDrawableWithColor(int cell, color rectColor) {
    Drawable newAsset = new DrawableRectangle( rectColor,
                                               getCellLocation(cell),
                                               m_imageSize,
                                               m_fadeInTime,
                                               m_fadeWidth);
    replaceDrawable(cell, newAsset);
  }


  void update() {
    for (int cell = 0; cell < m_cellCount; cell++) {
      m_lifetimes[cell] += 1;
    }

    if (m_timeTillNextReplacement > 0) {
      m_timeTillNextReplacement -= 1;      
    }

    if (m_timeTillNextReplacement == 0) {
      // Once a cell reaches a certain age, randomly we should replace it
      ArrayList expired = new ArrayList();
      
      // Search for replacable cells
      for (int cell = 0; cell < m_cellCount; cell++) {
        if (m_lifetimes[cell] > m_minLifetime) {
          expired.add((Integer)cell);
        }
      }
      if (expired.size() > 0) {
        // Choose a cell and replace it
        int cellToExpire = (Integer)expired.get(int(random(expired.size())));

        // Replace it with something different than what was there
        // (picture for color and vice versa)
        String objectName = m_cellAssets[cellToExpire].getClass().getName();
      
        if ((objectName == "processing_slideshow$DrawableRectangle") && (m_images.size() > 0)) {
          int newImageIndex = int(random(int(m_images.size())));
          replaceDrawableWithImage( cellToExpire, m_images.get(newImageIndex) );
        }
        else {
          int newColorIndex = int(random(int(m_colors.size())));
          replaceDrawableWithColor( cellToExpire, m_colors.get(newColorIndex) );
        }

        m_timeTillNextReplacement = m_fadeInTime/2;
      }
    }
  }
  
  void draw() {
    noStroke();  
//    fill(color(238, 242, 255));
//    rect(m_gridOffset.x, m_gridOffset.y, m_gridWidth, m_gridHeight);
  // Fill the background with a gradient
  color edgeColor = color(220);
  color centerColor =  color(255);

  fill(centerColor);
  rect(m_gridOffset.x, m_gridOffset.y, m_gridWidth, m_gridHeight);
  makeRectangle(m_gridOffset.x, m_gridOffset.y, m_gridWidth/4, m_gridHeight,  edgeColor, centerColor, centerColor, edgeColor, g);
  makeRectangle(m_gridOffset.x + m_gridWidth*3/4, m_gridOffset.y, m_gridWidth/4, m_gridHeight,  centerColor, edgeColor, edgeColor, centerColor, g);
    
    // Handle all of the drawables
    for (int i = 0; i < m_drawables.size(); i++) {
      m_drawables.get(i).update();
      m_drawables.get(i).draw();
    }
    
    // Remove dead drawables
    for (int i = m_drawables.size() - 1; i >= 0; i-- ) {
      if(m_drawables.get(i).isdead() ) {
        m_drawables.remove(i);
      }
    }
  }
}
