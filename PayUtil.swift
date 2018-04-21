//
//  PayUtil.swift
//  微信支付、支付宝支付
//
//  Created by nick lin on 2018/4/21.
//  Copyright © 2018年 nick lin. All rights reserved.
//

import Foundation

class PayUtil: NSObject {
    
    /// 调起支付app发起支付
    ///
    /// - Parameters:
    ///   - type: 支付app类型 PayType.alipay 支付宝支付 PayType.wxpay 微信支付
    ///   - payCode: 服务端返回的支付授权code，主要包含了支付订单信息和授权调起支付信息
    ///   - listener: 回调处理支付结果，支付结果有可能是 支付成功、取消、错误，根据返回结果做相对应的处理
    ///   - callback: 回调处理,传递给 listener 处理
    static func pay( type: PayType, payCode: String, listener: BasePayResultListener, callback: ( (_ str:String) -> Void )? = nil ) -> Void {
        
        if AppConfig.DEBUG_LOG {
            print("PayUtil.pay.type",type)
        }
        
        switch type {
        case .alipay:
            Alipay().pay(payCode: payCode, callback: { ( payResult: PayResult) in
                listener.handle(payResult, callback: callback)
            })
            break
        case .wxpay:
            Wxpay.shared.pay(payCode: payCode, callback: { (payResult: PayResult) in
                listener.handle(payResult, callback: callback)
            })
            break
        default:
            break
        }
    }
    
    static func process(url:URL, listener: BasePayResultListener, callback: ( (_ str:String) -> Void )? = nil) -> Void {
        
        if AppConfig.DEBUG_LOG {
            print("PayUtil.process.url",url)
        }
        
        guard let host = url.host else {
            return
        }
        
        let hosttype = PayURLType(rawValue: host)
        
        if hosttype == nil {
            return
        }
        
        switch hosttype! {
        case .alipay:
            Alipay().process(url: url, callback: { ( payResult: PayResult) in
                listener.handle(payResult, callback: callback)
            })
            break
        default:
            // 微信异步的callback被存起来了
            Wxpay.shared.process(url: url)
            
            break
        }
    }
}


//MARK: 支付方式必须实现的协议

protocol BasePay {
    
    var scheme: String { get }
    
    /// 各支付方式需实现
    ///
    /// - Parameters:
    ///   - payCode: 服务端返回的支付授权code，主要包含了支付订单信息和授权调起支付信息
    ///   - callback: 回调一定要消耗掉，有同步调用
    func pay(payCode: String, callback: @escaping ( ( _ result:PayResult) -> Void ))
}

enum PayType: String {
    
    case alipay
    case wxpay
    case wx
}

enum PayURLType: String {
    case alipay = "safepay"
    case wxpay = "wxpay"
}


//MARK: 支付结果必须实现的协议

protocol BasePayResultListener {
    
    /// listener 再次加工处理支付结果，处理完触发 callback 回调告知结果
    ///
    /// - Parameters:
    ///   - payResult: 支付结果
    ///   - callback: 发起支付时传入的回调, 非 listener
    /// - Returns: return value description
    func handle(_ payResult:PayResult, callback: ( (_ str:String) -> Void )? )
    
    func success(_ callback: ( (_ str:String) -> Void )?)
    
    func cancel(_ callback: ( (_ str:String) -> Void )?)
    
    func fail(_ error: String, callback: ( (_ str:String) -> Void )?)
}

protocol BasePayResultProtocol {
    
    var result: PayResult.state! { get set }
}

class PayResult: NSObject, BasePayResultProtocol {

    enum state:String {
        case success
        case check
        case fail
        case cancel
        case network
    }
    
    var result: PayResult.state!
    
    var message: String!

    var data: [String:Any]!
    
    init(_ result:[String:Any]?) {
        super.init()
        if AppConfig.DEBUG_LOG {
            print("payresult",result as Any)
        }
        data = result
    }
}


//MARK: PayResultListner 是默认的支付结果返回处理业务逻辑，一般需要自定义

/*
 PayUtil.pay( type: PayType, payCode: String, listener: BasePayResultListener )
 */

class SharedPayResultListener: BasePayResultListener {
    
    func fail(_ error:String,callback: ((String) -> Void)?) {
        let alert = ToastAlertController()
        alert.title = error
        alert.start()
        
        let str = JsonUtil.encode(["result":PayResult.state.fail.rawValue,"state":false])
        
        if callback != nil {
            callback!(str!)
        }
    }
    
    func cancel(_ callback: ((String) -> Void)?) {
        let alert = ToastAlertController()
        alert.title = "取消支付"
        alert.start()
        
        let str = JsonUtil.encode(["result":PayResult.state.cancel.rawValue,"state":false])
        
        if callback != nil {
            callback!(str!)
        }
    }
    
    func success(_ callback: ((String) -> Void)?) {
        let alert = ToastAlertController()
        alert.title = "支付处理中"
        alert.start()
        
        let str = JsonUtil.encode(["result":PayResult.state.success.rawValue,"state":true])
        
        if callback != nil {
            callback!(str!)
        }
    }
    
    
    func handle(_ payResult: PayResult, callback: ( (_ str:String) -> Void )? ) {
        switch payResult.result! {
        case .success:
            success(callback)
            break
        case .cancel:
            cancel(callback)
            break
        case .check:
            fail("check" + payResult.message, callback: callback)
            break
        case .fail:
            fail("fail" + payResult.message, callback: callback)
            break
        case .network:
            fail("networkerr" + payResult.message, callback: callback)
            break
        default:
            fail("networkerr" + payResult.message, callback: callback)
            break
        }
    }
}

class TestSharedPayResultListener: SharedPayResultListener {
    override func success(_ callback: ((String) -> Void)?) {
        // 自定义
    }
    
    override func fail(_ error: String, callback: ((String) -> Void)?) {
        // 自定义
    }
    
    override func cancel(_ callback: ((String) -> Void)?) {
        // 自定义
    }
}


