//
//  DriverState.swift
//  GysbKit
//
//  Created by omochimetaru on 2017/11/10.
//

import Foundation

extension Driver.State {
    public func resultString(index: Int, stage: Driver.Stage) -> String {
        switch stage {
        case .parse:
            return entries[index].template!.print()
        case .compile:
            return entries[index].code!
        case .render:
            return entries[index].rendered!
        }
    }
    
    public func targetName(index: Int) -> String {
        return "render\(index)"
    }
    
    public func buildWorkIndexForEntry(index: Int) -> Int? {
        return buildWorks.firstIndex { work in
            work.entryIndices.contains(index)
        }
    }
    
    public var printResult: Bool {
        return option.writeOnSame == false
    }
}

extension Driver.BuildWork {
//    var 
}

