//
//  GameViewController.swift
//  #14
//
//  Created by Egor Malyshev on 03.03.2021.
//

import UIKit
import SceneKit
import ARKit
import RealityKit

enum TargetColor: Int, CaseIterable {
    case red
    case blue
    case green
    case yellow
    case purple
    case orange
    
    var color: UIColor {
        switch self {
        case .blue:
            return UIColor.blue
        case .red:
            return UIColor.red
        case .green:
            return UIColor.green
        case .yellow:
            return UIColor.yellow
        case .purple:
            return UIColor.purple
        case .orange:
            return UIColor.orange
        }
    }
    static var random: UIColor {
        return TargetColor(rawValue: Int.random(in: 0...TargetColor.allCases.count - 1))?.color ?? TargetColor.red.color
    }
}

class GameViewController: UIViewController, ARSCNViewDelegate{

    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.scene.physicsWorld.contactDelegate = self
        createTargets()
        let config = ARWorldTrackingConfiguration()
        sceneView.session.run(config)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(shoot))
        sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        segmentsSetup()
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
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            node.physicsBody?.isAffectedByGravity = false
            node.physicsBody?.categoryBitMask = CollisionCategory.targetCategory.rawValue
            print("\(node.name) with category \(node.physicsBody?.categoryBitMask) was created")
            node.physicsBody?.contactTestBitMask = CollisionCategory.missileCategory.rawValue
            node.position = SCNVector3(randomFloat(min: -10, max: 10),randomFloat(min: -4, max: 5),randomFloat(min: -10, max: 10))
            let action : SCNAction = SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 1.0)
            let forever = SCNAction.repeatForever(action)
            node.runAction(forever)
            sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    func createMissile() -> Missile {
        let color = TargetColor(rawValue: segmentedControl.selectedSegmentIndex)?.color ?? TargetColor.random
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
    
//    func segmentsSetup(){
//        for i in 0...5 {
//            let color = TargetColor(rawValue: i)?.color ?? TargetColor.random
//            let image = UIImage(systemName: "square.fill")?.withTintColor(color)
//            segmentedControl.setImage(image, forSegmentAt: i)
//        }
//    }
    
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
        print("Collision!! " + contact.nodeA.name! + " with category \(contact.nodeA.categoryBitMask) hit " + contact.nodeB.name! + " with category \(contact.nodeB.categoryBitMask)")
        DispatchQueue.main.async {
            if let a = contact.nodeA as? TargetBox,
               let b = contact.nodeB as? Missile {
                if a.color == b.color {
                    if let explosion = SCNParticleSystem(named: "Explode", inDirectory: nil){
                        a.addParticleSystem(explosion)
                    }
                    a.removeFromParentNode()
                    b.removeFromParentNode()
                } else {
                    b.removeFromParentNode()
                }
            } else if let a = contact.nodeA as? Missile,
                      let b = contact.nodeB as? TargetBox{
                if a.color == b.color {
                    if let explosion = SCNParticleSystem(named: "Explode", inDirectory: nil){
                        b.addParticleSystem(explosion)
                    }
                    a.removeFromParentNode()
                    b.removeFromParentNode()
                } else {
                    a.removeFromParentNode()
                }
            }
        }
    }
}
