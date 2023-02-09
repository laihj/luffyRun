//
//  LuffyDataTransformer.swift
//  luffyRun
//
//  Created by laihj on 2023/2/9.
//

import Foundation


@objc(LuffyValueTransformer)
final class LuffyValueTransformer: NSSecureUnarchiveFromDataTransformer {
    
    // 定义静态属性name，方便使用
    static let name = NSValueTransformerName(rawValue: String(describing: LuffyValueTransformer.self))
    
    // 重写allowedTopLevelClasses，确保UIColor在允许的类列表中
    override static var allowedTopLevelClasses: [AnyClass] {
        return [NSArray.self, ZonePace.self, CumulativeQuantity.self,DiscreateHKQuanty.self,RouteNode.self,NSUUID.self] // NSArray.self 也要加上，不然不能在数组中使用！
    }
    
    // 定义Transformer转换器注册方法
    public static func register() {
        let transformer = LuffyValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
