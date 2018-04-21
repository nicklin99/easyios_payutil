//
//  Wxpay.swift
//  微信支付
//
//  Created by nick lin on 2018/4/21.
//  Copyright © 2018年 nick lin. All rights reserved.
//

import Foundation


class Wxpay: NSObject, BasePay, WXApiDelegate {
    
    let scheme: String = AppConfig.WXAPP_SCHEME
    
    private static var instance: Wxpay!

    static var shared: Wxpay {
        if Wxpay.instance == nil {
            Wxpay.instance = Wxpay()
        }
        
        return Wxpay.instance
    }
    
    
    var callback: ( ( _ result:PayResult) -> Void )!
    
    /// 发起微信支付
    ///
    /// - Parameters:
    ///   - payCode: 服务端返回的微信支付授权code
    ///   - callback: 回调处理微信支付结果
    func pay(payCode: String, callback: @escaping ( ( _ result:PayResult) -> Void ) ) -> Void {
        if !is_installed() || !is_support() {
            let alert = ToastAlertController()
            
            let msg = "未安装微信"
            alert.title = msg
            alert.start()
            
            let payResult = WxpayResult(nil)
            payResult.result = PayResult.state.fail
            payResult.message = msg
            callback(payResult)
            return
        }
        
        let req = PayReq()
        
        let payCodeDict = JsonUtil.parseObject(json: payCode)
        
        if AppConfig.DEBUG_LOG {
            print("wxpay.payCode", payCode)
            print("wxpay.payCodeDict", payCodeDict)
        }
    
        req.partnerId		= payCodeDict["partnerid"] as! String
        req.prepayId		= payCodeDict["prepayid"]  as! String
        req.nonceStr		= payCodeDict["noncestr"]  as! String
        req.timeStamp		= UInt32(payCodeDict["timestamp"]  as! String)!
        req.package         = payCodeDict["package"]  as! String
        req.sign			= payCodeDict["sign"]  as! String
        
        let result = WXApi.send(req)
        
        if AppConfig.DEBUG_LOG {
            print("wxpay.send.result", result)
        }
        
        // 调起不成功，提示失败
        if !result {
            let payResult = WxpayResult(nil)
            payResult.result = PayResult.state.fail
            payResult.message = "调起失败"
            callback(payResult)
            return
        }
        
        // 存起来 callback
        self.callback = callback
        
        // func onReq(_ req: BaseReq!) 处理支付结果
    }
    
    
    func process(url:URL) -> Void {
        //TODO: 需要判断是不是微信支付
        WXApi.handleOpen(url, delegate: self)
    }
    
    func onReq(_ req: BaseReq!) {
        
    }
    
    // 处理支付结果
    func onResp(_ resp: BaseResp!) {
        
        if resp is PayResp {
            if AppConfig.DEBUG_LOG {
                print("wxpay.callback.start.resp", resp)
            }
            
            let payResult = PayResult(nil)
            
//            0	成功	展示成功页面
//            -1	错误	可能的原因：签名错误、未注册APPID、项目设置APPID不正确、注册的APPID与设置的不匹配、其他异常等。
//            -2	用户取消	无需处理。发生场景：用户不支付了，点击取消，返回APP。
            switch resp.errCode {
            case 0:
                payResult.result = PayResult.state.success
                break
            case -1:
                payResult.result = PayResult.state.fail
                payResult.message = resp.errStr
                break
            case -2:
                payResult.result = PayResult.state.cancel
                break
            default:
                payResult.result = PayResult.state.fail
                break
            }
            
            callback(payResult)
            
            callback = nil
            // 是否可以释放？
            
            if AppConfig.DEBUG_LOG {
                print("wxpay.callback.end.result", payResult)
            }
        }
    }
    
    func is_installed() -> Bool {
        return WXApi.isWXAppInstalled()
    }
    
    func is_support() -> Bool {
        return WXApi.isWXAppSupport()
    }
}


class WxpayResult: PayResult {
    
    
}


