//
//  ViewController.swift
//  ARDicee
//
//  Created by Tey Ti Siang on 30/3/20.
//  Copyright © 2020 Tey Ti Siang. All rights reserved.
//
import AVFoundation
import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    var diceArray = [SCNNode]()
    
    var soundPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        //turn off debug in real app
        //sceneView.debugOptions = .showFeaturePoints
        
   
        
//        let sphere = SCNSphere(radius: 0.2)
//        
//        let material = SCNMaterial()
//        material.diffuse.contents = UIImage(named: "art.scnassets/8k_earth_daymap.jpg")
//        
//        sphere.materials = [material]
//        
//        let node = SCNNode()
//        node.position = SCNVector3(x: 0, y: 0.5, z: -0.5)
//        node.geometry = sphere
//        sceneView.scene.rootNode.addChildNode(node)
//        sceneView.autoenablesDefaultLighting = true
     
        // Show statistics such as fps and timing information
//        sceneView.showsStatistics = true
//
//        // Create a new scene
//        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
       // sceneView.scene = scene
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK: - Motion methods
    @IBAction func refreshButtonTapped(_ sender: Any) {
        playFeedback()
        rollAll()
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        if !diceArray.isEmpty {
            for dice in diceArray {
                dice.removeFromParentNode()
            }
        }
    }
    
    override func motionBegan(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        print("motion detected")
        playFeedback()
        rollAll()
    }
    
    func playFeedback() {
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
         let path = Bundle.main.path(forResource: "dice.wav", ofType:nil)!
         let url = URL(fileURLWithPath: path)

         do {
             soundPlayer = try AVAudioPlayer(contentsOf: url)
             soundPlayer?.play()
         } catch {
             // couldn't load file :(
         }
    }

    //MARK: - Dice rendering methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            let result = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = result.first {
                print(hitResult)
                addDice(atLocation: hitResult)
            }
        }
    }
    
    func addDice(atLocation location : ARHitTestResult) {
        //let scene = SCNScene(named: "art.scnassets/banana.scn")!
        let scene = SCNScene(named: "art.scnassets/diceCollada.scn")!
          
          if let node = scene.rootNode.childNode(withName: "Dice", recursively: true) {
              
              node.position = SCNVector3(
                  x: location.worldTransform.columns.3.x,
                  y: location.worldTransform.columns.3.y + node.boundingSphere.radius,
                  z: location.worldTransform.columns.3.z)
              
              sceneView.scene.rootNode.addChildNode(node)
              sceneView.autoenablesDefaultLighting = true
              
              diceArray.append(node)
              roll(diceNode: node)
          }
    }
    
    func roll(diceNode: SCNNode) {
         //Roll the dice
          let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
          let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2)
          
          diceNode.runAction(SCNAction.rotateBy(
              x: CGFloat(randomX) * 5 ,
              y: 0,
              z: CGFloat(randomZ) * 5,
              duration: 0.3))
     }
    
    func rollAll() {
        if !diceArray.isEmpty {
            for dice in diceArray {
                roll(diceNode: dice)
            }
        }
    }
    
    //MARK: - ARSCNViewDelegateMethods
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("Plane detected......")
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}
        
        let planeNode = createPlaneNode(withPlaneAnchor: planeAnchor)
            
        //Do not want to show grid in real app
        //node.addChildNode(planeNode)
    }
    
    func createPlaneNode(withPlaneAnchor planeAnchor : ARPlaneAnchor) -> SCNNode {
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
                
        let gridMaterial = SCNMaterial()
                 
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
         
        plane.materials = [gridMaterial]

        let planeNode = SCNNode()
        
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        planeNode.geometry = plane
        
        return planeNode
    }
    


}
