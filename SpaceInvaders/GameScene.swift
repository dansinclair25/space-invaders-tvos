//
//  GameScene.swift
//  SpaceInvaders
//
//  Created by Dan Sinclair on 27/12/2015.
//  Copyright (c) 2015 Dan Sinclair. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    enum InvaderType {
        case A
        case B
        case C
    }
    
    enum InvaderMovementDirection {
        case Right
        case Left
        case DownThenRight
        case DownThenLeft
        case None
    }
    
    let kInvaderSize = CGSize(width:48, height:32)
    let kInvaderGridSpacing = CGSize(width:24, height:24)
    let kInvaderRowCount = 5
    let kInvaderColCount = 10
    
    let kInvaderName = "invader"
    let kShipSize = CGSize(width:60, height:32)
    let kShipName = "ship"
    
    let kScoreHudName = "scoreHud"
    let kHealthHudName = "healthHud"
    
    var contentCreated = false
    
    var invaderMovementDirection: InvaderMovementDirection = .Right
    var timeOfLastMove: CFTimeInterval = 0.0
    let timePerMove: CFTimeInterval = 1.0
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        if (!contentCreated) {
            createContent()
            contentCreated = true
        }
    }
    
    func createContent() {
        
        setupInvaders()
        setupShip()
        setupHud()
        
        backgroundColor = SKColor.blackColor()
    }
    
    func makeInvaderOfType(invaderType: InvaderType) -> (SKNode) {
        
        // 1
        var invaderColor: SKColor
        
        switch(invaderType) {
        case .A:
            invaderColor = SKColor.redColor()
        case .B:
            invaderColor = SKColor.greenColor()
        case .C:
            invaderColor = SKColor.blueColor()
        }
        
        // 2
        let invader = SKSpriteNode(color: invaderColor, size: kInvaderSize)
        invader.name = kInvaderName
        
        return invader
    }
    
    func setupInvaders() {
        
        let baseOrigin = CGPoint(x:size.width / 3, y:self.size.height / 2)
        for var row = 1; row <= kInvaderRowCount; row++ {
            
            var invaderType: InvaderType
            if row % 3 == 0 {
                invaderType = .A
            } else if row % 3 == 1 {
                invaderType = .B
            } else {
                invaderType = .C
            }
            
            let invaderPositionY = CGFloat(row) * (kInvaderSize.height * 2) + baseOrigin.y
            var invaderPosition = CGPoint(x:baseOrigin.x, y:invaderPositionY)
            
            for var col = 1; col <= kInvaderColCount; col++ {
                
                let invader = makeInvaderOfType(invaderType)
                invader.position = invaderPosition
                addChild(invader)
                
                invaderPosition = CGPoint(x: invaderPosition.x + kInvaderSize.width + kInvaderGridSpacing.width, y: invaderPositionY)
            }
        }
    }
    
    func setupShip() {
        let ship = makeShip()
        
        ship.position = CGPoint(x:size.width / 2.0, y:kShipSize.height / 2.0)
        addChild(ship)
    }
    
    func makeShip() -> SKNode {
        let ship = SKSpriteNode(color: SKColor.orangeColor(), size: kShipSize)
        ship.name = kShipName
        return ship
    }
    
    func setupHud() {
        let scoreLabel = SKLabelNode(fontNamed: "Courier")
        scoreLabel.name = kScoreHudName
        scoreLabel.fontSize = 50
        
        scoreLabel.fontColor = SKColor.whiteColor()
        scoreLabel.text = String(format: "Score: %04u", 0)
        
        print(size.height)
        scoreLabel.position = CGPoint(x: scoreLabel.frame.width / 2 + 20, y: size.height - scoreLabel.frame.size.height - 20)
        addChild(scoreLabel)
        
        let healthLabel = SKLabelNode(fontNamed: "Courier")
        healthLabel.name = kHealthHudName
        healthLabel.fontSize = 50
        
        healthLabel.fontColor = SKColor.whiteColor()
        healthLabel.text = String(format: "Health: %.1f%%", 100.0)
        
        healthLabel.position = CGPoint(x: frame.size.width - healthLabel.frame.width / 2 - 20, y: size.height - healthLabel.frame.size.height - 20)
        addChild(healthLabel)
    }
    
    func moveInvadersForUpdate(currentTime: CFTimeInterval) {
        
        if (currentTime - timeOfLastMove < timePerMove) {
            return
        }
        
        determineInvaderMovementDirection()
        
        enumerateChildNodesWithName(kInvaderName) {
            node, stop in
            
            switch self.invaderMovementDirection {
            case .Right:
                node.position = CGPoint(x: node.position.x + 10, y: node.position.y)
            case .Left:
                node.position = CGPoint(x: node.position.x - 10, y: node.position.y)
            case .DownThenLeft, .DownThenRight:
                node.position = CGPoint(x: node.position.x, y: node.position.y - 10)
            case .None:
                break
            }
            
            self.timeOfLastMove = currentTime
        }
    }
    
    func determineInvaderMovementDirection() {
        
        var proposedMovementDirection: InvaderMovementDirection = invaderMovementDirection
        
        enumerateChildNodesWithName(kInvaderName) { node, stop in
            switch self.invaderMovementDirection {
            case .Right:
                if (CGRectGetMaxX(node.frame) >= node.scene!.size.width - 1.0) {
                    proposedMovementDirection = .DownThenLeft
                    stop.memory = true
                }
            case .Left:
                if (CGRectGetMinX(node.frame) <= 1.0) {
                    proposedMovementDirection = .DownThenRight
                    
                    stop.memory = true
                }
            case .DownThenLeft:
                proposedMovementDirection = .Left
                stop.memory = true
            case .DownThenRight:
                proposedMovementDirection = .Right
                stop.memory = true
            default:
                break
            }
        }
        
        if (proposedMovementDirection != invaderMovementDirection) {
            invaderMovementDirection = proposedMovementDirection
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        moveInvadersForUpdate(currentTime)
    }
}
