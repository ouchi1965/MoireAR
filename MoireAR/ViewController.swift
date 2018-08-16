//
//  ViewController.swift
//  MoireAR
//
//  Created by 大内克哉 on 2018/03/05.
//  Copyright © 2018年 大内克哉. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    let configuration = ARWorldTrackingConfiguration()
    var bodyNodes: [MoireControl] = []
    
    let moireNumber: Int = 3
    let lineWidth:[CGFloat] = [5.0, 20.0, 5.0] // line width for each Node
    let rotVelicity: [Float] = [0.0, 0.001, 0.002] //rotation velocity for each Node
    
    
    @IBOutlet weak var NodeNumber: UISegmentedControl!
    @IBAction func nodeChanged(_ sender: UISegmentedControl) {
        for member in self.bodyNodes {
            member.isHidden = true
        }
        self.bodyNodes[sender.selectedSegmentIndex].isHidden = false
        self.VisibleNumber.value = Double(self.bodyNodes[sender.selectedSegmentIndex].visibleNumber)
        
        var hue:CGFloat = 0.0
        var sat: CGFloat = 0.0
        var bri: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        UIColor(cgColor: self.bodyNodes[sender.selectedSegmentIndex].nodes[Int(self.VisibleNumber.value)-1].color).getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
        self.HueValue.value = Float(hue)
        self.SaturationValue.value = Float(sat)
        
    }
    
    @IBOutlet weak var VisibleNumber: UIStepper!
    @IBAction func visibleChanged(_ sender: UIStepper) {
        for member in self.bodyNodes {
            if member.isHidden == false {
                member.visibleNumber = Int(sender.value)
            }
        }
        
        var hue:CGFloat = 0.0
        var sat: CGFloat = 0.0
        var bri: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        UIColor(cgColor: self.bodyNodes[self.NodeNumber.selectedSegmentIndex].nodes[Int(sender.value)-1].color).getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alpha)
        self.HueValue.value = Float(hue)
        self.SaturationValue.value = Float(sat)
    }
    
    @IBOutlet weak var SettingWindow: UIView!
    @IBAction func settingView(_ sender: UIBarButtonItem) {
        self.SettingWindow.isHidden = !self.SettingWindow.isHidden
    }
    
    @IBOutlet weak var HueValue: UISlider!
    @IBAction func hueChaned(_ sender: UISlider) {
        self.bodyNodes[self.NodeNumber.selectedSegmentIndex].nodes[Int(self.VisibleNumber.value)-1].color = UIColor(hue: CGFloat(sender.value), saturation: CGFloat(self.SaturationValue.value), brightness: 0.5, alpha: 1.0).cgColor
    }

    @IBOutlet weak var SaturationValue: UISlider!
    @IBAction func saturationChanged(_ sender: UISlider) {
        self.bodyNodes[self.NodeNumber.selectedSegmentIndex].nodes[Int(self.VisibleNumber.value)-1].color = UIColor(hue: CGFloat(self.HueValue.value), saturation: CGFloat(sender.value), brightness: 0.5, alpha: 1.0).cgColor
    }

    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.sceneView.delegate = self
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.showsStatistics = true
        self.sceneView.scene = SCNScene()
        
        self.bodyNodes.append(MoireControl(number: self.moireNumber, minRadius: 0.09, maxRadius: 0.1))
        self.bodyNodes.append(MoireControl(number: self.moireNumber, minLength: 0.19, maxLength: 0.2, chamRadius: 0.02))
        self.bodyNodes.append(MoireControl(number: self.moireNumber, ringRadius: 0.1, minPipeRadius: 0.036, maxPipeRadius: 0.04))
        
        for member in self.bodyNodes {
            member.isHidden = true
        }
        self.bodyNodes[self.NodeNumber.selectedSegmentIndex].isHidden = false
        self.VisibleNumber.value = Double(self.bodyNodes[self.NodeNumber.selectedSegmentIndex].visibleNumber)
        
        self.VisibleNumber.maximumValue = Double(self.moireNumber)
        self.VisibleNumber.value = Double(self.moireNumber)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.configuration.planeDetection = .horizontal
        self.sceneView.session.run(self.configuration)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else {
            return
        }
        
        DispatchQueue.main.sync {
//            for member in self.bodyNodes {
//                member.lineColor = UIColor(hue: CGFloat(self.HueValue.value), saturation: CGFloat(self.SaturationValue.value), brightness: 0.5, alpha: 1.0).cgColor
//            }
            
            for num in 0..<self.bodyNodes.count {
                self.bodyNodes[num].lineColor = UIColor(hue: CGFloat(self.HueValue.value), saturation: CGFloat(self.SaturationValue.value), brightness: 0.5, alpha: 1.0).cgColor
                self.bodyNodes[num].position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.y+0.3, planeAnchor.center.z)
                self.bodyNodes[num].lineWidth = lineWidth[num]
                self.bodyNodes[num].skipSize = 2.0*lineWidth[num]
                for n in 0..<self.moireNumber {
                    self.bodyNodes[num].nodes[n].velocity = self.rotVelicity[n]
                }
            }

        }

        for member in self.bodyNodes {
            for each_node in member.nodes {
                node.addChildNode(each_node)
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        for member in self.bodyNodes {
            member.update()
        }
    }

    private func fRandom(Min _Min : Float, Max _Max : Float)->Float {
        return ( Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX) ) * (_Max - _Min) + _Min
    }
}

