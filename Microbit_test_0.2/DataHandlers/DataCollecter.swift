//
//  Calculation.swift
//  Microbit_test_0.1
//
//  Created by Ethan Shin on 20/12/2018.
//  Copyright © 2018 Peter Wallen. All rights reserved.
//

import Foundation

class Calculation
{
    /// Calculates three dimensional acceleration
    ///
    /// - Parameters:
    ///   - x: The x acceleration
    ///   - y: The y acceleration
    ///   - z: The z acceleration
    /// - Returns: The three dimensional acceleration
    private func threeDAcceleration(x:Int16, y:Int16, z:Int16) -> Double
    {
        return pow( pow(Double(x), 2)+pow(Double(x), 2)+pow(Double(x), 2) , 1/3).rounded()
    }
    
    
    /// Calculates the difference between the two most recent values in an array
    ///
    /// - Parameter array: The array whose two most recent two values will be compared
    /// - Returns: The difference between the two most recent values in Double
    private func differenceOfMostRecentValues(_ array:[Double]) -> Double
    {
        return Double(array.last! - array[array.endIndex-2])
    }
    
    /// Smoothens data to remove irregularities
    ///
    /// - Parameters:
    ///   - record: An array containing the previous values
    ///   - rawValue: The raw, unsmoothened value
    ///   - smoothenLevel: The degree at which the smoothening should be done; 0 is the highest, 1 is the lowest.
    /// - Returns: The value to be inputted inside the 'record'
    private func smoothen(record:[Double]?, rawValue:Double, _ smoothenLevel:Double) -> Double
    {
        if !(record?.isEmpty)!
        {
            let equationPart_1 = ((smoothenLevel)*Double(rawValue))
            let equationPart_2 = ((1.0-smoothenLevel)*Double((record?.last)!))
            
            return (equationPart_1 + equationPart_2)
        }
        return rawValue
    }

    /// Updates x, threeD, dX, and dThreeD arrays, called when new accelerometer data is provided.
    ///
    /// - Parameters:
    ///   - dataHolder: The DataHolder to be updated
    ///   - x: The x acceleration
    ///   - y: The y acceleration
    ///   - z: The z acceleration
    public func updateDataHolder(dataHolder: inout DataHolder, x:Int16, y:Int16, z:Int16)
    {
        let threeD = threeDAcceleration(x: x, y: y, z: z)
    
        dataHolder.x.append(smoothen(record: dataHolder.x, rawValue: Double(x), 0.15))
        dataHolder.threeD.append(smoothen(record: dataHolder.threeD, rawValue: threeD, 0.01))
        
        if dataHolder.x.count > 2
        {
            dataHolder.dX.append(smoothen(record: dataHolder.dX, rawValue: differenceOfMostRecentValues(dataHolder.x), 0.01))
            dataHolder.dThreeD.append(smoothen(record: dataHolder.dThreeD, rawValue: differenceOfMostRecentValues(dataHolder.threeD), 0.01))
        }
        else if dataHolder.x.count == 2
        {
            dataHolder.dX.append(Double(dataHolder.x.last! - dataHolder.x.first!))
        }
    }
}
