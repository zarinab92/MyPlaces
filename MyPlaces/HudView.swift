//
//  HudView.swift
//  MyPlaces
//
//  Created by Zarina Bekova on 10/31/20.
//

import UIKit

class HudView: UIView {
    var text = "Done"
    
    static func hud(inView view: UIView, animated: Bool) -> HudView {
        let hudView = HudView(frame: view.bounds)
        hudView.isOpaque = false
        
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        
        hudView.backgroundColor = UIColor.init(white: 0.7, alpha: 0.5)
        
        hudView.show(animated: animated)
        return hudView
    }
    
    
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 100
        let boxHeight: CGFloat = 100
        
        let boxRect = CGRect(x: round((bounds.size.width - boxWidth) / 2),
                             y: round((bounds.size.height - boxHeight) / 2),
                             width: boxWidth, height: boxHeight)
        
        let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10)
        
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        if let image = UIImage(named: "Checkmark") {
            let imagePoint = CGPoint(x: center.x - round(image.size.width / 2),
                                     y: center.y - round(image.size.height / 2) - 15)
            image.draw(at: imagePoint)
        }
        
        let textAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.foregroundColor: UIColor.white
        ]
        
        let textSize = text.size(withAttributes: textAttributes)
        
        let textPoint = CGPoint(x: center.x - round(textSize.width / 2),
                                y: center.y - round(textSize.height / 2) + 15)
        
        text.draw(at: textPoint, withAttributes: textAttributes)
    }
    
    
    func show(animated: Bool) {
        if animated == true {
            self.alpha = 0
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
                self.transform = CGAffineTransform.identity
            }
        }
    }
    
    func hide() {
        superview?.isUserInteractionEnabled = true
        self.removeFromSuperview()
    }
}

