//
//  Encoder.swift
//  CBORSwift
//
//  Created by Hassan Shahbazi on 5/2/18.
//  Copyright © 2018 Hassan Shahbazi. All rights reserved.
//

import Foundation

class Encoder: NSObject {
    class func prepareByteArray(major: MajorType, measure: Int) -> [UInt8] {
        var encoded = MajorTypes(major).get().bytes
        
        var rawBytes = [UInt8]()
        prepareHeaderByteArray(bytes: &rawBytes, measure: measure)
        rawBytes.append(contentsOf: measure.decimal_binary)
        encoded.append(contentsOf: [UInt8](rawBytes[3..<rawBytes.count]))
        
        return encoded
    }
    
    private class func prepareHeaderByteArray(bytes: inout [UInt8], measure: Int) {
        let upperBound: UInt64 = 4294967295
        
        if measure >= 0 && measure <= 23 {}
        else if measure >= 24 && measure <= 255 { bytes = 24.decimal_binary }
        else if measure >= 256 && measure <= 65535 { bytes = 25.decimal_binary }
        else if measure >= 65536 && measure <= upperBound { bytes = 26.decimal_binary }
    }
    
    class func getIncludedEncodings(item: AnyObject) -> String {
        var data = ""
        data.append(item.encode())
        return data
    }
}

extension NSObject: Any {
    @objc internal func encode() -> String {
        return self.encode()
    }
}

extension NSNumber {
    @objc override func encode() -> String {
        let major: MajorType = (self.intValue < 0) ? .major1 : .major0
        let measure = (self.intValue < 0) ? (self.intValue * -1) - 1 : self.intValue

        let encodedArray = Encoder.prepareByteArray(major: major, measure: measure)
        return Data(bytes: encodedArray).binary_decimal.hex
    }
}

extension NSString {
    @objc override func encode() -> String {
        let encodedArray = Encoder.prepareByteArray(major: .major3, measure: self.length)
        let headerData  = Data(bytes: encodedArray).binary_decimal.hex
        let strData     = Data(bytes: self.ascii_bytes).hex
        
        return headerData.appending(strData)
    }
}

extension NSArray {
    @objc override func encode() -> String {
        let encodedArray = Encoder.prepareByteArray(major: .major4, measure: self.count)
        return (Data(bytes: encodedArray).binary_decimal.hex).appending(getItemsEncoding())
    }
    
    private func getItemsEncoding() -> String {
        var data = ""
        for item in self {
            data.append(Encoder.getIncludedEncodings(item: item as AnyObject))
        }
        return data
    }
}

extension NSDictionary {
    @objc override func encode() -> String {
        let encodedArray = Encoder.prepareByteArray(major: .major5, measure: self.allKeys.count)
        return (Data(bytes: encodedArray).binary_decimal.hex).appending(getItemsEncoding())
    }
    
    private func getItemsEncoding() -> String {
        var data = ""
        var key_value = [String:String]()
        for (key, value) in self {
            key_value[Encoder.getIncludedEncodings(item: key as AnyObject)] = Encoder.getIncludedEncodings(item: value as AnyObject)
        }
        
        let dic = key_value.valueKeySorted
        for item in dic {
            data.append(item.0)
            data.append(item.1)
        }
        return data
    }
}

extension NSData {
    @objc override func encode() -> String {
        let data = self as Data
        let encodedArray = Encoder.prepareByteArray(major: .major2, measure: data.count)
        return Data(bytes: encodedArray).binary_decimal.hex
    }
}
