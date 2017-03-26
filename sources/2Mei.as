/**
 * Create a Flash app using Union Platform,
 * where you can collaborate with more than 4 people online.
 *
 * UnionRamen is an example app,
 * you can write code based on this, or build from scratch.
 *
 * UnionRamen is a multiuser bowl of ramen built on the Union Platform.
 * Press the 'n' key to add naruto to the bowl.
 * For Union Platform documentation, see www.unionplatform.com.
 * 
 * @author   Colin Moock
 * @date     July 2009
 * @location Toronto, Canada
 */

package {
  import flash.display.Sprite;
  import flash.events.KeyboardEvent;
  import flash.ui.Keyboard;
  import net.user1.reactor.*;
  import net.user1.logger.Logger;
  
  // The main application class
  public class UnionRamen extends Sprite {
    // Union objects
    protected var reactor:Reactor;
    protected var ramenRoom:Room;
    // Visual objects
    protected var ramenBowl:Sprite;
    
    // Constructor
    public function UnionRamen () {
      // Create the visuals
      buildUI();
      // Make the UConnection object
      reactor = new Reactor();
      // Run readyListener() when the connection is ready
      reactor.addEventListener(ReactorEvent.READY, 
                               readyListener);
      // Connect to Union
      reactor.connect("tryunion.com", 9100);
      reactor.getLog().setLevel(Logger.DEBUG);
    }
    
    // Method invoked when the connection is ready
    protected function readyListener (e:ReactorEvent):void {
      // Create the application room
      // use a unique identifier for your app
      ramenRoom = reactor.getRoomManager().createRoom(
                                   "wonderfl.ramenRoom");
      // Listen for the ADD_NARUTO message from other users
      ramenRoom.addMessageListener("ADD_NARUTO", 
                                   addNarutoListener);
      // Join the application room
      ramenRoom.join();
    }
    
    // Creates the user interface
    protected function buildUI ():void {
      // Listen for key presses
      stage.addEventListener(KeyboardEvent.KEY_UP, 
                                        keyUpListener);
      // Create the ramen bowl graphic
      ramenBowl = new Sprite();
      ramenBowl.graphics.beginFill(0xCCCC99);
      ramenBowl.graphics.drawCircle(150, 150, 150);
      addChild(ramenBowl);
    }
    
    // Keyboard listener for outgoingMessages
    protected function keyUpListener (e:KeyboardEvent):void {
      // If the connection isn't ready, don't process
      // key presses
      if (!reactor.isReady()) {
        return;
      }
      
      // If the 'n' key was pressed...
      if (e.keyCode == 78) {
        // ...add naruto to the bowl
        ramenRoom.sendMessage("ADD_NARUTO", 
                             true, 
                             null);
      }
    }
    
    // Method invoked when an ADD_NARUTO message 
    // is received from another user
    protected function addNarutoListener (fromClient:IClient):void {
      // If there are more than 15 pieces of naruto in the
      // bowl already, remove the oldest one before adding
      // the new one
      if (ramenBowl.numChildren > 15) {
        ramenBowl.removeChildAt(0);
      }

      // Add a new piece of Naruto to the bowl
      var naruto:Naruto = new Naruto();
      naruto.x = 40 + Math.floor(Math.random()*150);
      naruto.y = 40 + Math.floor(Math.random()*150);
      ramenBowl.addChild(naruto);
    }
  }
}

import flash.display.Sprite;
class Naruto extends Sprite {
  public function Naruto () {
    draw();
  }

  protected function draw ():void {
    graphics.beginFill(0xFFFFFF);
    graphics.drawCircle(40, 40, 20);
    graphics.beginFill(0xFF5599);
    graphics.drawCircle(40, 40, 7);
  }
}





