class FPlayer extends FBox {
  private final int jumpStrength = 1150;
  private final int jumpPadJumpStrength = 1800;
  private int xPos;
  private int lastJumpTime;
  
  public FPlayer(int x, int y, float w, float h, PImage playerImg) {
    super(w, h);
    this.xPos = x;
    this.lastJumpTime = 0;
    
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
    if(millis() - lastJumpTime > 300) {
      this.setVelocity(0, isGravityFlipped ? jumpStrength : -jumpStrength);
      this.setAngularVelocity(isGravityFlipped ? -PI : PI);
      lastJumpTime = millis();
    }
  }
  public void jumpPadJump() {
    this.setVelocity(0, isGravityFlipped ? jumpPadJumpStrength : -jumpPadJumpStrength);
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
