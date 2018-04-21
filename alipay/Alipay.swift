//
//  Alipay.swift
//  支付宝支付
//
//  Created by nick lin on 2018/4/21.
//  Copyright © 2018年 nick lin. All rights reserved.
//

import Foundation

class Alipay: NSObject, BasePay {
    
    let scheme: String = AppConfig.APP_SCHEME
    
    func pay(payCode: String, callback: @escaping ( ( _ result:PayResult) -> Void ) ) -> Void {
        
        AlipaySDK.defaultService().payOrder(payCode, fromScheme: scheme) { (data:[AnyHashable : Any]?) in
            
            let payResult = AlipayResult(data as! [String:Any])
            
            if AppConfig.DEBUG_LOG {
                print("alipay.payOrder.result", data)
            }
            
            callback(payResult)
        }
    }
    
    func process(url:URL, callback: @escaping ( ( _ result:PayResult) -> Void )) -> Void {
        
        if url.host == "safepay" {
            
            // 支付跳转支付宝钱包进行支付，处理支付结果
            
            AlipaySDK.defaultService().processOrder(withPaymentResult: url, standbyCallback: { ( data: [AnyHashable : Any]?) in
                
                let payResult = AlipayResult(data as! [String:Any])
                
                if AppConfig.DEBUG_LOG {
                    print("alipay.urlcallback.result", data)
                }
                
                callback(payResult)
            })
        }
    }
    
    
}


class AlipayResult: PayResult {
    
    override init(_ body:[String:Any]?) {
        super.init(body)
        
        result = PayResult.state.fail
        
        guard let status = body?["resultStatus"] as? String else {
            return
        }
        
        // 返回数据处理错了 4 5次 !!!
        
        data = JsonUtil.parseObject(json: body?["result"] as? String)
        
        switch status {
        case "9000":
            result = PayResult.state.success
            break
        case "8000":
            result = PayResult.state.check
            break
        case "4000":
            result = PayResult.state.fail
            break
        case "5000":
            result = PayResult.state.fail
            break
        case "6001":
            result = PayResult.state.cancel
            break
        case "6002":
            result = PayResult.state.network
            break
        case "6004":
            result = PayResult.state.check
            break
        default:
            result = PayResult.state.fail
            break
        }
        
        // 返回数据处理错了 4 5次 !!!
        
        let memo = data["memo"] as? String
        
        if memo != nil {
            message = memo!
        }
    }
    
}
