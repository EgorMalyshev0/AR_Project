//
//  RulerViewController.swift
//  #14
//
//  Created by Egor Malyshev on 09.03.2021.
//

import ARKit
import SceneKit

class RulerViewController: UIViewController, ARSessionDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var virtualObjectAnchor: ARAnchor?
    let virtualObjectAnchorName = "virtualObject"
    var virtualObject: SCNNode = {
        let sphere = SCNSphere(radius: 0.01)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        sphere.materials = [material]
        return SCNNode(geometry: sphere)
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.session.delegate = self
        gestureSetup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let config = ARWorldTrackingConfiguration()
        config.environmentTexturing = .automatic
        config.planeDetection = [.horizontal, .vertical]
        sceneView.debugOptions = [.showFeaturePoints]
        sceneView.session.run(config)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        distanceLabel.text = ""
        sceneView.session.pause()
    }
    
    func gestureSetup(){
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        sceneView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer){
        let location = sender.location(in: sceneView)
        if let query = sceneView.raycastQuery(from: location, allowing: .estimatedPlane, alignment: .any),
           let frame = sceneView.session.currentFrame,
           let firstResult = sceneView.session.raycast(query).first {
                let cameraTransform = frame.camera.transform
                let resultTransform = firstResult.worldTransform
                let distance = simd_distance(cameraTransform.columns.3, resultTransform.columns.3)
                print(distance)
                let distanceString = distance.roundedToHundredthsString()
                self.distanceLabel.text = distanceString + " m"
            
            
        }
        
        
//        if let existingAnchor = virtualObjectAnchor {
//            sceneView.session.remove(anchor: existingAnchor)
//        }
//        virtualObjectAnchor = ARAnchor(name: virtualObjectAnchorName, transform: hitTestResult.worldTransform)
        sceneView.session.add(anchor: virtualObjectAnchor!)
//        anchorEntity?.removeFromParent()
//        guard let frame = sceneView.session.currentFrame, let raycastResult = sceneView.raycast(from: location, allowing: .estimatedPlane, alignment: .any).first else {
//            anchorEntity = nil
//            distanceLabel.text = "Can't measure distance, try again"
//            return
//        }
//        let camera = frame.camera.transform
//        anchorEntity = AnchorEntity(world: raycastResult.worldTransform)
//        if let anchor = anchorEntity {
//            anchor.addChild(sphere(radius: 0.01, color: .red))
//            sceneView.scene.addAnchor(anchor)
//        }
//        let distance = simd_distance(camera.columns.3, raycastResult.worldTransform.columns.3)
//        let formatter = NumberFormatter()
//        formatter.maximumFractionDigits = 2
//        if let string = formatter.string(from: NSNumber(value: distance)){
//            distanceLabel.text = string + " meters"
//        }
    }
    
//    func sphere(radius: Float, color: UIColor) -> ModelEntity {
//        let sphere = ModelEntity(mesh: .generateSphere(radius: radius), materials: [SimpleMaterial(color: color, isMetallic: false)])
//        sphere.position.y = radius
//        return sphere
//    }
}

extension RulerViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard anchor.name == virtualObjectAnchorName
            else { return }
        if virtualObjectAnchor == nil {
            virtualObjectAnchor = anchor
        }
        node.addChildNode(virtualObject)
    }
}
extension Float {
    func roundedToHundredthsString() -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? String(describing: self)
    }
}
