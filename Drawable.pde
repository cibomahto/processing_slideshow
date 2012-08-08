class Drawable {
  
  boolean m_dead = false;                    // 
  int m_timeToDie = -1;                      // If -1, we are alive.  If > 0, dying.  If 0, dead.
  
  void update() {
    if (m_timeToDie > 0) {
      m_timeToDie -= 1;
    }
    
    if (m_timeToDie == 0) {
      m_dead = true;
    }
  }
  
  void draw() {
  }

  // kill the object in n frames
  void scheduleDeath(int timeToDie) {
    m_timeToDie = timeToDie;
  }

  void kill() {
    m_dead = true;
  }
  
  boolean isdead() {
    return m_dead;
  }
}
