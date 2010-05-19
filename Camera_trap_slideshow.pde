/**
 * Simple grid-based screensaver thingy
 * looks for new photos and displays them
 */

int cols = 5;
int rows = 5;

int cellSpacing = 6;

int screenWidth = 900;
int screenHeight = 600;

int transitionSpeed = 20;
int assetLifetime = 100;

// List of things we are drawing
ArrayList drawables;

Grid grid;

// 238, 242, 255

void setup() {
  size(screenWidth, screenHeight);
  
  drawables = new ArrayList();

  grid = new Grid(new PVector(cols, rows), assetLifetime, transitionSpeed, cellSpacing);
  
  // make a demo image
//  drawables.add( new ImageDrawable( loadImage("jelly.jpg"),
//                                    new PVector(0,0),
//                                    new PVector(width/cols, width/rows)) );

   fill(color(238, 242, 255));
   rect(0,0,width,height);
}


void draw() {  
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
      println("removing dead drawable: " + i);
      drawables.remove(i);
    }
  }
}


// Grid asset store, that manages the dispaly of all gridded objects
class Grid {
  PVector gridSize;  // rows and colums to make the grid

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
  
  // Minimum number of frames an asset should be displayed before it is replaced.
  int minLifetime;
  
  // Number of frames it takes to fade in an asset
  int fadeInTime;
  
  // Counter so that we don't replace more than one asset at a time
  int timeTillNextReplacement = 0;

  // Image size and location
  PVector imageSize;
  PVector imageSpacing;
  
  // Border between cells
  int cellSpacing;
  
  Grid(PVector gridSize_, int minLifetime_, int fadeInTime_, int cellSpacing_) {
    images = new ArrayList();
    
    gridSize = gridSize_;
    minLifetime = minLifetime_;
    fadeInTime = fadeInTime_;

    cellSpacing = cellSpacing_;

    // Precompute the image sizes
    imageSize = new PVector((width - cellSpacing*(gridSize.x - 1))/gridSize.x,
                            (height - cellSpacing*(gridSize.y - 1))/gridSize.y);

    imageSpacing = new PVector(width/gridSize.x + int(cellSpacing/gridSize.x),
                               height/gridSize.y + int(cellSpacing/gridSize.y));

    
    cellCount = int(gridSize.x * gridSize.y);
    
    cellAssets =  new Drawable[cellCount];
    lifetimes =  new int[cellCount];
    
    colors = new color[7];
    // Add some MAKE-friendly colors
    colors[0] = color(156, 185, 95);
    colors[1] = color(235, 169, 85);
    colors[2] = color(238, 78, 77);
    colors[3] = color(29, 90, 136);
    colors[4] = color(47, 178, 189);
    colors[5] = color(208, 105, 85);
    colors[6] = color(200, 176, 77);
    
    
    // and add a sample image so we don't choke
    images.add(loadImage("DSC_5080.JPG"));
    images.add(loadImage("DSC_5092.JPG"));
    images.add(loadImage("DSC_5094.JPG"));
    images.add(loadImage("DSC_5098.JPG"));
    images.add(loadImage("DSC_5101.JPG"));
    images.add(loadImage("DSC_5104.JPG"));
    images.add(loadImage("DSC_5105.JPG"));
    images.add(loadImage("DSC_5109.JPG"));
    images.add(loadImage("DSC_5119.JPG"));
    images.add(loadImage("DSC_5124.JPG"));
    images.add(loadImage("DSC_5128.JPG"));
    images.add(loadImage("DSC_5134.JPG"));

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

  // Add a new image to the grid
  void addImage(PImage image_) {
    images.add(image_);
    
    // Find the oldest object in the grid, and replace it
    
    // TODO: remove some images if we have a lot of them
  }

  // Replace an existing asset with a new one, killing the old one
  void replaceAsset(int cell, PImage bitmap) {
    // Kill the old asset
    if (cellAssets[cell] != null) {
      cellAssets[cell].scheduleDeath(fadeInTime);
    }
    
    int assetX = int(int(cell%gridSize.x)*imageSpacing.x);
    int assetY = int(int(cell/gridSize.y)*imageSpacing.y);

    // Create the new image

    Drawable newAsset = new ImageDrawable( bitmap,
                                           new PVector(assetX, assetY),
                                           imageSize,
                                           fadeInTime);

    // Add it to our list, and to the world drawing list
    cellAssets[cell] = newAsset;
    lifetimes[cell] = 0;
    drawables.add(newAsset);
  }

  // Replace an existing asset with a new one, killing the old one
  void replaceAsset(int cell, color rectColor) {
    // Kill the old asset
    if (cellAssets[cell] != null) {
      cellAssets[cell].scheduleDeath(fadeInTime);
    }
    
    int assetX = int(int(cell%gridSize.x)*imageSpacing.x);
    int assetY = int(int(cell/gridSize.y)*imageSpacing.y);
    
    // Create the new image

    Drawable newAsset = new RectangleDrawable( rectColor,
                                               new PVector(assetX, assetY),
                                               imageSize,
                                               fadeInTime);
    
    // Add it to our list, and to the world drawing list
    cellAssets[cell] = newAsset;
    lifetimes[cell] = 0;
    drawables.add(newAsset);
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
      for (int cell = 0; cell < cellCount; cell++) {
        if ( lifetimes[cell] > minLifetime) {
          if (random(100) > 99) {
            // grab a random image from the pool
            // TODO: use things besides images

            // Replace it with some kind of asset
            int type = int(random(100));
            if (type < 30) {
              int newColorIndex = int(random(int(colors.length)));
              replaceAsset( cell, colors[newColorIndex] );
            }
            else {
              int newImageIndex = int(random(int(images.size())));
              replaceAsset( cell, (PImage)images.get(newImageIndex) );
            }
            
            timeTillNextReplacement = fadeInTime * 2;
          }
        }
      }
    }
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

