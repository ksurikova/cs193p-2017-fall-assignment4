//
//  DeckView.swift
//  cs193p-2017-fall-assignment4
//
//  Created by Ksenia Surikova on 13.04.2022.
//

import UIKit

class DeckView: UIView {
    
    required init(){
        super.init(frame: CGRect.zero)
        contentMode = .redraw
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentMode = .redraw
    }
    
    var calcAspectHeight : CGFloat {get
        {
            bounds.height * SetCardViewConstants.cardAspectRatio > bounds.width ? bounds.width / SetCardViewConstants.cardAspectRatio : bounds.height
        }
    }
    var calcAspectWidth : CGFloat{get
        {
            bounds.height * SetCardViewConstants.cardAspectRatio > bounds.width ? bounds.width : bounds.height * SetCardViewConstants.cardAspectRatio
        }
    }
    
    override func draw(_ rect: CGRect) {
        let rect = UIBezierPath(roundedRect: CGRect(x: bounds.midX - calcAspectWidth/2, y: bounds.midY - calcAspectHeight/2, width: calcAspectWidth, height: calcAspectHeight),
                                cornerRadius: calcAspectHeight/10)
        SetCardViewConstants.shirtColor.setFill()
        rect.fill()
        let rectLayer = CAShapeLayer()
        rectLayer.path = rect.cgPath
        layer.mask = rectLayer
    }
    
    // we need it to set some behaviour that we handle click only for colored area
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let view = super.hitTest(point, with: event){
            let modifiedPoint = self.convert(point, to: view)
            let color = view.colorOfPoint(point: modifiedPoint)
            if color.isClear(){
                return nil
            }
            else {
                return self
            }
        }
        return nil
    }
}

extension UIView {
  func colorOfPoint(point: CGPoint) -> UIColor {
    let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
    
    var pixelData: [UInt8] = [0, 0, 0, 0]
    
    let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
    
    context!.translateBy(x: -point.x, y: -point.y)
    
    self.layer.render(in: context!)
    
    let red: CGFloat = CGFloat(pixelData[0]) / CGFloat(255.0)
    let green: CGFloat = CGFloat(pixelData[1]) / CGFloat(255.0)
    let blue: CGFloat = CGFloat(pixelData[2]) / CGFloat(255.0)
    let alpha: CGFloat = CGFloat(pixelData[3]) / CGFloat(255.0)
    
    let color: UIColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    
    return color
  }
}

extension UIColor {
    func isClear() -> Bool {
        // Get alpha value of color
        var alpha: CGFloat = 0.0
        self.getWhite(nil, alpha: &alpha)
        return alpha == 0.0
    }
}

