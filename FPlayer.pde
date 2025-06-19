class FPlayer extends FBox {
  private final int jumpStrength = 1150;
  private int xPos;
  
  public FPlayer(int x, int y, float w, float h, PImage playerImg) {
    super(w, h);
    this.xPos = x;
    
    this.setPosition(x, y);
    this.attachImage(playerImg);
    this.setName("player");
  }
  
  public void update() {
    handlePlayerMovement();
  }
  
  private void handlePlayerMovement() {
    this.setPosition(xPos, this.getY());
    if(spaceKeyDown && isGrounded()) {
      jump();
    }
  }
  
  public void jump() {
    this.setVelocity(0, isGravityFlipped ? jumpStrength : -jumpStrength);
    this.setAngularVelocity(isGravityFlipped ? -PI : PI);
  }
  
  public boolean isGrounded() {
    if(this.getContacts().size() == 0) {
      return false;
    } else if(contactsContainsPortal()) {
      return false;
    } else {
      return true;
    }
  }
  private boolean contactsContainsPortal() {
    for(Object c : this.getContacts()) {
      if(((FContact) c).contains("portal")) return true;
    }
    return false;
  }
}
