// Grid asset store, that manages the dispaly of all gridded objects
class Grid {
  int m_gridColumns;                   // Number of drawable columns in the grid
  int m_gridRows;                      // Number of drawable rows in the grid

  ArrayList<Drawable> m_drawables;     // List of things we are drawing (todo: wtf)
  
  ArrayList<PImage> m_images;          // Images we could potentially draw
  int m_imageIndex;                    // Index of the next image to draw
  
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
  
  
  Grid(int gridColumns, int gridRows, float imageAspectRatio_, int minLifetime, int fadeInTime, int cellSpacing, int fadeWidth, color colors[]) {
    m_images = new ArrayList<PImage>();
    m_colors = new ArrayList<Integer>();
    m_drawables = new ArrayList<Drawable>();
    m_imageIndex = 0;
    
    m_gridColumns = gridColumns;
    m_gridRows = gridRows;
    m_minLifetime = minLifetime;
    m_fadeInTime = fadeInTime;
    m_fadeWidth = fadeWidth;
    
    // First, see if we have to letterbox
    int gridWidth = width;
    int gridHeight = height;
    
    float targetAspectRatio = imageAspectRatio_*m_gridColumns/m_gridRows;
    
    if (abs((float)gridWidth/gridHeight - targetAspectRatio) > .001) {
      if (targetAspectRatio > (float)gridWidth/gridHeight) {
        gridHeight = int((float)gridWidth/targetAspectRatio);
      }
      else {
        gridWidth = int((float)gridHeight*targetAspectRatio);
      }
    }

    // Center the grid 
    m_gridOffset = new PVector(int((width - gridWidth)/2), int((height - gridHeight)/2));
    
    // Force the image to have integer size, rounding up
    m_imageSize = new PVector(int((gridWidth - cellSpacing*(m_gridColumns - 1))/m_gridColumns +.5),
                            int((gridHeight - cellSpacing*(m_gridRows - 1))/m_gridRows + .5));

    // Leave the spacing as a float, so it will fill evently
    m_imageSpacing = new PVector(gridWidth/m_gridColumns + cellSpacing/m_gridColumns,
                               gridHeight/m_gridRows + cellSpacing/m_gridRows);
    
    m_cellAssets =  new Drawable[m_gridColumns*m_gridRows];
    m_lifetimes =  new int[m_gridColumns*m_gridRows];

    // Add colors to the grid
    for(int i = 0; i < colors.length; i++) {
      m_colors.add(colors[i]);
    }
  

    // pre-fill with colors
    for (int cell = 0; cell < m_gridColumns*m_gridRows; cell++) {
      int newColorIndex = int(random(int(m_colors.size())));
      replaceDrawableWithColor( cell, m_colors.get(newColorIndex) );
    }

    // and randomize starting lifetimes   
    for (int i = 0; i < m_gridColumns*m_gridRows; i++) {
      m_lifetimes[i] = int(random(m_minLifetime));
    }
    
    m_timeTillNextReplacement = 0;
  }

  // Add a new image to the grid, set to display as the next image
  void addImage(PImage bitmap) {
    m_images.add(m_imageIndex, bitmap);
      
    // TODO: remove some images if we have a lot of them (?)
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
    for (int cell = 0; cell < m_gridColumns*m_gridRows; cell++) {
      m_lifetimes[cell] += 1;
    }

    if (m_timeTillNextReplacement > 0) {
      m_timeTillNextReplacement -= 1;      
    }

    if (m_timeTillNextReplacement == 0) {
      // Once a cell reaches a certain age, randomly we should replace it
      ArrayList expired = new ArrayList();
      
      // Search for replacable cells
      for (int cell = 0; cell < m_gridColumns*m_gridRows; cell++) {
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

        if (m_images.size() > 0) {
          int newImageIndex = m_imageIndex;
          replaceDrawableWithImage( cellToExpire, m_images.get(newImageIndex) );
          
          // Increment the image index, and randomize the array if we're at the end.
          m_imageIndex += 1;
          if (m_imageIndex == m_images.size()) {
            m_imageIndex = 0;
            Collections.shuffle(m_images);
          }
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

    // Handle all of the drawables
    for (int i = 0; i < m_drawables.size(); i++) {
      m_drawables.get(i).update();
      
      pushMatrix();
//      translate(screen.width/2, screen.height/2);
//      rotateZ(PI/2/10);
//      translate(-screen.width/2, -screen.height/2);
      m_drawables.get(i).draw();
      popMatrix();
    }
    
    // Remove dead drawables
    for (int i = m_drawables.size() - 1; i >= 0; i-- ) {
      if(m_drawables.get(i).isdead() ) {
        m_drawables.remove(i);
      }
    }
  }
}
