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
    var sphereNodes: MoireControl!
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.sceneView.delegate = self
        self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.autoenablesDefaultLighting = true
        self.sceneView.showsStatistics = true
        self.sceneView.scene = SCNScene()
        self.sphereNodes = MoireControl(number: 2, minRadius: 0.095, maxRadius: 0.1)
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
        
        self.sphereNodes.position = SCNVector3Make(planeAnchor.center.x, planeAnchor.center.y+0.3, planeAnchor.center.z)
        self.sphereNodes.lineWidth = 3.0
        self.sphereNodes.skipSize = 12.0
        self.sphereNodes.lineColor = UIColor.lightGray.cgColor
        
        for each_node in self.sphereNodes.nodes {
            each_node.velocity = fRandom(Min: -0.001, Max: 0.001)
            node.addChildNode(each_node)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
            self.sphereNodes.update()
    }

    private func fRandom(Min _Min : Float, Max _Max : Float)->Float {
        return ( Float(arc4random_uniform(UINT32_MAX)) / Float(UINT32_MAX) ) * (_Max - _Min) + _Min
    }
}

