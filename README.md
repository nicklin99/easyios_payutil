# -easyios_payutil

swift实现的支付宝支付和微信支付，一行代码调起

### 安装

1.`git clone https://github.com/nicklin99/-easyios_payutil.git` 拖进项目目录

2. 设置

设置header search path

`$(SRCROOT)/<项目名称>/pay/alipayAlipaySDK`
`$(SRCROOT)/<项目名称>/pay/wxpay`

link binary with libraries 添加

`libc++.tbd` `libz.tbd` `sqllite3.tbd`  `CoreMotion.framework`


3. project-bridging-Header.h 头文件导入sdk头文件

```
#import <AlipaySDK/AlipaySDK.h>

#import "WXApi.h"
#import "WXApiObject.h"
```

4. 支付结果url处理

```swift
//MARK: 处理接收的其他app发过来的url，成功处理返回true 失败返回false
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        
        // 支付url处理方法
        PayUtil.process(url: url, listener: SharedPayResultListener())
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        // 支付url处理方法
        PayUtil.process(url: url, listener: SharedPayResultListener())
        
        return true
    }
```

### 发起支付

```swift
// str 支付结果
func pay(_ type:String, payCode: String, callback: ( (str:String)->Void )) -> Void {
    PayUtil.pay(type: PayType(rawValue: type)!, payCode: payCode, listener: SharedPayResultListener()) { (String) in
        callback(String, false)
    }
}

// 支付宝支付

// payCode 是服务端返回的支付授权code string，主要包含了支付订单信息和授权调起支付信息
let payCode = "payCode"
pay("alipay", payCode: payCode) { (result) in
    // 支付结果处理
}

// 微信支付

// payCode 是服务端返回的支付授权code string，主要包含了支付订单信息和授权调起支付信息
let wxpayCode = "payCode"
pay("wx", payCode: wxpayCode) { (result) in
    // 支付结果处理
}
```

### 自定义支付结果返回

默认只有一个 SharedPayResultListener，自定义新建一个类继承，重写 success fail cancel,替换掉 SharedPayResultListener

```swift
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
```


## 目录结构

alipay
  -  AlipaySDK.bundle
  -  AlipaySDK.framework
  -  Alipay.swift

wxpay
- libWeChatSDK.a
- WXApi.h
- WXApiObject.h
- Wxpay.swift

PayUtil.swift
Json.swfit



