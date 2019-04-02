//
//  DetectPause.swift
//  Microbit_test_0.1
//
//  Created by Ethan Shin on 25/12/2018.
//  Copyright © 2018 Peter Wallen. All rights reserved.
//

import Foundation

class DetectPause
{
    private func average(array:ArraySlice<Double>) -> Double
    {
        var sum:Double = 0
        for element in array { sum += Double(abs(Int32(element)))}
        return sum/Double(array.count)
    }
    
    public func isPaused(dataHolder:inout DataHolder?, runCount:Int) -> Bool
    {
        let dThreeD = dataHolder!.dThreeD
        
        if dThreeD.count >= 200
        {
            let recentD = dThreeD.suffix(from: dThreeD.count-199)
            
            if average(array: recentD) < 0.75 && runCount-(dataHolder?.crossedRunCountLog.last! ?? 0) > 375 { return true }
        }
        return false
    }
    
    public func isPaused(dataHolderOne:inout DataHolder?, dataHolderTwo:inout DataHolder?, runCount:Int) -> Bool
    {
        return isPaused(dataHolder: &dataHolderOne, runCount:runCount) && isPaused(dataHolder: &dataHolderTwo, runCount:runCount)
    }
}
