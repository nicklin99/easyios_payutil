//
//  JsonUtil.swift
//  json string to Dictionary, Dictionary to json string
//
//  Created by nick lin on 2018/4/3.
//  Copyright © 2018年 nick lin. All rights reserved.
//

import Foundation


class JsonUtil {
    
    /// convert json array string Data to swift Array<Dictionary<String,Any>>
    /*
     ### use api convert string to swift [AnyObject]
     JSONSerialization.jsonObject(with:options:)
     as! convert to [Dictionary<String,Any>]
     */
    /// - Parameter data: json array String
    /// - Returns: Array<Dictionary<String,Any>>
    static func parseArray(data:Data?) -> Array<Dictionary<String,Any>>? {
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
            
            let jsonArray = json as! [Dictionary<String,Any>]

            return jsonArray
        } catch {
            print("json parseArray fail")
        }
        
        return nil;
    }
    
    
    /// convert json object string Data to Dictionary,support more than one level
    ///
    /// - Parameter data: Data
    /// - Returns: Dictionary<String, Any>
    static func parseObject(data:Data?) -> Dictionary<String, Any> {
        do {
            let json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers)
            
            let jsonObject = json as! Dictionary<String,Any>
            
            return jsonObject
        } catch {
            print("json parseObject fail")
        }
        
        return Dictionary.init()
    }
    
    // ### convert json object string to Dictionary
    /* 
     example json = {"build":2018031931,"build_scope":"all","version":"1.0.9","vcode":9}
     */
    static func parseObject(json:String?) -> Dictionary<String, Any> {
        let data:Data? = json?.data(using: String.Encoding.utf8)
        return parseObject(data:data)
    }
    
    
    // return json string
    static func encode(_ data:[String:Any]) -> String? {
        do {
            let json:Data = try JSONSerialization.data(withJSONObject: data, options: .init(rawValue: 0))
            let str = String(data: json, encoding: String.Encoding.utf8)
            return str
        } catch  {
            return nil
        }
    }
    
}
