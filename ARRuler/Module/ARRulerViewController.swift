//
//  ViewController.swift
//  ARRuler
//
//  Created by Binaya on 06/11/2021.
//

import UIKit
import SceneKit
import ARKit

class ARRulerViewController: UIViewController {

    //MARK: - @IBOutlets

    @IBOutlet var sceneView: ARSCNView!
    
    //MARK: - Instance properties

    private var dotNodesArray = [SCNNode]()
    private var textNode = SCNNode()
    
    //MARK: - Lifecycle methods

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupConfiguration()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        pauseSceneViewSession()
    }

    //MARK: - Instance methods
    
    private func setup() {
        setupSceneView()
    }
    
    private func setupSceneView() {
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.autoenablesDefaultLighting = true
    }
    
    private func setupConfiguration() {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    private func pauseSceneViewSession() {
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // If 2 red dot nodes are already present when user clicks for the third time, clear the first 2 nodes:
        if dotNodesArray.count >= 2 {
            dotNodesArray.forEach { $0.removeFromParentNode() }
            dotNodesArray.removeAll()
        }
        
        if let touchLocation = touches.first?.location(in: sceneView) {
            
            let hitTestResults = sceneView.hitTest(touchLocation, types: .featurePoint)
            if let hitTestResult = hitTestResults.first {
                addADot(at: hitTestResult)
            }
            
        }
        
    }
    
    private func addADot(at hitTestResult: ARHitTestResult) {
        
        let redDot = SCNSphere(radius: 0.005)
        
        let redDotMaterial = SCNMaterial()
        redDotMaterial.diffuse.contents = UIColor.red
        redDot.materials = [redDotMaterial]
        
        let redDotNode = SCNNode(geometry: redDot)
        redDotNode.position = SCNVector3(hitTestResult.worldTransform.columns.3.x,
                                         hitTestResult.worldTransform.columns.3.y,
                                         hitTestResult.worldTransform.columns.3.z)

        sceneView.scene.rootNode.addChildNode(redDotNode)
        dotNodesArray.append(redDotNode)
        
        if dotNodesArray.count >= 2 {
            calculateDistance()
        }
        
    }
    
    private func calculateDistance() {
        
        let startingPoint = dotNodesArray[0]
        let endingPoint = dotNodesArray[1]
        
        let a = endingPoint.position.x - startingPoint.position.x
        let b = endingPoint.position.y - startingPoint.position.y
        let c = endingPoint.position.z - startingPoint.position.z
        
        let distanceBetweenPoints = sqrt(pow(a, 2) + pow(b, 2) + pow(c, 2))
        let absoluteDistanceAsString = String(format: "%.2f", abs(distanceBetweenPoints) * 100)
        
        // Using absolute value because we don't want negative values.
        let distanceString = "Distance: " + absoluteDistanceAsString + "cm"
        
        displayDistanceTextGeomtry(with: distanceString, atPosition: endingPoint.position)
        
    }
    
    private func displayDistanceTextGeomtry(with distance: String, atPosition position: SCNVector3) {
        
        // Remove previous textNode when we want to update new distance's text:
        textNode.removeFromParentNode()
        
        // extrusionDepth - The depth of our 3D text
        
        let textGeometry = SCNText(string: distance, extrusionDepth: 1.0)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.red // Since it will only have one material.
        
        textNode = SCNNode(geometry: textGeometry)
        
        // Placing it a bit above the end point.
        textNode.position = SCNVector3(position.x - 0.01, position.y + 0.01, position.z)
        
        // Scaling the text so that it's 1% of it's original size set by ARKit.
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
    
}

//MARK: - ARSCNViewDelegate extension

extension ARRulerViewController: ARSCNViewDelegate {
    
}
