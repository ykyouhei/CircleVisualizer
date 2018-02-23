//
//  CircleVisualizer.swift
//  CircleVisualizer
//
//  Created by kyo__hei on 2017/12/17.
//  Copyright © 2017年 kyo__hei. All rights reserved.
//

import UIKit

@IBDesignable public class CircleVisualizer: UIView {
    
    // MARK: - Types

    public enum LineCap: Int {
        case butt
        case round
        case square
        
        var lineCap: String {
            switch self {
            case .butt:
                return kCALineCapButt
            case .round:
                return kCALineCapRound
            case .square:
                return kCALineCapSquare
            }
        }
    }
    
    internal typealias Line = (layer: CAShapeLayer, value: CGFloat)
    
    
    // MARK: - Properties

    @IBInspectable public var numberOfLines: Int = 64 {
        didSet {
            lines = makeLineLayers()
        }
    }
    
    @IBInspectable public var maximumLength: CGFloat = 30 {
        didSet {
            lines.enumerated().forEach {
                $0.element.layer.path = linePath(position: $0.offset, value: $0.element.value).cgPath
            }
        }
    }

    @IBInspectable public var lineWidth: CGFloat = 3 {
        didSet {
            lines.forEach { $0.layer.lineWidth = lineWidth }
        }
    }
    
    @IBInspectable public var gradationColor0: UIColor = #colorLiteral(red: 1, green: 0.337254902, blue: 0.5764705882, alpha: 1) {
        didSet {
            lines.enumerated().forEach {
                $0.element.layer.strokeColor = color(potision: $0.offset).cgColor
            }
        }
    }

    @IBInspectable public var gradationColor1: UIColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1) {
        didSet {
            lines.enumerated().forEach {
                $0.element.layer.strokeColor = color(potision: $0.offset).cgColor
            }
        }
    }
    
    @IBInspectable public var gradationColor2: UIColor = #colorLiteral(red: 0.4784313725, green: 1, blue: 0.9921568627, alpha: 1) {
        didSet {
            lines.enumerated().forEach {
                $0.element.layer.strokeColor = color(potision: $0.offset).cgColor
            }
        }
    }
    
    @IBInspectable public var gradationColor3: UIColor = #colorLiteral(red: 0.5764705882, green: 0.4117647059, blue: 0.768627451, alpha: 1) {
        didSet {
            lines.enumerated().forEach {
                $0.element.layer.strokeColor = color(potision: $0.offset).cgColor
            }
        }
    }
    
    @IBInspectable public private(set) var lineCapRaw: Int = LineCap.butt.rawValue {
        didSet {
            let lineCap = LineCap(rawValue: lineCapRaw) ?? .butt
            lines.forEach {
                $0.layer.lineCap = lineCap.lineCap
            }
        }
    }
    
    public var lineCap: LineCap {
        get {
            return LineCap(rawValue: lineCapRaw) ?? .butt
        }
        set {
            lineCapRaw = lineCap.rawValue
        }
    }
    
    public var values: [CGFloat] {
        return lines.map { $0.value }
    }

    private var lines = [Line]() {
        willSet {
            lines.forEach { $0.layer.removeFromSuperlayer() }
        }
        didSet {
            lines.forEach { layer.addSublayer($0.layer) }
        }
    }

    
    // MARK: - Initializer
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.lines = makeLineLayers()
        self.lines.forEach { layer.addSublayer($0.layer) }
    }
    
    
    // MARK: - Override
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        lines.enumerated().forEach {
            $0.element.layer.path = self.linePath(position: $0.offset, value: $0.element.value).cgPath
        }
    }
    

    // MARK: - Functions
    
    public func set(color: UIColor,
                    at position: Int,
                    animated: Bool,
                    duration: TimeInterval = 0.2) {
        let lineLayer = lines[position].layer
        let animationKey = "strokeColorAnimation"
        
        let completion = {
            lineLayer.strokeColor = color.cgColor
            lineLayer.removeAnimation(forKey: animationKey)
        }
        
        guard animated else {
            completion()
            return
        }
        
        CATransaction.setCompletionBlock(completion)
        CATransaction.begin()
        
        let animation = CABasicAnimation(keyPath: "strokeColor")
        animation.duration = CFTimeInterval(duration)
        animation.fromValue = lineLayer.strokeColor
        animation.toValue = color.cgColor
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        lineLayer.add(animation, forKey: animationKey)
        
        CATransaction.commit()
    }

    public func set(value: CGFloat,
                    at position: Int,
                    animated: Bool,
                    duration: TimeInterval = 0.2) {
        let lineLayer = lines[position].layer
        let endPath = linePath(position: position, value: value)
        let animationKey = "pathAnimation"
        let completion = {
            lineLayer.path = endPath.cgPath
            lineLayer.removeAnimation(forKey: animationKey)
        }
        
        self.lines[position].value = value
        
        guard animated else {
            completion()
            return
       }
        
        CATransaction.setCompletionBlock(completion)
        CATransaction.begin()
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.duration = CFTimeInterval(duration)
        animation.fromValue = lineLayer.path
        animation.toValue = endPath.cgPath
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        lineLayer.add(animation, forKey: animationKey)
        
        CATransaction.commit()
    }
    
    public func performBatchUpdates(_ updates: (() -> Swift.Void),
                                    completion: (() -> Swift.Void)? = nil) {
        CATransaction.setCompletionBlock(completion)
        
        CATransaction.begin()
        updates()
        CATransaction.commit()
    }

    // MARK: - Private
    
    private func makeLineLayers() -> [Line] {
        return (0..<self.numberOfLines).map {
            let value = CGFloat(1.0)
            let path = self.linePath(position: $0, value: value)
            let layer = CAShapeLayer()
            
            layer.path = path.cgPath
            layer.strokeColor = UIColor.red.cgColor
            layer.lineWidth = self.lineWidth
            layer.strokeColor = self.color(potision: $0).cgColor
            layer.lineCap = kCALineCapRound
            
            return Line(layer: layer, value: value)
        }
    }
    
    private func linePath(position: Int, value: CGFloat) -> UIBezierPath {
        let length = maximumLength*value
        let angle = 360/CGFloat(self.numberOfLines)*CGFloat(position) - 90
        
        let radiusX = bounds.width/2 - maximumLength
        let radiusY = bounds.height/2 - maximumLength
        
        let midx = bounds.midX
        let midy = bounds.midY
        let radian = angle*CGFloat.pi/180
        
        let x0 = cos(radian)*radiusX + midx
        let y0 = (sin(radian)*radiusY + midy)
        let x1 = cos(radian)*(radiusX+length) + midx
        let y1 = (sin(radian)*(radiusY+length) + midy)
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: x0, y: y0))
        path.addLine(to: CGPoint(x: x1, y: y1))

        return path
    }
    
    private func color(potision: Int) -> UIColor {
        let i = potision + 1
        var r0: CGFloat = 0
        var g0: CGFloat = 0
        var b0: CGFloat = 0
        var a0: CGFloat = 0
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        var rate: CGFloat = 0
        
        switch i {
        case let x where x < numberOfLines/4:
            gradationColor0.getRed(&r0, green: &g0, blue: &b0, alpha: &a0)
            gradationColor1.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
            rate = CGFloat(i)/(CGFloat(numberOfLines)/4)
        case let x where x < numberOfLines/4*2:
            gradationColor1.getRed(&r0, green: &g0, blue: &b0, alpha: &a0)
            gradationColor2.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
            rate = CGFloat(i-numberOfLines/4)/(CGFloat(numberOfLines)/4)
        case let x where x < numberOfLines/4*3:
            gradationColor2.getRed(&r0, green: &g0, blue: &b0, alpha: &a0)
            gradationColor3.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
            rate = CGFloat(i-(numberOfLines/4)*2)/(CGFloat(numberOfLines)/4)
        default:
            gradationColor3.getRed(&r0, green: &g0, blue: &b0, alpha: &a0)
            gradationColor0.getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
            rate = CGFloat(i-(numberOfLines/4)*3)/(CGFloat(numberOfLines)/4)
        }
        
        return UIColor(
            red: r0+(r1-r0)*rate,
            green: g0+(g1-g0)*rate,
            blue: b0+(b1-b0)*rate,
            alpha: 1.0
        )
    }
    
}
