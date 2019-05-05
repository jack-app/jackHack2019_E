//
//  File.swift
//  AQR2
//
//  Created by 中田　優樹 on 2019/05/05.
//  Copyright © 2019 nakatayuki. All rights reserved.
//

import Foundation

class HTMLPaser {
    func getOgImageURL(htmlStr :String) -> URL {
        let pattern = "^<meta.+(\"|')((http|https)://.+\\.(png|jpg|jpeg))(\"|').*>$"
        let imageUrl = htmlStr.capture(pattern: pattern, group: 1)
        return URL(string: "https://www.hackingwithswift.com/apple-icon-57x57.png")!
    }
}

extension String {
    
    /// 正規表現でキャプチャした文字列を抽出する
    ///
    /// - Parameters:
    ///   - pattern: 正規表現
    ///   - group: 抽出するグループ番号(>=1)
    /// - Returns: 抽出した文字列
    func capture(pattern: String, group: Int) -> String? {
        let result = capture(pattern: pattern, group: [group])
        return result.isEmpty ? nil : result[0]
    }
    
    /// 正規表現でキャプチャした文字列を抽出する
    ///
    /// - Parameters:
    ///   - pattern: 正規表現
    ///   - group: 抽出するグループ番号(>=1)の配列
    /// - Returns: 抽出した文字列の配列
    func capture(pattern: String, group: [Int]) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return []
        }
        
        guard let matched = regex.firstMatch(in: self, range: NSRange(location: 0, length: self.count)) else {
            return []
        }
        
        return group.map { group -> String in
            return (self as NSString).substring(with: matched.range(at: group))
        }
    }
}
