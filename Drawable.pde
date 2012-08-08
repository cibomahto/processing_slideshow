class Drawable {
  
  boolean dead = false;                    // 
  int timeToDie = -1;                      // If -1, we are alive.  If > 0, dying.  If 0, dead.
  
  void update() {
    if (timeToDie > 0) {
      timeToDie -= 1;
    }
    
    if (timeToDie == 0) {
      dead = true;
    }
  }
  
  void draw() {
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
