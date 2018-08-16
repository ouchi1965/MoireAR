//
//  MoireSphere.swift
//  MoireAR
//
//  Created by 大内克哉 on 2018/03/05.
//  Copyright © 2018年 大内克哉. All rights reserved.
//

import Foundation
import SceneKit

struct InitParameter {
    var className: String
    var parameters: [String: CGFloat]
}

class MoireControl {
    private var _number: Int!
    private var _visibleNumber: Int!
    private var moireObjects: [MoireObject] = []
    private var _lineWidth: CGFloat = 2.0
    private var _skipSize: CGFloat = 10.0
    private var _lineColor: CGColor = UIColor.gray.cgColor
    private var _position: SCNVector3 = SCNVector3Make(0.0, 0.0, 0.0)
    private var _isHidden: Bool = false
    private let textureSize = CGSize(width: 2048.0, height: 2048.0)
    private var initParm: InitParameter!

    public var number: Int {
        get {
            return self._number
        }

        set (num) {
            self.moireObjects.removeAll()
            switch self.initParm.className {
            case "Sphere":
                self.setSphere(number: num, minRadius: self.initParm.parameters["minRadius"]!, maxRadius: self.initParm.parameters["maxRadius"]!)
            case "Box":
                self.setBox(number: num, minLength: self.initParm.parameters["minLength"]!, maxLength: self.initParm.parameters["maxLength"]!, chamRadius: self.initParm.parameters["chamRadius"]!)
            case "Torus":
                self.setTorus(number: num, ringRadius: self.initParm.parameters["ringRadius"]!, minPipeRadius: self.initParm.parameters["minPipeRadius"]!, maxPipeRadius: self.initParm.parameters["maxPipeRadius"]!)
            default:
                print("fail to reset")
            }
        }
    }

    public var visibleNumber: Int {
        get {
            return self._visibleNumber
        }
        
        set (num) {
            self._visibleNumber = num
            
            if (self._isHidden == false) {
                for mem in 0..<self._visibleNumber {
                    self.moireObjects[mem].isHidden = false
                }
                
                for mem in self._visibleNumber..<self._number {
                    self.moireObjects[mem].isHidden = true
                }
            }
        }
    }
    
    public var nodes: [MoireObject] {
        get {
            return self.moireObjects
        }
    }
    
    public var position: SCNVector3 {
        get {
            return self._position
        }
        
        set (val) {
            for each in self.moireObjects {
                each.position = val
            }
        }
    }
    
    public var lineWidth: CGFloat {
        get {
            return self._lineWidth
        }
        
        set (val) {
            self._lineWidth = val
            for each in self.moireObjects {
                each.lineWidth = val
            }
        }
    }
    
    public var skipSize: CGFloat {
        get {
            return self._skipSize
        }
        
        set (val) {
            self._skipSize = val
            for each in self.moireObjects {
                each.skipSize = val
            }
        }
    }
    
    public var lineColor: CGColor {
        get {
            return self._lineColor
        }
        
        set (col) {
            self._lineColor = col
            for each in self.moireObjects {
                each.color = col
            }
        }
    }
    
    public var isHidden: Bool {
        get {
            return self._isHidden
        }
        
        set (val) {
            self._isHidden = val
            if (val == true) {
                for each in self.moireObjects {
                    each.isHidden = true
                }
            } else {
                for num in 0..<self._visibleNumber {
                    self.moireObjects[num].isHidden = false
                }
                
                for num in self._visibleNumber..<self._number {
                    self.moireObjects[num].isHidden = true
                }
            }
        }
    }

    
    init(number: Int, minRadius: CGFloat, maxRadius: CGFloat) {
        self.initParm = InitParameter(className: "Sphere", parameters: ["minRadius": minRadius, "maxRadius": maxRadius])
        self.setSphere(number: number, minRadius: minRadius, maxRadius: maxRadius)
    }
    
    init(number: Int, minLength: CGFloat, maxLength: CGFloat, chamRadius: CGFloat) {
        self.initParm = InitParameter(className: "Box", parameters: ["minLength": minLength, "maxLength": maxLength, "chamRadius": chamRadius])
        self.setBox(number: number, minLength: minLength, maxLength: maxLength, chamRadius: chamRadius)
    }
    
    init(number: Int, ringRadius: CGFloat, minPipeRadius: CGFloat, maxPipeRadius: CGFloat) {
        self.initParm = InitParameter(className: "Torus", parameters: ["ringRadius": ringRadius, "minPipeRadius": minPipeRadius, "maxPipeRadius": maxPipeRadius])
        self.setTorus(number: number, ringRadius: ringRadius, minPipeRadius: minPipeRadius, maxPipeRadius: maxPipeRadius)
    }
    
    public func update() {
        for member in self.moireObjects {
            member.update()
        }
    }
    
    
    private func setSphere(number: Int, minRadius: CGFloat, maxRadius: CGFloat) {
        if (number<2) {
            self._number = 1
            let rad = (minRadius + maxRadius)/2.0
            self.moireObjects.append(MoireObject(radius: rad, textSize: self.textureSize ,skipSize: self._skipSize, lineWidth: self._lineWidth, color: self._lineColor))
        } else {
            self._number = number
            let delta = (maxRadius - minRadius)/CGFloat(self._number-1)
            for num in 0..<self._number {
                let radius = minRadius + delta*CGFloat(num)
                self.moireObjects.append(MoireObject(radius: radius, textSize: self.textureSize ,skipSize: self._skipSize, lineWidth: self._lineWidth, color: self._lineColor))
            }
        }
        self._visibleNumber = number
        
    }
    
    private func setBox(number: Int, minLength: CGFloat, maxLength: CGFloat, chamRadius: CGFloat) {
        if (number<2) {
            self._number = 1
            let length = (minLength + maxLength)/2.0
            self.moireObjects.append(MoireObject(width: length, height: length, length: length, chamferRadius: chamRadius, textSize: self.textureSize, skipSize: self._skipSize, lineWidth: self._lineWidth, color: self._lineColor))
        } else {
            self._number = number
            let delta = (maxLength - minLength)/CGFloat(self._number-1)
            for num in 0..<self._number {
                let length = minLength + delta*CGFloat(num)
                self.moireObjects.append(MoireObject(width: length, height: length, length: length, chamferRadius: chamRadius, textSize: self.textureSize, skipSize: self._skipSize, lineWidth: self._lineWidth, color: self._lineColor))
            }
        }
            self._visibleNumber = number
    }
    
    private func setTorus(number: Int, ringRadius: CGFloat, minPipeRadius: CGFloat, maxPipeRadius: CGFloat) {
        if (number<2) {
            self._number = 1
            let radius = (minPipeRadius + maxPipeRadius)/2.0
            self.moireObjects.append( MoireObject(ringRadius: ringRadius, pipeRadius: radius, textSize: self.textureSize, skipSize: self._skipSize, lineWidth: self._lineWidth, color: self._lineColor))
        } else {
            self._number = number
            let delta = (maxPipeRadius - minPipeRadius)/CGFloat(self._number-1)
            for num in 0..<self._number {
                let radius = minPipeRadius + delta*CGFloat(num)
                self.moireObjects.append( MoireObject(ringRadius: ringRadius, pipeRadius: radius, textSize: self.textureSize, skipSize: self._skipSize, lineWidth: self._lineWidth, color: self._lineColor))
            }
        }
        self._visibleNumber = number
    }
}


class MoireObject: SCNNode {
    private var material: SCNMaterial!
    private var rotAngle: Float = 0.0
    private var rotVelocity: Float = 0.0
    private var skip_size: CGFloat!
    private var line_color: CGColor!
    private var line_width: CGFloat!
    private var texture_size: CGSize!
    
    public var velocity: Float {
        get {
            return self.rotVelocity
        }
        
        set (val) {
            self.rotVelocity = val
        }
    }
    
    public var color: CGColor {
        get {
            return self.line_color
        }
        
        set (col) {
            self.line_color = col
            self.material.diffuse.contents = updateMaterial(skip: self.skip_size, linewidth: self.line_width, color: col)
        }
    }
    
    public var lineWidth: CGFloat {
        get {
            return self.line_width
        }
        
        set (val) {
            self.line_width = val
            self.material.diffuse.contents = updateMaterial(skip: self.skip_size, linewidth: val, color: self.line_color)
        }
    }
    
    public var skipSize: CGFloat {
        get {
            return self.skip_size
        }
        
        set (val) {
            self.skip_size = val
            self.material.diffuse.contents = updateMaterial(skip: val, linewidth: self.line_width, color: self.line_color)
        }
    }
    
    init(radius: CGFloat, textSize: CGSize, skipSize: CGFloat, lineWidth: CGFloat, color: CGColor) {
        super.init()

        let sphere = SCNSphere(radius: radius)
        sphere.segmentCount = 64
//        sphere.isGeodesic = true
        self.initParameters(geometry: sphere, textSize: textSize, skipSize: skipSize, lineWidth: lineWidth, color: color)
    }
    
    init(width: CGFloat, height: CGFloat, length: CGFloat, chamferRadius: CGFloat, textSize: CGSize, skipSize: CGFloat, lineWidth: CGFloat, color: CGColor) {
        super.init()
        
        let box = SCNBox(width: width, height: height, length: length, chamferRadius: chamferRadius)
        self.initParameters(geometry: box, textSize: textSize, skipSize: skipSize, lineWidth: lineWidth, color: color)
    }
    
    init(ringRadius: CGFloat, pipeRadius: CGFloat, textSize: CGSize, skipSize: CGFloat, lineWidth: CGFloat, color: CGColor) {
        super.init()
        
        let torus = SCNTorus(ringRadius: ringRadius, pipeRadius: pipeRadius)
        torus.ringSegmentCount = 96
        torus.pipeSegmentCount = 48
        self.initParameters(geometry: torus, textSize: textSize, skipSize: skipSize, lineWidth: lineWidth, color: color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initParameters(geometry: SCNSphere(radius: 0.1), textSize: CGSize(width: 2048, height: 2048), skipSize: 10.0, lineWidth: 1.0, color: UIColor.white.cgColor)
    }
    
    private func initParameters(geometry: SCNGeometry, textSize: CGSize, skipSize: CGFloat, lineWidth: CGFloat, color: CGColor) {
        self.geometry = geometry
        self.position = SCNVector3Make(0.0, 0.0, 0.0)
        
        self.material = SCNMaterial()
        self.texture_size = textSize
        self.skip_size = skipSize
        self.line_width = lineWidth
        self.line_color = color
        self.material.diffuse.contents = updateMaterial(skip: skipSize, linewidth: lineWidth, color: self.line_color)
        self.material.specular.contents = UIColor.white
        
        self.geometry?.materials = [self.material]
    }
    
    private func updateMaterial(skip: CGFloat, linewidth: CGFloat, color: CGColor)->CGImage {
        UIGraphicsBeginImageContext(self.texture_size)
        let context = UIGraphicsGetCurrentContext()!
        
        context.setFillColor(red: 0, green: 0, blue: 0, alpha: 0)
        context.fill(CGRect(x: 0, y: 0, width: self.texture_size.width, height: self.texture_size.height) )
        
        context.setLineWidth(linewidth)
        context.setStrokeColor(color)

        var xpos: CGFloat = 0.0
        while (xpos < self.texture_size.width) {
            context.move(to: CGPoint(x: xpos, y: 0.0))
            context.addLine(to: CGPoint(x: xpos, y: self.texture_size.height))
            xpos += skip
        }
        
        context.strokePath()
        
        let img:CGImage = context.makeImage()!
        UIGraphicsEndImageContext()
        
        return img
    }
    
    public func update() {
        self.rotation = SCNVector4(0.0, 1.0, 0.0, self.rotAngle)
        self.rotAngle += self.rotVelocity
    }
}
