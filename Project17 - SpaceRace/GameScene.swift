//
//  GameScene.swift
//  Project17 - SpaceRace
//
//  Created by Noah Pope on 10/10/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfield: SKEmitterNode!
    var player: SKSpriteNode!
    let possibleEnemies             = [ImageKeys.ball, ImageKeys.hammer, ImageKeys.tv]
    var enemiesCreated              = 0
    var isGameOver                  = false
    var gameTimer: Timer?
    var timeInterval: TimeInterval  = 1.0 {
        didSet { gameTimer          = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true) }
    }
    
    var scoreLabel: SKLabelNode!
    var score                       = 0 {
        didSet { scoreLabel.text    = "Score: \(score)"}
    }
    
    override func didMove(to view: SKView) {
        backgroundColor                         = .black
            
        starfield                               = SKEmitterNode(fileNamed: ImageKeys.starfield)!
        starfield.position                      = CGPoint(x: 1024, y: 384)
        starfield.zPosition                     = -1
        starfield.advanceSimulationTime(10)
        addChild(starfield)
        
        player                                  = SKSpriteNode(imageNamed: ImageKeys.player)
        player.position                         = CGPoint(x: 100, y: 384)
        // pixel perfect collision (below)
        player.physicsBody                      = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask  = 1
        addChild(player)
        
        scoreLabel                              = SKLabelNode(fontNamed: FontKeys.chalkduster)
        scoreLabel.position                     = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode      = .left
        addChild(scoreLabel)
        
        score                                   = 0
        
        physicsWorld.gravity                    = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate            = self
                
        gameTimer                               = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    
    @objc func createEnemy() {
        guard let enemy                     = possibleEnemies.randomElement() else { return }
        guard !isGameOver else { return }
        
        if enemiesCreated % 20 == 0 {
            gameTimer?.invalidate()
            timeInterval -= 0.1
        }
        
        let sprite                          = SKSpriteNode(imageNamed: enemy)
        sprite.position                     = CGPoint(x: 1200, y: Int.random(in: 50...736))
        sprite.physicsBody                  = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity        = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.linearDamping   = 0
        sprite.physicsBody?.angularDamping  = 0
        addChild(sprite)
        
        enemiesCreated += 1
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // too much work in here will slow game down
        for node in children {
            if node.position.x < -300 { node.removeFromParent() }
        }
        
        if !isGameOver { score += 1 }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location    = touch.location(in: self)
        
        if location.y < 100 { location.y = 100 }
        else if location.y > 668 { location.y = 668 }
        
        player.position = location
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion       = SKEmitterNode(fileNamed: EmitterKeys.explosion)!
        explosion.position  = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        isGameOver          = true
    }
}
