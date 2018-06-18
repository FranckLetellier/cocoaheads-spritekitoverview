import SpriteKit

/**
 A simple white button with a text
 */
class SKButton: SKNode {
    // TODO: make better with status (Active,...)
    private var action:() -> Void
    private var backgroundNode: SKSpriteNode
    
    /**
     Default Init
     
     - Parameter size: Actual Size of the button
     - Parameter title: title Button's Title
     - Parameter action: block called on TouchUpInside like behavior
     */
    init(size: CGSize, title:String?, action: @escaping ()->Void){
        self.action = action
        self.backgroundNode = SKSpriteNode(color: .white, size: size)
        super.init()
        
        // Needed to be able to interact with the button
        isUserInteractionEnabled = true
        
        let titleLabel = SKLabelNode(text: title)
        titleLabel.fontColor = .black
        titleLabel.verticalAlignmentMode = .center
        
        addChild(backgroundNode)
        addChild(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // The touch need to be place inside the button coordinate system
        // to know if it's inside or not
        guard   let touch = touches.first,
                let parent = self.parent else { return }
        if contains(touch.location(in: parent)) {
            action()
        }
    }
}
