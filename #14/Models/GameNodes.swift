//
//  GameNodes.swift
//  #14
//
//  Created by Egor Malyshev on 06.03.2021.
//

import SceneKit

final class TargetBox: SCNNode {
    
    var color: UIColor!
    
    convenience init(color: UIColor) {
        self.init()
        let box = SCNBox(width: 0.3, height: 0.3, length: 0.3, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = color
        box.materials = [material]
        self.geometry = box
        self.color = color
    }
}

final class Missile: SCNNode {
    
    var color: UIColor!
    
    convenience init(color: UIColor) {
        self.init()
        let sphere = SCNSphere(radius: 0.1)
        let material = SCNMaterial()
        material.diffuse.contents = color
        sphere.materials = [material]
        self.geometry = sphere
        self.color = color
    }
}
