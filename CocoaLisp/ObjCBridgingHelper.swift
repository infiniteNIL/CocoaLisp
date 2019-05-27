//
//  ObjCBridgingHelper.swift
//  CocoaLisp
//
//  Created by Rod Schmidt on 5/24/19.
//  Copyright © 2019 infiniteNIL. All rights reserved.
//

import Foundation

protocol BridgedToCocoa {
    var objCClass: AnyClass { get }
}

extension DataType: BridgedToCocoa {
    var objCClass: AnyClass { return NSObject.self }
}

func toObjectiveC(_ ast: DataType) throws -> AnyObject {
    switch ast {
    case let s as CocoaLispString:
        return s.value as NSString

    case let n as Number:
        return n.value as NSNumber

    default:
        throw CocoaLispError.invalidOperation
    }
}

func objCInstanceToDataType(_ object: Any) throws -> DataType {
    switch object {
    case let s as NSString:
        return CocoaLispString(s as String)

    case let n as CUnsignedLongLong:
        return Number(Int(n))

    case let c as CChar:
        guard c == 0 || c == 1 else { fatalError("c is not a 0 or 1") }
        return c == 1 ? Boolean.True : Boolean.False

    case let n as NSNumber:
        return Number(n.intValue)

    case let c as Character:
        return CocoaLispString(String(c))

    default:
        throw CocoaLispError.invalidOperation
    }
}
