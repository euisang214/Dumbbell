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
    /// Calculates the average value of a given ArraySlice, BUT ALL VALUES ARE ABSOLUTE VALUED throughout the process to measure magnitude without + - signs
    ///
    /// - Parameter array: The array whose average value is desired
    /// - Returns: The average ABSOLUTE value of the array's contents as a Double
    private func average(array:ArraySlice<Double>) -> Double
    {
        var sum:Double = 0
        for element in array { sum += Double(abs(Int32(element)))}
        return sum/Double(array.count)
    }
    
    /// Determines whether a MicroBit has minimal movement; aka whether the user stopped moving the MicroBit/stopped workout
    ///
    /// - Parameters:
    ///   - dataHolder: The DataHolder to be examined whether it has minimal movement or not
    ///   - runCount: The number of times accerlerometer data has been passed to the iOS device
    /// - Returns: A Bool of whether the user stopped moving the MicroBit
    private func isPaused(dataHolder:inout DataHolder?, runCount:Int) -> Bool
    {
        let dThreeD = dataHolder!.dThreeD
        
        if dThreeD.count >= 200
        {
            let recentD = dThreeD.suffix(from: dThreeD.count-199)
            
            if average(array: recentD) < 0.75 && runCount-(dataHolder?.crossedRunCountLog.last! ?? 0) > 375 { return true }
        }
        return false
    }
    
    /// Determines whether BOTH MicroBits have minimal movement using the isPaused private function
    ///
    /// - Parameters:
    ///   - dataHolderOne: A DataHolder for a MicroBit
    ///   - dataHolderTwo: A DataHolder for a different MicroBit
    ///   - runCount: The number of times accerlerometer data has been passed to the iOS device
    /// - Returns: A Bool of whether the user stopped moving BOTH MicroBits
    public func isPaused(dataHolderOne:inout DataHolder?, dataHolderTwo:inout DataHolder?, runCount:Int) -> Bool
    {
        return isPaused(dataHolder: &dataHolderOne, runCount:runCount) && isPaused(dataHolder: &dataHolderTwo, runCount:runCount)
    }
}
