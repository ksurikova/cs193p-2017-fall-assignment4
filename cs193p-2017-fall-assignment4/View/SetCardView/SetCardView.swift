//
//  SetCardView.swift
//  cs193p-2017-fall-assignment4
//
//  Created by Ksenia Surikova on 15.03.2022.
//

import UIKit


@IBDesignable
class SetCardView: UIView {
    
    @IBInspectable
    var isFaceUp: Bool = true { didSet {
        setNeedsDisplay(); setNeedsLayout() } }
    
    @IBInspectable
    var isSelected: Bool = false { didSet {
        if isFaceUp {
            if !isSelected {
                isMatched = nil
            }
            borderColor = isSelected ? DefaultUIConstants.chosenCardColor : DefaultUIConstants.borderColor}
    }}
    var isMatched: Bool? { didSet {
        if isFaceUp {
            if let match = isMatched {
                isSelected = true
                borderColor =  match ? DefaultUIConstants.matchedCardColor : DefaultUIConstants.mismatchedCardColor}
        }
    }}
    
   
    @IBInspectable var borderColor : UIColor = DefaultUIConstants.borderColor {
        didSet {
            layer.borderColor = borderColor.cgColor
            setNeedsDisplay(); setNeedsLayout()
        }
    }

    @IBInspectable var borderWidth : CGFloat = DefaultUIConstants.borderWidth {
        didSet {
            layer.borderWidth = borderWidth
            setNeedsDisplay(); setNeedsLayout()
        }
    }

    @IBInspectable var cornerRadius : CGFloat = DefaultUIConstants.cornerRadius {
        didSet {
            layer.cornerRadius = cornerRadius
            setNeedsDisplay(); setNeedsLayout()
        }
    }
    
    @IBInspectable
    var symbolKindInt: Int = 1 {
        didSet {
            switch symbolKindInt {
            case 1: symbol = .oval
            case 2: symbol = .squiggle
            case 3: symbol = .diamond
            default: break
            }
        }
    }
    
    @IBInspectable
    var fillKindInt: Int = 1 {
        didSet {
            switch fillKindInt {
            case 1: fill = .solid
            case 2: fill = .striped
            case 3: fill = .unfilled
            default: break
            }
        }
    }
    
    @IBInspectable
    var colorKindInt: Int = 1 {
        didSet {
            switch colorKindInt {
            case 1: color = SetColor.green
            case 2: color = SetColor.red
            case 3: color = SetColor.purple
            default: break
            }
        }
    }
    
    @IBInspectable
    var symbolsCount: Int = 1 {didSet {setNeedsDisplay(); setNeedsLayout()}}
    
    private var color: UIColor = SetColor.green {didSet {setNeedsDisplay(); setNeedsLayout()}}
    private var fill = Fill.unfilled{didSet {setNeedsDisplay(); setNeedsLayout()}}
    private var symbol = Symbol.squiggle{didSet {setNeedsDisplay(); setNeedsLayout()}}
    
    
    required init(with card: SetCard){
        self.card = card
        super.init(frame: CGRect.zero)
        updateViewFromCard(card)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var card : SetCard {
        didSet {
            updateViewFromCard(card)
        }
    }
    
    private func updateViewFromCard(_ card: SetCard) {
        symbolsCount = card.firstSign.rawValue
        colorKindInt = card.secondSign.rawValue
        fillKindInt = card.thirdSign.rawValue
        symbolKindInt = card.fourthSign.rawValue
        setNeedsDisplay()
        setNeedsLayout()
    }
    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        let rect = UIBezierPath(roundedRect: bounds,
                                cornerRadius: cornerRadius)
        if isFaceUp {
            drawCard(rect)
        }
        else {
            SetCardViewConstants.shirtColor.setFill()
            rect.fill()
        }
    }
    
    private func drawCard(_ path: UIBezierPath) {
        DefaultUIConstants.backgroundColor.setFill()
        path.fill()
        let areaToDrawSymbols = path.bounds.insetBy(dx: DefaultUIConstants.cornerOffset, dy: DefaultUIConstants.cornerOffset)
        switch symbolsCount {
        case 1:
            drawSymbol(areaToDrawSymbols.centerThird)
        case 2:
            drawSymbol(areaToDrawSymbols.firstThirdWithSixOffset)
            drawSymbol(areaToDrawSymbols.lastThirdWithSixOffset)

        case 3:
            drawSymbol(areaToDrawSymbols.firstThird)
            drawSymbol(areaToDrawSymbols.centerThird)
            drawSymbol(areaToDrawSymbols.lastThird)
        default: break
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isFaceUp {
            configureBorder()
        }
        else {
            layer.borderWidth = 0.0
        }
    }

    private func configureBorder() {
        backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
        layer.cornerRadius = cornerRadius
        layer.borderWidth = borderWidth
        layer.borderColor = borderColor.cgColor
    }
    
    private func drawSymbol(_ rect: CGRect) {
        let rect = rect.insetBy(dx: DefaultUIConstants.internalOffset, dy: DefaultUIConstants.internalOffset)
        let path: UIBezierPath
        switch symbol {
        case .oval:
            path = getOval(in: rect)
        case .squiggle:
            path = getSquiggle(in: rect)
        case .diamond:
            path = getDiamond(in: rect)
        }
       
        // we always set border
        color.setStroke()
        path.lineWidth = DefaultUIConstants.internalBorderWidth
        path.stroke()
        switch fill {
        case .unfilled:
           break
        case .solid:
            color.setFill()
            path.fill()
        case .striped:
            stripePath(path: path)
        }
    }
    
    private func stripePath(path: UIBezierPath){
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        path.addClip()
        let numberOfLines : Int = Int(self.bounds.width / DefaultUIConstants.betweenStripesDistance)
        let line = UIBezierPath()
        line.lineWidth = DefaultUIConstants.internalBorderWidth
        line.move(to: CGPoint(x: self.bounds.minX, y: self.bounds.minY))
        line.addLine(to: CGPoint(x: self.bounds.minX, y: self.bounds.maxY))
        for _ in 1...numberOfLines {
           let translation = CGAffineTransform(translationX: DefaultUIConstants.betweenStripesDistance, y: 0)
            line.apply(translation)
            line.stroke()
        }
        context?.restoreGState()
    }
    
    //MARK: shape drawing functions
    private func getOval(in rect: CGRect) -> UIBezierPath {
        let oval = UIBezierPath()
        let radius = rect.height / 2
        oval.addArc(withCenter: CGPoint(x: rect.maxX - radius,
                                        y: rect.minY + radius),
                                   radius: radius,
                               startAngle: -CGFloat.pi/2,
                                 endAngle: CGFloat.pi/2,
                                clockwise: true)
        oval.addLine(to: CGPoint(x: rect.minX + radius,
                                   y: rect.maxY))
        oval.addArc(withCenter: CGPoint(x: rect.minX + radius,
                                               y: rect.maxY - radius),
                                          radius: radius,
                                      startAngle: CGFloat.pi/2,
                                        endAngle: CGFloat.pi*3/2,
                                       clockwise: true)
        oval.close()
        return oval
    }
    
    private func getDiamond(in rect: CGRect) -> UIBezierPath {
        let diamond = UIBezierPath()
        diamond.move(to: CGPoint(x: rect.midX, y: rect.minY))
        diamond.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        diamond.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        diamond.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        diamond.close()
        return diamond
    }
    
    private func getSquiggle(in rect: CGRect) -> UIBezierPath {
        let partSquiggle = UIBezierPath()
        partSquiggle.move(to: CGPoint(x: rect.minX, y: rect.midY))
        partSquiggle.addCurve(to: CGPoint(x: rect.minX + rect.size.width*0.2, y: rect.minY + rect.height*0.15),
                              controlPoint1: CGPoint(x: rect.minX, y: rect.minY),
                              controlPoint2: CGPoint(x: rect.minX + rect.size.width*0.15, y: rect.minY + rect.height*0.1))
        
        partSquiggle.addCurve(to: CGPoint(x: rect.midX + rect.size.width*0.15, y: rect.midY - rect.height*0.15),
                                  controlPoint1: CGPoint(x: rect.minX + rect.size.width*0.25, y: rect.minY + rect.height*0.2),
        controlPoint2: CGPoint(x: rect.midX, y: rect.midY))
        partSquiggle.addCurve(to: CGPoint(x: rect.maxX, y: rect.midY),
                              controlPoint1: CGPoint(x: rect.midX + rect.size.width*0.35, y: rect.minY),
        controlPoint2: CGPoint(x: rect.maxX, y: rect.minY))
        let downSquiggle = UIBezierPath(cgPath: partSquiggle.cgPath)
        downSquiggle.apply(CGAffineTransform.identity.rotated(by: CGFloat.pi))
        downSquiggle.apply(CGAffineTransform.identity.translatedBy(
            x: self.bounds.width,
            y: self.bounds.height))
        partSquiggle.move(to: CGPoint(x: rect.minX, y: rect.midY))
        partSquiggle.append(downSquiggle)
        return partSquiggle
    }

    //MARK: animation
    func dealAndFlip(from point: CGPoint, width: CGFloat, height: CGFloat, with delay: TimeInterval) {
        let currentCenter = center
        let currentBounds = bounds
        center =  point
        alpha = 1.0
        bounds = CGRect(x: 0.0, y: 0.0, width: width, height: height)
        isFaceUp = false
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: DefaultUIConstants.dealDuration,
            delay: delay,
            options: [],
            animations:
                {
                    self.center = currentCenter
                    self.bounds = currentBounds
                },
            completion:
                { position in
                    UIView.transition(
                        with: self,
                        duration: DefaultUIConstants.flipAfterDealDuration,
                        options: [.transitionFlipFromLeft],
                        animations:
                            {
                                self.isFaceUp = true
                            }
                    )
                }
        )
    }
    
    var notifyCardIsDropped : (() -> Void)?
    
    func dropAndFaceDown(to point: CGPoint, width: CGFloat, height: CGFloat, with delay: TimeInterval) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: DefaultUIConstants.dropDuration,
            delay: delay,
            options: [],
            animations:
                {
                    self.center = point
                    self.bounds = CGRect(x: 0.0, y: 0.0, width: width, height: height)
                },
            completion:
                { position in
                    UIView.transition(
                        with: self,
                        duration: DefaultUIConstants.flipAfterDropDuration,
                        options: [.transitionFlipFromLeft],
                        animations:
                            {
                                self.isFaceUp = false
                            },
                        completion: {
                            finished in
                            self.notifyCardIsDropped?()
                        }
                    )
                }
        )
    }
    
}
    
    
private enum Fill: Int {
    case solid = 1
    case striped
    case unfilled
}

private enum Symbol: Int {
    case oval = 1
    case squiggle
    case diamond
}

private struct SetColor {
    static let green = #colorLiteral(red: 0, green: 0.5628422499, blue: 0.3188166618, alpha: 1)
    static let red = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
    static let purple = #colorLiteral(red: 0.5791940689, green: 0.1280144453, blue: 0.5726861358, alpha: 1)
}

private struct DefaultUIConstants {
    static let borderWidth : CGFloat = 2.5
    static let borderColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
    static let backgroundColor  = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    static let cornerOffset = 1.5
    static let internalOffset = 1.0
    static let internalBorderWidth = 0.5
    static let betweenStripesDistance = 4.0
    static let cornerRadius : CGFloat = 8.0
    static let chosenCardColor : UIColor = #colorLiteral(red: 0.05665164441, green: 0.2764216363, blue: 1, alpha: 1)
    static let matchedCardColor : UIColor = #colorLiteral(red: 0, green: 1, blue: 0, alpha: 1)
    static let mismatchedCardColor : UIColor = #colorLiteral(red: 1, green: 0, blue: 0, alpha: 1)
    static let dealDuration = 1.0
    static let dropDuration = 1.0
    static let flipAfterDealDuration = 0.25
    static let flipAfterDropDuration = 0.25
}

extension CGRect {
    var firstThird: CGRect {
        return CGRect(x: minX, y: minY, width: width, height: height/3)
    }
    var centerThird: CGRect {
        return CGRect(x: minX, y: minY + height/3, width: width, height: height/3)
    }
    var lastThird: CGRect {
        return CGRect(x: minX, y: minY + 2*height/3, width: width, height: height/3)
    }
    var firstThirdWithSixOffset: CGRect {
        return CGRect(x: minX, y: minY + height/6, width: width, height: height/3)
    }
    var lastThirdWithSixOffset: CGRect {
        return CGRect(x: minX, y: midY, width: width, height: height/3)
    }
}
