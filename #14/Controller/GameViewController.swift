//
//  GameViewController.swift
//  #14
//
//  Created by Egor Malyshev on 03.03.2021.
//

import ARKit
import RealityKit

class GameViewController: UIViewController, ARSCNViewDelegate{

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var parentView: UIView!
    
    var colorChangeView: ColorChangeView!
    
    var missiles: [SCNNode?] = []
    
    override var prefersStatusBarHidden: Bool { return true }
    override var prefersHomeIndicatorAutoHidden: Bool { return true }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurView.layer.cornerRadius = 6
        blurView.clipsToBounds = true
        
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        createTargets()
        
        let config = ARWorldTrackingConfiguration()
        sceneView.session.run(config)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(shoot))
        sceneView.addGestureRecognizer(gestureRecognizer)
        let view = ColorChangeView(frame: parentView.bounds)
        parentView.addSubview(view)
        colorChangeView = view
    }
    
    @IBAction func closeScreen(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func createTargets(){
        let light = SCNLight()
        light.type = SCNLight.LightType.omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
        sceneView.scene.rootNode.addChildNode(lightNode)
        
        for i in 1...100 {
            let color = TargetColor.random
            let node = TargetBox(color: color)
            node.name = "Box №\(i)"
            node.physicsBody = SCNPhysicsBody(type: .static, shape: nil)
            node.physicsBody?.isAffectedByGravity = false
            node.physicsBody?.categoryBitMask = CollisionCategory.targetCategory.rawValue
            node.physicsBody?.contactTestBitMask = CollisionCategory.missileCategory.rawValue
            node.position = SCNVector3(randomFloat(min: -10, max: 10),randomFloat(min: -4, max: 5),randomFloat(min: -10, max: 10))
            let action : SCNAction = SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 1.0)
            let forever = SCNAction.repeatForever(action)
            node.runAction(forever)
            sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    func createMissile() -> Missile {
        let color = colorChangeView.currentColor ?? TargetColor.random
        let node = Missile(color: color)
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.isAffectedByGravity = false
        node.physicsBody?.categoryBitMask = CollisionCategory.missileCategory.rawValue
        node.physicsBody?.contactTestBitMask = CollisionCategory.targetCategory.rawValue
        return node
    }
    
    @objc func shoot() {
        let node = createMissile()
        node.name = "Missile"
        let (direction, position) = getUserVector()
        node.position = position
        let nodeDirection  = SCNVector3(direction.x*4,direction.y*4,direction.z*4)
        node.physicsBody?.applyForce(nodeDirection, at: SCNVector3(0.1,0,0), asImpulse: true)
        sceneView.scene.rootNode.addChildNode(node)
        Timer.scheduledTimer(withTimeInterval: 7, repeats: false) { (timer) in
            node.removeFromParentNode()
        }
    }
    
    func getUserVector() -> (SCNVector3, SCNVector3) {
        if let frame = self.sceneView.session.currentFrame {
            let matrix = SCNMatrix4(frame.camera.transform)
            let direction = SCNVector3(-1 * matrix.m31, -1 * matrix.m32, -1 * matrix.m33)
            let position = SCNVector3(matrix.m41, matrix.m42, matrix.m43)
            return (direction, position)
        }
        return (SCNVector3(0, 0, -1), SCNVector3(0, 0, -0.2))
    }
    
    func randomFloat(min: CGFloat, max: CGFloat) -> CGFloat {
        return CGFloat.random(in: min...max)
    }

}

struct CollisionCategory: OptionSet {
    let rawValue: Int
    
    static let missileCategory  = CollisionCategory(rawValue: 1 << 0)
    static let targetCategory = CollisionCategory(rawValue: 1 << 1)
    static let otherCategory = CollisionCategory(rawValue: 1 << 2)
}

extension GameViewController: SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        if let a = contact.nodeA as? TargetBox,
           let b = contact.nodeB as? Missile {
            if a.color == b.color {
                a.removeFromParentNode()
                b.removeFromParentNode()
            } else {
                b.removeFromParentNode()
            }
        } else if let a = contact.nodeA as? Missile,
                  let b = contact.nodeB as? TargetBox{
            if a.color == b.color {
                a.removeFromParentNode()
                b.removeFromParentNode()
            } else {
                a.removeFromParentNode()
            }
        }
    }
}
