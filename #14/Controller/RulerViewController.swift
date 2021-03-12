//
//  RulerViewController.swift
//  #14
//
//  Created by Egor Malyshev on 09.03.2021.
//

import ARKit
import SceneKit

class RulerViewController: UIViewController, ARSessionDelegate {

    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    var virtualObject: SCNNode = {
        let sphere = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        sphere.materials = [material]
        return SCNNode(geometry: sphere)
    }()
    
    var counter: Int = 0
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurView.layer.cornerRadius = 4
        blurView.clipsToBounds = true
        
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
        virtualObject.removeFromParentNode()
        if let query = sceneView.raycastQuery(from: location, allowing: .estimatedPlane, alignment: .any),
           let frame = sceneView.session.currentFrame,
           let firstResult = sceneView.session.raycast(query).first {
            counter = 0
            let cameraTransform = frame.camera.transform
            let resultTransform = firstResult.worldTransform
            let distance = simd_distance(cameraTransform.columns.3, resultTransform.columns.3)
            let distanceString = distance.roundedToHundredthsString()
            self.distanceLabel.text = distanceString + " m"
            
            let resultCoordinates = resultTransform.columns.3
            virtualObject.position = SCNVector3(resultCoordinates.x, resultCoordinates.y, resultCoordinates.z)
            sceneView.scene.rootNode.addChildNode(virtualObject)
        } else if counter == 2 {
            counter = 0
            distanceLabel.text = "Try to move camera"
        } else {
            counter += 1
            distanceLabel.text = "Try again"
        }
    }
}

extension Float {
    func roundedToHundredthsString() -> String {
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: self)) ?? String(describing: self)
    }
}
