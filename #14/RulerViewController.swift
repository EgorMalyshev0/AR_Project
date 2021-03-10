//
//  RulerViewController.swift
//  #14
//
//  Created by Egor Malyshev on 09.03.2021.
//

import ARKit
import RealityKit

class RulerViewController: UIViewController, ARSessionDelegate {

    @IBOutlet weak var arView: ARView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        arView.session.delegate = self
        
        let config = ARWorldTrackingConfiguration()
        arView.session.run(config)
        
        gestureSetup()
    }
    
    func gestureSetup(){
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        arView.addGestureRecognizer(tapRecognizer)
    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer){
        let location = sender.location(in: arView)
        guard let frame = arView.session.currentFrame, let raycastResult = arView.raycast(from: location, allowing: .estimatedPlane, alignment: .any).first else {
            distanceLabel.text = "Can't measure distance, try again"
            return
        }
        let camera = frame.camera.transform
        let anchorEntity = AnchorEntity(world: raycastResult.worldTransform)
        anchorEntity.addChild(sphere(radius: 0.01, color: .red))
        arView.scene.addAnchor(anchorEntity)
        let distance = simd_distance(camera.columns.3, raycastResult.worldTransform.columns.3)
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        if let string = formatter.string(from: NSNumber(value: distance)){
            distanceLabel.text = string + " meters"
        }
    }
    
    func sphere(radius: Float, color: UIColor) -> ModelEntity {
        let sphere = ModelEntity(mesh: .generateSphere(radius: radius), materials: [SimpleMaterial(color: color, isMetallic: false)])
        sphere.position.y = radius
        return sphere
    }
}

