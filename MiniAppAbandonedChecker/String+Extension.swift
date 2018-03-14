//
//  String+Extension.swift
//  aaa
//
//  Created by 何嘉荣 on 2018/3/12.
//  Copyright © 2018年 何嘉荣. All rights reserved.
//

import Cocoa

extension String{
    func getStr(_ begin: Int , end : Int) -> String{
        
        let range = Range.init(self.characters.index(self.startIndex, offsetBy: begin)..<self.characters.index(self.startIndex, offsetBy: end + 1))
        return String(self[range])
    }
    
    //是否英文字母
    func isChar()->Bool{
        let priceNum = "^[A-Za-z]*$"
        let regextestcm = NSPredicate(format: "SELF MATCHES %@",priceNum)
        if regextestcm.evaluate(with: self) {
            return true
        }else{
            return false
        }
    }
    
    //删除某字符串后的
    func delectStr(_ keyWord : String) -> String{
        let range = self.range(of: keyWord)
        guard let location = range?.lowerBound else {return self}
        return self.substring(to: location)
    }
}
