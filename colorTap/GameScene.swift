//
//  GameScene.swift
//  colorTap
//
//  Created by Angelina Olmedo on 12/8/19.
//  Copyright © 2019 Angelina Olmedo. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    //Score for game
    var score = 0
    
    enum Colors:String, CaseIterable {
        case red = "RED"
        case orange = "ORANGE"
        case yellow = "YELLOW"
        case green = "GREEN"
        case blue = "BLUE"
        case purple = "PURPLE"
    }
    
    var colorDict: [Colors: UIColor] = [
        Colors.red : UIColor.red,
        Colors.orange : UIColor.orange,
        Colors.yellow : UIColor.yellow,
        Colors.green : UIColor.green,
        Colors.blue : UIColor.blue,
        Colors.purple : UIColor.purple
    ]
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var scoreLabel : SKLabelNode?
    private var textLabel : SKLabelNode?
    private var colorLabel : SKLabelNode?
    private var timeLabel : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    var timer:Timer?
    var timeLeft = 60
    
    //return to start screen when game finished
    //let startScene = SKScene(fileNamed: "startScene")!
    //let transition = SKTransition.moveIn(with: .right, duration: 1)
    
    //instance vars
    var colorChoice = Colors.allCases.randomElement()!
    var textColorChoice = Colors.allCases.randomElement()!
    
    override func sceneDidLoad() {
        

        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.scoreLabel = self.childNode(withName: "//scoreLabel") as? SKLabelNode
        if let label = self.scoreLabel {
            label.alpha = 0.0
            label.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Label to hold the text-accurate color
        self.textLabel = self.childNode(withName: "//textLabel") as? SKLabelNode
        if let text = self.textLabel {
            text.text = self.colorChoice.rawValue
            text.alpha = 0.0
            text.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Label to hold the color-accurate color
        self.colorLabel = self.childNode(withName: "//colorLabel") as? SKLabelNode
        if let color = self.colorLabel {
            color.alpha = 0.0
            color.fontColor = colorDict[textColorChoice]
            color.text = "\(Colors.allCases.randomElement()!.rawValue)"
            color.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        //timer label
        self.timeLabel = self.childNode(withName: "//timeLabel") as? SKLabelNode
        if let time = self.textLabel {
            time.alpha = 0.0
            time.run(SKAction.fadeIn(withDuration: 2.0))
        }
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        //start timer
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
    }
    
    //when the time left changes
    @objc func onTimerFires()
    {
        timeLeft -= 1
        
        timeLabel!.text = "Time Remaining: \(timeLeft)"

        if timeLeft <= 0 {
            timer!.invalidate()
            timer = nil
            endGame()
        }
    }
    
    func endGame() {
        if let scene = GKScene(fileNamed: "startScene") {
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! SKScene? {
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode)
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //see if correct answer
        for touch in touches {
            //keeping the fancy spinner thing :)
            self.touchDown(atPoint: touch.location(in: self))
            
            //selected a yes/no button
            let positionInScene = touch.location(in: self)
            
            //Find the name for the node in that location
            let name = self.atPoint(positionInScene).name
            //print(name)
            
            //Check if there is an node there.
            if name == "yesButton" || name == "yesLabel" {
                //if yes is correct increase score
                if let label = self.scoreLabel {
                    label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
                    if colorChoice == textColorChoice {
                        score += 10
                    }
                    else {
                        score -= 10
                    }
                    label.text = "Score: \(score)"
                    nextSet()
                }
            }
            else if name == "noButton" || name == "noLabel" {
                //if no is correct increase score
                if let label = self.scoreLabel {
                    label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
                    if colorChoice != textColorChoice {
                        score += 10
                    }
                    else {
                        score -= 10
                    }
                    label.text = "Score: \(score)"
                    nextSet()
                }
            }
        }
    }
    
    func nextSet () {
        //set up next question
        colorChoice = Colors.allCases.randomElement()!
        textColorChoice = Colors.allCases.randomElement()!
        
        if let text = self.textLabel {
            text.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            text.text = "\(colorChoice.rawValue)"
            }
        if let color = self.colorLabel {
            color.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
            color.text = "\(Colors.allCases.randomElement()!.rawValue)"
            color.fontColor = colorDict[textColorChoice]
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
    }
}
