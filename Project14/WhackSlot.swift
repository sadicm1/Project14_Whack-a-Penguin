//
//  WhackSlot.swift
//  Project14
//
//  Created by Mehmet Sadıç on 04/04/2017.
//  Copyright © 2017 Mehmet Sadıç. All rights reserved.
//

import UIKit
import SpriteKit

class WhackSlot: SKNode {
  
  // If penguin is visible
  var isVisible = false
  
  // If penguin is hit
  var isHit = false
  
  // Node which represents penguin
  var charNode: SKSpriteNode!
  
  /* Configure a hole in given position */
  func configure(at point: CGPoint) {
    
    // Make the position of class equal to the point in parameter
    self.position = point
    
    let hole = SKSpriteNode(imageNamed: "whackHole")
    addChild(hole)
    
    let cropNode = SKCropNode()
    cropNode.position = CGPoint(x: 0, y: 15)
    cropNode.zPosition = 1
    cropNode.maskNode = nil
    addChild(cropNode)
    
    charNode = SKSpriteNode(imageNamed: "penguinGood")
    charNode.position = CGPoint(x: 0, y: -90)
    cropNode.addChild(charNode)
    
    cropNode.maskNode = SKSpriteNode(imageNamed: "whackMask")
  }
  
  
  /* Show penguin */
  func show(hideTime: Double) {
    
    // Reset the penguin size. Because when it was hit the size got reduced
    charNode.setScale(1.0)
    
    // If the penguin is visible return
    if isVisible { return }
    
    // After showing the penguin it becomes visible
    isVisible = true
    
    // Penguin is still not hit
    isHit = false
    
    // 33% of time good penguin is shown. The rest of the time evil penguin is shown
    if RandomInt(min: 0, max: 2) == 0 {
      charNode.texture = SKTexture(imageNamed: "penguinGood")
      charNode.name = "charFriend"
    } else {
      charNode.texture = SKTexture(imageNamed: "penguinEvil")
      charNode.name = "charEvil"
    }
    
    if let moveUpMudEffect = SKEmitterNode(fileNamed: "MyParticle") {
      moveUpMudEffect.position = charNode.position
      moveUpMudEffect.run(SKAction.moveBy(x: 0, y: 100, duration: 0.05))
      moveUpMudEffect.zPosition = 1
      addChild(moveUpMudEffect)
    }
    
    // Move penguin up to make it visible
    charNode.run(SKAction.moveBy(x: 0, y: 80, duration: 0.05))
    
    // Hide penguin after hideTime * 3.5
    DispatchQueue.main.asyncAfter(deadline: .now() + hideTime * 3.5) { [unowned self] in
      self.hide()
    }
    

  }
  
  /* Hide penguin */
  func hide() {
    // Penguins should be visible. Return otherwise
    if !isVisible { return }
    
    // Now the penguin is not visible
    isVisible = false
    
    // Move penguin down to hide it
    charNode.run(SKAction.moveBy(x: 0, y: -80, duration: 0.05))
  }
  
  /* Hit penguin */
  func hit() {
    
    // Penguins shouldn't be already hit
    if isHit { return }
    isHit = true
    
    // Make the penguin smaller when it is hit.
    charNode.setScale(0.75)
    
    let wait = SKAction.wait(forDuration: 0.25)
    let notVisible = SKAction.run { [unowned self] in self.isVisible = false }
    let hide = SKAction.moveBy(x: 0, y: -80, duration: 0.25)
    
    // Create a smoke affect
    if let smokeEmitter = SKEmitterNode(fileNamed: "smokeEmitter") {
      smokeEmitter.position = charNode.position
      addChild(smokeEmitter)
    }
    
    
    // Create a sequence of three actions
    let sequence = SKAction.sequence([wait, notVisible, hide])
    
    // Run the sequence of actions on charNode
    charNode.run(sequence)
    
  }
}
