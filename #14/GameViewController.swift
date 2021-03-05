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

class GameViewController: UIViewController {

    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let config = ARWorldTrackingConfiguration()
        sceneView.session.run(config)
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(shoot))
        sceneView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        segmentsSetup()
        createTargets()
    }
    
    func createTargets(){
        let light = SCNLight()
        light.type = SCNLight.LightType.omni
        let lightNode = SCNNode()
        lightNode.light = light
        lightNode.position = SCNVector3(x: 1.5, y: 1.5, z: 1.5)
        sceneView.scene.rootNode.addChildNode(lightNode)
        
        for _ in 1...100 {
            let box = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0)
            let material = SCNMaterial()
            let color = TargetColor.init(rawValue: Int.random(in: 0...5))?.color
            material.diffuse.contents = color ?? UIColor.red
            box.materials = [material]
            let node = SCNNode(geometry: box)
            node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
            node.physicsBody?.isAffectedByGravity = false
            node.position = SCNVector3(randomFloat(min: -10, max: 10),randomFloat(min: -4, max: 5),randomFloat(min: -10, max: 10))
            let action : SCNAction = SCNAction.rotate(by: .pi, around: SCNVector3(0, 1, 0), duration: 1.0)
            let forever = SCNAction.repeatForever(action)
            node.runAction(forever)
            sceneView.scene.rootNode.addChildNode(node)
        }
    }
    
    @objc func shoot() {
        guard let color = TargetColor(rawValue: segmentedControl.selectedSegmentIndex)?.color else { return }
        let (direction, position) = getUserVector()
        let sphere = SCNSphere(radius: 0.1)
        let material = SCNMaterial()
        material.diffuse.contents = color
        sphere.materials = [material]
        let node = SCNNode(geometry: sphere)
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.physicsBody?.isAffectedByGravity = false
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
