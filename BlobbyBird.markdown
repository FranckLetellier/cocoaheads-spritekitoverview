# New Snippetty Document
Will create a setup method:
```
private func setupGame() {

    // 1 - Add player Node

    state = .running
}
```

Create a sprite without image:
```
// 1 - Add player Node
let playerNode = SKSpriteNode(color: .white, size: CGSize(width:100,height:100))
addChild(playerNode)
player = playerNode
```

Create a sprite with an image:
```
let playerNode = SKSpriteNode(imageNamed: "frame-1.png")
playerNode.size = CGSize(width: playerNode.size.width/3, height: playerNode.size.height/3)
```

Place Player Node:
```
player?.position = CGPoint(x: 100, y: size.height/2)
```
Create Texture:
```
// 2 - Setup animation
let animation = [SKTexture(imageNamed: "frame-1.png"),
SKTexture(imageNamed: "frame-2.png"),
SKTexture(imageNamed: "frame-3.png"),
SKTexture(imageNamed: "frame-4.png")]
```

Create animation:
```
let action = SKAction.animate(with: animation, timePerFrame: 0.1)
playerNode.run(SKAction.repeatForever(action))
```

Create Physics Bodies
```
// 3 - Physics
playerNode.physicsBody = SKPhysicsBody(circleOfRadius: playerNode.size.width/3)
```

Create floor:
```
let bounds = SKNode()
let floor = SKPhysicsBody(edgeFrom: CGPoint(x: 0,y: 0), to: CGPoint(x: size.width, y: 0))
bounds.physicsBody = floor
addChild(bounds)
```

Create user interactions:
```
override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard state == .running else {return}
    player!.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 50))
}
```

Use velicity to animate:
```
override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
    guard let player = player else {return}
    let angle = (player.physicsBody!.velocity.dy * 0.001)
    player.zRotation = angle.clamped(to: -1...0.5)
}
```

Create Obstacle (+ need to add an obstacle as child) :
```
private func createObstacle() -> SKNode {

    let obstacleSize = CGSize(width: 50, height: 200)
    let obstacle = SKShapeNode(rect:CGRect(x: 0, y: 0, width: obstacleSize.width, height: obstacleSize.height), cornerRadius: 8)

    // Design
    obstacle.fillColor = .yellow

    // Physics
    obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacleSize,
    center: CGPoint(x:obstacleSize.width/2,y:obstacleSize.height/2))
    // We want to avoid being subject to physic world
    obstacle.physicsBody?.isDynamic = false
    obstacle.position = CGPoint(x: size.width + obstacleSize.width, y: 0)

    return obstacle
}
```

Make obstacle move:
```
// First action :
//   - Move the obstacle all the way to the left side of the screen
//   - Over a course of 5 seconds
let moveBuildingAction = SKAction.moveTo(x: -obstacleSize.width, duration: 5)

// Second Action : Remove the node from the scene
let removeAction = SKAction.removeFromParent()
obstacle.run(SKAction.sequence([moveBuildingAction,removeAction]))
```

Add several obstacles :
```
// 4 - Obstacles
let createOnbstacleAction = SKAction.run { [weak self] in
    guard let obstacle = self?.createObstacle() else { return }
    self?.addChild(obstacle)
}

let waitAction = SKAction.wait(forDuration: 1)
let obstacleSequence = SKAction.sequence([createOnbstacleAction,waitAction])
run(SKAction.repeatForever(obstacleSequence))
```

Refactor obstacle creation:
```
private func createObstacle() -> SKNode {
    // Setup random height for obstacle
    let minHeight:CGFloat = 50
    let maxHeight = (size.height / 2.0) - minHeight
    let height = minHeight + CGFloat(arc4random_uniform(UInt32(maxHeight)))
    let isUpsidedown = (arc4random_uniform(2) == 1)

    let obstacleSize = CGSize(width: 50, height: height)
    let obstacle = SKShapeNode(rect:CGRect(x: 0, y: 0, width: obstacleSize.width, height: obstacleSize.height), cornerRadius: 8)

    // Design
    obstacle.fillColor = .yellow

    // Physics
    obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacleSize,
    center: CGPoint(x:obstacleSize.width/2,y:obstacleSize.height/2))
    obstacle.physicsBody?.isDynamic = false


    let yPosition = isUpsidedown ? size.height - obstacleSize.height : 0
    obstacle.position = CGPoint(x: size.width + obstacleSize.width, y: yPosition)

    // First action :
    //   - Move the obstacle all the way to the left side of the screen
    //   - Over a course of 5 seconds
    let moveBuildingAction = SKAction.moveTo(x: -obstacleSize.width, duration: 5)

    // Second Action : Remove the node from the scene
    let removeAction = SKAction.removeFromParent()
    obstacle.run(SKAction.sequence([moveBuildingAction,removeAction]))

    return obstacle
}
```

Add physicsWorld delegate:
```
physicsWorld.contactDelegate = self
```

Add physicsWord Methods:
```
// MARK: SKPhysicsContactDelegate methods
extension GameScene: SKPhysicsContactDelegate {
    public func didBegin(_ contact: SKPhysicsContact) {


    }
}
```

Add physics Category:
```
struct GamePhysicsCategory {
    static let player: UInt32 = 0b1
    static let obstacle: UInt32 = 0b10
    static let ground: UInt32 = 0b11
}
```

Categorized physics object :
```
// 5 - Contact event
player?.physicsBody?.categoryBitMask = GamePhysicsCategory.player
player?.physicsBody?.collisionBitMask = GamePhysicsCategory.ground | GamePhysicsCategory.obstacle
player?.physicsBody?.contactTestBitMask = GamePhysicsCategory.ground | GamePhysicsCategory.obstacle

bounds.physicsBody?.categoryBitMask = GamePhysicsCategory.ground
```

Categorized obstacle:
```
obstacle.physicsBody?.categoryBitMask = GamePhysicsCategory.obstacle
```

Stop game at contact
```
// We are only interested in contact while the game is running
guard state == .running else {return}
state = .over
```

Stop action
```
// Stop all action
speed = 0
```

Add gameover UI
```
private lazy var gameOverUI: SKNode = {
    let gameOverUI = SKNode()

    // Title
    let label = SKLabelNode(text: "Game Over!")
    label.position = CGPoint(x:size.width/2,y:size.height/2)

    // Action to restart the game
    let button = SKButton(size:CGSize(width:200,height:44),title:"Play again") { [weak self] in
    self?.resetGame()
    }
    button.position = CGPoint(x:size.width/2,y:size.height/4)

    // Add it all up to the UI node
    gameOverUI.addChild(label)
    gameOverUI.addChild(button)

    return gameOverUI
}()
```
Add reset method
```
// MARK: Game lifecyle
private func resetGame() {
    // Remove all unnecessary nodes
    obstaclesNode?.removeAllChildren()
    gameOverUI.removeFromParent()

    // Resume Action
    speed = 1

    player?.physicsBody?.velocity = .zero

    state = .setup
    launchGame()
}

private func launchGame() {
    player?.position = CGPoint(x: 100, y: size.height/2)
    state = .running
}
```

Add node for obstacle:
```
obstaclesNode = SKNode()
addChild(obstaclesNode!)
```
