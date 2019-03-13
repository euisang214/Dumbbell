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
    private func threeDAcceleration(x:Int16, y:Int16, z:Int16) -> Int16
    {
        return Int16(pow( pow(Double(x), 2)+pow(Double(x), 2)+pow(Double(x), 2) , 1/3).rounded())
        //return 1
    }
    
    private func differenceOfMostRecentValues(_ array:[Int16]) -> Int16
    {
        return array.last! - array[array.endIndex-2]
    }
    
    //functions for masterRecordData()
    private func smoothen(record:[Int16]?, rawValue:Int16) -> Int16
    {
        if !(record?.isEmpty)!
        {
            return Int16(0.08*Double(rawValue)+(1-0.08)*Double((record?.last)!))
        }
        return rawValue
    }
    
    //Updates x, threeD, dX, and dThreeD arrays.
    //Called when new accelerometer data is provided.
    //Called in LiveAnalysis, compute()
    public func updateDataHolder(dataHolder: inout DataHolder, x:Int16, y:Int16, z:Int16)
    {
        let threeD = threeDAcceleration(x: x, y: y, z: z)
        
        dataHolder.x.append(smoothen(record: dataHolder.x, rawValue: x))
        dataHolder.threeD.append(smoothen(record: dataHolder.threeD, rawValue: threeD))
        
        if dataHolder.x.count >= 2
        {
            dataHolder.dX.append(smoothen(record: dataHolder.x, rawValue: differenceOfMostRecentValues(dataHolder.x)))
            dataHolder.dThreeD.append(smoothen(record: dataHolder.threeD, rawValue: differenceOfMostRecentValues(dataHolder.threeD)))
        }
    }
}
