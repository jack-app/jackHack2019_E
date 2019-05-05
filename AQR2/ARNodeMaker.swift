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
        // 画像のurlを取得する
        var imageURL:URL? = nil
        // HTMLをパースして画像のURLを代入
        let url = URL(string: payload)!
        let req = NSMutableURLRequest(url: url)
        req.httpMethod = "GET"
        let myHttpSession = HttpClientImpl()
        let (htmlData, _, _) = myHttpSession.execute(request: req as URLRequest)
        if htmlData != nil {
            // 受け取ったデータに対する処理
            let htmlStr = String(data: htmlData as! Data, encoding: .utf8)
            imageURL = HTMLPaser().getOgImageURL(htmlStr: htmlStr!)
        }
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
        node.name = payload
        return node
    }

}
