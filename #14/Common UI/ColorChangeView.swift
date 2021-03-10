//
//  ColorChangeView.swift
//  #14
//
//  Created by Egor Malyshev on 09.03.2021.
//

import UIKit

class ColorChangeView: UIView {
    
    var currentColor: UIColor! = TargetColor(rawValue: 0)?.color

    @IBOutlet var view: UIView!
    @IBOutlet var buttons: [UIButton]!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    func setupUI(){
        view = Bundle(for: type(of: self)).loadNibNamed("ColorChangeView", owner: self)?.first as? UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        for (i, button) in buttons.enumerated(){
            button.tintColor = TargetColor(rawValue: i)?.color ?? TargetColor.random
            button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
        }
    }
    
    @objc func tapped(_ sender: UIButton){
        for button in buttons{
            if button == sender {
                button.backgroundColor = .black
                currentColor = button.tintColor
            } else {
                button.backgroundColor = .clear
            }
        }
    }
    
}
