//
//  GameScene.swift
//  Project14
//
//  Created by Mehmet Sadıç on 04/04/2017.
//  Copyright © 2017 Mehmet Sadıç. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
  
  // Collect all the instances of WhackSlot class in an array
  var slots = [WhackSlot]()
  
  // Shows the users current score
  var scoreLabel: SKLabelNode!
  
  var score: Int = 0 {
    didSet {
      scoreLabel.text = "Score: \(score)"
    }
  }
  
  // Shows how fast penguins appear
  var popUpTime = 0.85
  
  // Number of times penguins appear
  var numRound = 0
  
  /* Called when the app is first loaded */
  override func didMove(to view: SKView) {
    
    // Add a background image
    let background = SKSpriteNode(imageNamed: "whackBackground")
    background.zPosition = -1
    background.position = CGPoint(x: 512, y: 384)
    background.blendMode = .replace
    addChild(background)
    
    // Add a score label
    scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
    scoreLabel.text = "Score: 0"
    scoreLabel.position = CGPoint(x: 8, y: 8)
    scoreLabel.horizontalAlignmentMode = .left
    scoreLabel.fontSize = 20
    addChild(scoreLabel)
    
    // Add 4 rows of holes counting 18 in total (5-4-5-4)
    for i in 0..<5 { makeHole(at: CGPoint(x: 100 + 170*i, y: 410)) }
    for i in 0..<4 { makeHole(at: CGPoint(x: 180 + 170*i, y: 320)) }
    for i in 0..<5 { makeHole(at: CGPoint(x: 100 + 170*i, y: 230)) }
    for i in 0..<4 { makeHole(at: CGPoint(x: 180 + 170*i, y: 140)) }
    
    // Show the enemy penguin together with friend penguin
    // asyncAfter method is used to start showing penguins 1 second after game starts
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
      self.createEnemy()
    }
  }
  
  /* This function is called whenever the the screen is tapped. */
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    
    // Find the first touch and its location
    if let touch = touches.first {
      
      let location = touch.location(in: self)
      
      // Find the nodes at touched location
      let nodesTapped = nodes(at: location)
      
      // Count through nodes and call hit() method for each node
      for node in nodesTapped {
        
        if let whackSlot = node.parent?.parent as? WhackSlot {
          // It shouldn't be hit
          if whackSlot.isHit { continue }
          
          // It shouldn't be hidden
          if !whackSlot.isVisible { continue }
          
          if node.name == "charFriend" {
            // This is a good penguin. We shouldn't have whacked it
            
            // Hit the penguin
            whackSlot.hit()
            
            // Decrement score by 5 points
            score -= 5
            
            // Play wrong hit sound
            run(SKAction.playSoundFileNamed("whackBad.caf", waitForCompletion: false))
            
          } else if node.name == "charEvil" {
            // This is a bad penguin. We should have whacked it
            
            // Hit the penguin
            whackSlot.hit()
            
            // Increment score
            score += 1
            
            // Play correct hit sound
            run(SKAction.playSoundFileNamed("whack", waitForCompletion: false))
            
          }
        }
      }
    }
    
  }
  
  /* Make a hole at a given position */
  private func makeHole(at point: CGPoint) {
    
    // Create an instance of WhackSlot class
    let whackSlot = WhackSlot()
    
    // Call the configure() function to create a hole
    whackSlot.configure(at: point)
    
    // Add the node to view so that it is seen
    addChild(whackSlot)
    
    // Add the node to the slots array
    slots.append(whackSlot)
  }
  
  /* Show good and evil penguins in random basis */
  private func createEnemy() {
    
    numRound += 1
    if numRound >= 20 {
      // call game over
      gameOver()
      // leave the function
      
      return
    }
    
    // popUpTime gets smaller after each iteration
    popUpTime *= 0.991
    
    slots = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: slots) as! [WhackSlot]
    slots[0].show(hideTime: popUpTime)
    
    let randomDouble = RandomDouble(min: 0, max: 12)
    if randomDouble > 4 { slots[1].show(hideTime: popUpTime) }
    if randomDouble > 8 { slots[2].show(hideTime: popUpTime) }
    if randomDouble > 10 { slots[3].show(hideTime: popUpTime) }
    if randomDouble > 11 { slots[4].show(hideTime: popUpTime) }
    
    let minDelay = popUpTime / 2.0
    let maxDealy = popUpTime * 2.0
    let delay = RandomDouble(min: minDelay, max: maxDealy)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [unowned self] in
      self.createEnemy()
    }
  }
  
  /* Call this function to finish the game */
  private func gameOver() {
    let gameOver = SKSpriteNode(imageNamed: "gameOver")
    gameOver.position = CGPoint(x: 512, y: 384)
    gameOver.zPosition = 2
    addChild(gameOver)
    
    // Play game over sound file
    run(SKAction.playSoundFileNamed("GameOver.m4a", waitForCompletion: false))
    
    for slot in slots {
      slot.isVisible = false
    }
  }
}
