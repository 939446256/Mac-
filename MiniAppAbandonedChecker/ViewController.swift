//
//  ViewController.swift
//  MiniAppAbandonedChecker
//
//  Created by 何嘉荣 on 2018/3/14.
//  Copyright © 2018年 A了个K. All rights reserved.
//

import Cocoa

enum ValueType {
    case get    //在JS中有Get方法
    case set    //在JS中有set方法
    case all    //在JS中有all方法
    case none   //在JS中有none方法
}

class ViewController: NSViewController, NSTextFieldDelegate, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var wxssTest: NSTextField!
    @IBOutlet weak var JSTest: NSTextField!
    @IBOutlet weak var wxmlText: NSTextField!
    
    
    
    @IBOutlet var resultTextView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        wxssTest.delegate = self
        
    }
    
    //WXML触发方法
    var allClickFun = [String]()
    
    //JS中没有使用的方法名
    var jsFuncRubbish = [String]()
    
    
    //所有相同代码
    var allSameAry = [String: [String:[String]]]()
    //所有属性名
    var allValue = [String]()
    
    //
    var allIsHaveGetAndSet = [String:ValueType]()
    //WXML应用样式
    var useWXSS = [String]()
    //WXSS选择样式
    var wxssStyle = [String]()
    
    //所有JS垃圾代码
    var allJSRubbish = [String]()
    //所有WXSS垃圾代码
    var allWXSSRubbish = [String]()
    //所有JS垃圾方法名
    var allFunctionRubbish = [String]()
    
    
    @IBAction func click(_ sender: NSButton) {
        //!!!-----数据处理的顺序不能改变------!!!!
        //JS数据处理
        getJSValue()
        //WXML数据处理
        getWXML()
        //WXSS数据处理
        getWXSSValue()
        
        //搜索垃圾代码
        //JS 搜索垃圾参数
        //            searchJSRubbish()
        //WXSS 搜索垃圾样式
        //            searchWXSSRubbish()
        
        //所有JS垃圾代码
        print("allJSRubbish",allJSRubbish)
        //所有WXSS垃圾代码
        print("allWXSSRubbish",allWXSSRubbish)
        //所有JS垃圾方法名
        print("allFunctionRubbish",allFunctionRubbish)
        let jsRubbish = try? JSONSerialization.data(withJSONObject: allJSRubbish, options: .prettyPrinted)
        let jsRub = String(data:jsRubbish!, encoding: String.Encoding.utf8)!
        
        let wxssRubbish = try? JSONSerialization.data(withJSONObject: allWXSSRubbish, options: .prettyPrinted)
        let wxssRub = String(data:wxssRubbish!, encoding: String.Encoding.utf8)!
        
        let functionRubbish = try? JSONSerialization.data(withJSONObject: allFunctionRubbish, options: .prettyPrinted)
        let functionRub = String(data:functionRubbish!, encoding: String.Encoding.utf8)!
        
        resultTextView.string = "JS废弃data属性:" + jsRub + "\n\n" + "JS废弃方法名:" + functionRub + "\n\n" + "WXSS废弃样式名:" + wxssRub
        
        //清空数据
        //WXML触发方法
        allClickFun = [String]()
        
        //JS中没有使用的方法名
        jsFuncRubbish = [String]()
        
        //所有相同代码
        allSameAry = [String: [String:[String]]]()
        //所有属性名
        allValue = [String]()
        
        //
        allIsHaveGetAndSet = [String:ValueType]()
        //WXML应用样式
        useWXSS = [String]()
        //WXSS选择样式
        wxssStyle = [String]()
        
        //所有JS垃圾代码
        allJSRubbish = [String]()
        //所有WXSS垃圾代码
        allWXSSRubbish = [String]()
        //所有JS垃圾方法名
        allFunctionRubbish = [String]()
    }
    
    func searchWXSSRubbish(){
        
        var saveWXSSAllData = [String]()
        
        for wxssName in wxssStyle{
            if wxssName == "" {continue};
            let wxssNames = wxssName.components(separatedBy: ".")
            for str in wxssNames{
                if str == "" {continue};
                //去除空格
                let strReplace = str.replacingOccurrences(of: " ", with: "")
                //判断是否带有>号  (cotent-item>label)
                if strReplace.contains(">"){
                    let strReplaceArrow = strReplace.components(separatedBy: ">")
                    if strReplaceArrow[1] != ""{
                        saveWXSSAllData.append(strReplaceArrow[1])
                    }
                    saveWXSSAllData.append(strReplaceArrow[0])
                }else{
                    saveWXSSAllData.append(strReplace)
                }
            }
        }
        
        //记录没有相同的WXSS名称
        var rubbishWXSS = [String]()
        
        for saveWXSSAllD in saveWXSSAllData{
            var isHave = false
            for useW in useWXSS{
                if saveWXSSAllD == useW{
                    isHave = true
                    break
                }
            }
            if isHave == false {
                rubbishWXSS.append(saveWXSSAllD)
            }
        }
        //            print("WXSS垃圾代码", rubbishWXSS)
        allWXSSRubbish = rubbishWXSS
    }
    
    func searchJSRubbish(){
        
        //垃圾代码处理
        for key in allValue{
            let js = allSameAry["JS"]
            let wxml = allSameAry["WXML"]
            let valueAry = js![key] ?? []
            allIsHaveGetAndSet[key] = ValueType.none
            
            var isGet = false
            var isSet = false
            
            for value in valueAry{
                if value.getStr(value.count - 1, end: value.count - 1) == ":"{
                    isSet = true
                }else{
                    isGet = true
                }
            }
            
            if (isGet){
                if (isSet){
                    allIsHaveGetAndSet[key] = .all
                }else{
                    allIsHaveGetAndSet[key] = .get
                }
            }else{
                if (isSet){
                    allIsHaveGetAndSet[key] = .set
                }else{
                    allIsHaveGetAndSet[key] = .none
                }
            }
            switchRubbish(wxmlSameList: wxml!,key: key)
        }
        
        //            print("垃圾代码",allJSRubbish)
    }
    
    
    //判断是否为垃圾代码
    func switchRubbish(wxmlSameList: [String : [String]],key: String){
        let type = allIsHaveGetAndSet[key]!
        //根据类型判断是否垃圾代码
        switch type{
        case .none:
            if wxmlSameList[key] == nil{
                allJSRubbish.append(key)
            }
        case .get:
            if wxmlSameList[key] == nil{
                allJSRubbish.append(key)
            }
        case .set:
            if wxmlSameList[key] == nil{
                allJSRubbish.append(key)
            }
        case .all: break
        }
    }
    
    //WXML数据处理
    func getWXML() {
        let strAry = wxmlText.stringValue.components(separatedBy: " ")
        var newCom = [String]()
        let saveAry = allValue
        
        //记录 跟缓存参数一样的
        var sameAry = [String:[String]]()
        
        var useWXSS = [String]()
        
        var isClassStart = false
        
        var wxmlClickName = [String]()
        
        //循环第一次(准备) 查找所有缓存参数
        for com in strAry{
            if com != "" && com != "//"{
                let replaceStr = com.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "\'", with: "")
                if replaceStr.contains("class="){
                    isClassStart = true
                }else if replaceStr.contains("=") || replaceStr.contains("<"){
                    isClassStart = false
                }
                
                if isClassStart {
                    let firstStr = replaceStr.components(separatedBy: ">")[0]
                    useWXSS.append(firstStr.replacingOccurrences(of: "class=", with: "").replacingOccurrences(of: ">", with: ""))
                }
                
                newCom.append(replaceStr)
            }
        }
        
        
        //第二次循环(筛选) 全文相同的项
        for saveStr in saveAry{
            for com in newCom{
                if com.contains(saveStr){
                    if isHaveChar(originStr: com, key: saveStr){
                        //判断该字典Value是否为空
                        if (sameAry[saveStr] == nil){
                            //为该字典的Value新建数组
                            sameAry[saveStr] = [String]()
                        }
                        
                        sameAry[saveStr]!.append(com)
                    }
                    
                }
            }
        }
        
        var functionRubbish = [String]()
        
        //第三次筛选使用的方法名称
        for jsFuncR in jsFuncRubbish{
            var isHave = false
            for wxmlUnit in newCom{
                if wxmlUnit.contains(jsFuncR){
                    isHave = true
                    break
                }
            }
            if isHave == false{
                functionRubbish.append(jsFuncR)
            }
        }
        
        //            print("数据分析", newCom)
        //            print("记录缓存", saveAry)
        //            print("记录相同缓存", sameAry)
        //
        //            print("WXML应用样式",useWXSS)
        self.useWXSS = useWXSS
        
        allSameAry["WXML"] = sameAry
        
        allClickFun = wxmlClickName
        
        self.allFunctionRubbish = functionRubbish
    }
    
    //JS数据处理
    func getJSValue() {
        let strAry = JSTest.stringValue.components(separatedBy: " ")
        var newCom = [String]()
        var isStartSave = false
        
        //缓存参数
        var saveAry = [String]()
        
        //记录 跟缓存参数一样的
        var sameAry = [String:[String]]()
        
        //循环第一次(准备) 查找所有缓存参数
        for com in strAry{
            if com != "" && com != "//"{
                let replaceStr = com.replacingOccurrences(of: "\n", with: "").replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "\'", with: "")
                //开始记录 缓存参数
                if isStartSave && replaceStr.contains(":"){
                    saveAry.append(replaceStr.replacingOccurrences(of: ":", with: ""))
                }
                
                if replaceStr == "data:"{
                    isStartSave = true
                }
                if replaceStr == "},"{
                    isStartSave = false
                }
                
                newCom.append(replaceStr)
            }
        }
        
        //第二次循环(筛选) 全文相同的项
        for saveStr in saveAry{
            for com in newCom{
                if com.contains(saveStr){
                    if isHaveChar(originStr: com, key: saveStr){
                        //判断该字典Value是否为空
                        if (sameAry[saveStr] == nil){
                            //为该字典的Value新建数组
                            sameAry[saveStr] = [String]()
                        }
                        
                        sameAry[saveStr]!.append(com)
                    }
                }
            }
        }
        
        var rubbish = [String]()
        //第三次循环(找出垃圾代码)
        for dic in sameAry{
            if dic.value.count == 1{
                rubbish.append(dic.key)
            }
        }
        
        var funcNames = [String]()
        //第四次循环 找出方法名
        for (i,key) in newCom.enumerated(){
            if key.contains("function"){
                if key.contains(":"){
                    let funcName = key.components(separatedBy: ":")[0]
                    if funcName != "onLoad" && funcName != "onReady" && funcName != "onShow" && funcName != "onHide" && funcName != "onUnload" && funcName != "onPullDownRefresh" && funcName != "onReachBottom" && funcName != "onShareAppMessage"{
                        funcNames.append(funcName)
                    }
                }else{
                    let funcName = newCom[i - 1].delectStr(":")
                    if funcName != "onLoad" && funcName != "onReady" && funcName != "onShow" && funcName != "onHide" && funcName != "onUnload" && funcName != "onPullDownRefresh" && funcName != "onReachBottom" && funcName != "onShareAppMessage"{
                        funcNames.append(funcName)
                    }
                }
                
            }
        }
        
        var jsFuncRubbish = [String]()
        for funcName in funcNames{
            var count = 0
            for key in newCom{
                if key.contains(funcName){
                    count += 1
                }
            }
            if count <= 1{
                jsFuncRubbish.append(funcName)
            }
        }
        
        //            print("方法名称",funcNames)
        //            print("方法名称垃圾",jsFuncRubbish)
        //            print("原始数据",newCom)
        //            print("记录缓存", saveAry)
        //            print("记录相同缓存", sameAry)
        //            print("垃圾代码", rubbish)
        //            allJSRubbish["JS"] = rubbish
        
        allSameAry["JS"] = sameAry
        allValue = saveAry
        self.jsFuncRubbish = jsFuncRubbish
    }
    
    
    //WXSS数据处理
    func getWXSSValue() {
        
        //缓存参数
        var saveAry = [String]()
        
        var isEnd = false
        
        var newStrAry = [String]()
        
        for char in wxssTest.stringValue.characters{
            
            if char == "{"{
                isEnd = false
                let newStr = newStrAry.joined(separator: "")
                //                    print("css字符串拼接",newStr)
                
                newStrAry = []
                saveAry.append(newStr.replacingOccurrences(of: "\n", with: ""))
            }
            else if isEnd{
                newStrAry.append(char.description)
            }
            
            if char == "}"{
                isEnd = true
            }
            
        }
        
        wxssStyle = saveAry
    }
    
    
    func isHaveChar(originStr: String, key: String)->Bool{
        let str = originStr
        let range = str.range(of: key)
        guard let startIndex = range?.lowerBound, let endIndex = range?.upperBound else{
            print("输入数据有误")
            return false
            
        }
        
        //判断单词开始位置
        if (startIndex.encodedOffset != 0){
            let lastCharIndex = startIndex.encodedOffset - 1
            let lastChar = str.getStr(lastCharIndex, end: lastCharIndex)
            if lastChar.isChar(){
                print("单词前一个字符是英文-\"",lastChar,"\"")
                return false
            }else{
                print("单词前一个字符不是英文-\"",lastChar,"\"")
            }
        }else{
            print("单词前没有字符")
        }
        
        //判断单词后一个字母是否英文
        if (endIndex.encodedOffset != str.count){
            let lastCharIndex = endIndex.encodedOffset
            let lastChar = str.getStr(lastCharIndex, end: lastCharIndex)
            if lastChar.isChar(){
                print("单词结束后一个字符是英文-\"",lastChar,"\"")
                return false
            }else{
                print("单词结束后一个字符不是英文-\"",lastChar,"\"")
            }
        }else{
            print("单词为最后字符")
        }
        return true
    }
    
    @IBAction func clickJSPaste(_ sender: Any) {
        
        let board = NSPasteboard.general
        let str = board.string(forType: NSPasteboard.PasteboardType.string)!
        JSTest.stringValue = str
    }
    
    @IBAction func clickWXMLPaste(_ sender: Any) {
        
        let board = NSPasteboard.general
        let str = board.string(forType: NSPasteboard.PasteboardType.string)!
        wxmlText.stringValue = str
    }
    
    @IBAction func clickWXSSPaste(_ sender: Any) {
        
        let board = NSPasteboard.general
        let str = board.string(forType: NSPasteboard.PasteboardType.string)!
        wxssTest.stringValue = str
    }
}



