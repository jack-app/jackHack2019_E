//
//  ARObjectMaker.swift
//  AQR2
//
//  Created by 中田　優樹 on 2019/05/05.
//  Copyright © 2019 nakatayuki. All rights reserved.
//

import Foundation
import ARKit

class ARNodeMaker{
    func makeFromPayload(from payload: String) -> SCNNode {
        if payload.contains("_aqr-obj") || payload.contains("_aqr-message") {
            return makeOriginNode(from: payload)
        } else {
            return makeMetaImgNode(from: payload)
        }
    }
    
    func makeOriginNode(from urlStr: String) -> SCNNode{
        let paramsStr = urlStr.components(separatedBy: "?")[1]
        let paramStrs = paramsStr.components(separatedBy: "&")
        var params = Dictionary<String , String>()
        paramStrs.forEach({ (str) in
            let key = str.components(separatedBy: "=")[0]
            let value = str.components(separatedBy: "=")[1]
            params.updateValue(value, forKey: key)
        })
        
        if (params["_aqr-obj"] != nil) {
            var node = SCNNode()
            let nodes = SCNScene(named: "art.scnassets/" + params["_aqr-obj"]! + ".scn")!.rootNode.childNodes
            let child = nodes.first!
            child.scale = SCNVector3Make(0.001, 0.001, 0.001)
            node.addChildNode(child)
            for c in node.childNodes
            {
                c.scale = SCNVector3Make(0.0001, 0.0001, 0.0001)
            }
//            node.scale =
            return node
        } else if(params["_aqr-message"] != nil) {
            return SCNNode(geometry: SCNSphere(radius: 0.01))
        } else {
            return SCNNode(geometry: SCNSphere(radius: 0.01))
        }
    }
    
    func makeMetaImgNode(from urlStr: String) -> SCNNode {
        // 画像のurlを取得する
        var imageURL:URL? = nil
        // HTMLをパースして画像のURLを代入
        let url = URL(string: urlStr)!
        let req = NSMutableURLRequest(url: url)
        req.httpMethod = "GET"
        let myHttpSession = HttpClientImpl()
        let (htmlData, _, _) = myHttpSession.execute(request: req as URLRequest)
        // 受け取ったデータに対する処理
        let htmlStr = String(data: htmlData as! Data, encoding: .utf8)
        imageURL = HTMLPaser().getOgImageURL(htmlStr: htmlStr!)
        // 画像のイメージを取得
        let imgReq = NSMutableURLRequest(url: imageURL!)
        req.httpMethod = "POST"
        let imageHttpSession = HttpClientImpl()
        let (imageData, _, _) = imageHttpSession.execute(request: imgReq as URLRequest)
        let image = UIImage(data: imageData as! Data)
        
        var geometry = SCNBox(width: 0.05, height: 0.05, length: 0.1, chamferRadius: 0)
        geometry.firstMaterial?.diffuse.contents = image
        geometry.firstMaterial?.lightingModel = .constant
        var node = SCNNode(geometry: geometry)
        node.name = urlStr
        return node
    }

}
