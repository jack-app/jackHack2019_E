//
//  ViewController.swift
//  AQR2
//
//  Created by 中田　優樹 on 2019/05/04.
//  Copyright © 2019年 nakatayuki. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import Vision

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    var qrRequests = [VNRequest]()
    var detectedDataAnchor: ARAnchor?
    var processing = false
    var viewRect = CGRect()


    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        // Set ARSession
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()//SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // Set QRcod Reader
        startQrCodeDetection()
        
        //
        viewRect = sceneView.superview!.frame
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                if self.processing {
                    return
                }
                self.processing = true
                // Create a request handler using the captured image from the ARFrame
                let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: frame.capturedImage,
                                                                options: [:])
                // Process the request
                try imageRequestHandler.perform(self.qrRequests)
            } catch {
                
            }
        }
    }
    
    
    // タップしたときの判定
    
    @IBAction func didTap(_ sender: UITapGestureRecognizer) {
        let touchLocation = sender.location(in: sceneView)
        let hitResults = sceneView.hitTest(touchLocation, options: [:])
        
        // タップ時にオブジェクトがあれば実行
        if !hitResults.isEmpty {
            // Show statistics such as fps and timing information
            print(hitResults.first?.node.name)
            var urlStr = hitResults.first?.node.name!
            UIApplication.shared.open(URL(string: urlStr!)!, options: [:], completionHandler: nil)
            sceneView.showsStatistics = false
        }
            
            // タップ時にオブジェクトがなければ実行
        else {
            print("Empty")
            sceneView.showsStatistics = true
        }
    }
    

    // MARK: - ARSCNViewDelegate
    

    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        // If this is our anchor, create a node
        if self.detectedDataAnchor?.identifier == anchor.identifier {
            
            var node = SCNNode()
            if #available(iOS 12.0, *) {
                node = ARNodeMaker().makeFromPayload(from: anchor.name!)
            } else {
                // Fallback on earlier versions
                print("バージョンが古いよ")
            }
            node.transform = SCNMatrix4(anchor.transform)
            print("renderer")
            return node
            
        }
        return nil
    }


    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user

    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

extension ViewController {
    func startQrCodeDetection() {
        // Create a Barcode Detection Request
        let request = VNDetectBarcodesRequest(completionHandler: self.requestHandler)
        // Set it to recognize QR code only
        request.symbologies = [.QR]
        self.qrRequests = [request]
    }
    
    func requestHandler(request: VNRequest, error: Error?) {
        // Get the first result out of the results, if there are any
        if let results = request.results, let result = results.first as? VNBarcodeObservation {
            guard let payload = result.payloadStringValue else {return}
            // Get the bounding box for the bar code and find the center
            let rect = result.boundingBox
            // Get center  ↓ YとXが入れ替わっているのは画像が90度回転してrequestに渡されているから
            let center = CGPoint(x: rect.midY*viewRect.width, y: rect.midX*viewRect.height)
            
            DispatchQueue.main.async {
                self.hitTestQrCode(center: center, payload: payload)
                self.processing = false
            }
        } else {
            self.processing = false
        }
    }
    
    // QRコードのcenterから
    func hitTestQrCode(center: CGPoint, payload: String) {
        if let hitTestResults = sceneView?.hitTest(center, types: [.featurePoint]), let hitTestResult = hitTestResults.first {
            if let detectedDataAnchor = self.detectedDataAnchor, let node = self.sceneView.node(for: detectedDataAnchor) {
                // 二回目以降の検出
                let previousQrPosition = node.position
                node.transform = SCNMatrix4(hitTestResult.worldTransform)
            } else {
                // 一回目の検出
                // Create an anchor. The node will be created in delegate methods
                if #available(iOS 12.0, *) {
                    self.detectedDataAnchor = ARAnchor(name: payload, transform: hitTestResult.worldTransform)
                } else {
                    // Fallback on earlier versions
//                    throw NSError(domain: "バージョンが古いよ", code: -1, userInfo: nil)
                    print("バージョンが古い")
                }
                self.sceneView.session.add(anchor: self.detectedDataAnchor!)
                print("add anchor")
            }
        }
    }
    
    func testCheckPoint(point: CGPoint) {
        var testView = UIView(frame: CGRect(x: point.x, y: point.y, width: 20, height: 20))
        testView.backgroundColor = UIColor.red
        sceneView.addSubview(testView)
    }
    
    func testAddNode(vector :SCNVector3){
        let box = SCNBox(width: 0.05, height: 0.05, length: 0.05, chamferRadius: 0)
        let node = SCNNode(geometry: box)
        node.position = vector
        sceneView.scene.rootNode.addChildNode(node)
    }
}
