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
    private func smoothen(record:[Int16]?, rawValue:Int16, _ smoothenLevel:Double) -> Int16
    {
        if !(record?.isEmpty)!
        {
            let equationPart_1 = Int16((smoothenLevel)*Double(rawValue))
            let equationPart_2 = Int16((1.0-smoothenLevel)*Double((record?.last)!))
            
            return Int16(equationPart_1 + equationPart_2)
        }
        return rawValue
    }
    
    //Updates x, threeD, dX, and dThreeD arrays.
    //Called when new accelerometer data is provided.
    //Called in LiveAnalysis, compute()
    public func updateDataHolder(dataHolder: inout DataHolder, x:Int16, y:Int16, z:Int16)
    {
        let threeD = threeDAcceleration(x: x, y: y, z: z)
    
        dataHolder.x.append(smoothen(record: dataHolder.x, rawValue: x, 0.1))
        /*dataHolder.x2.append(smoothen(record: dataHolder.x, rawValue: x, 0.25))
        dataHolder.x3.append(smoothen(record: dataHolder.x, rawValue: x, 0.675))
        dataHolder.x4.append(smoothen(record: dataHolder.x, rawValue: x, 0.9))
         */
        dataHolder.threeD.append(smoothen(record: dataHolder.threeD, rawValue: threeD, 0.92))
        
        if dataHolder.x.count >= 2
        {
            dataHolder.dX.append(smoothen(record: dataHolder.x, rawValue: differenceOfMostRecentValues(dataHolder.x), 0.225))
            /*
            dataHolder.dX_1.append(smoothen(record: dataHolder.x, rawValue: differenceOfMostRecentValues(dataHolder.x), 0.225))
            dataHolder.dX2_1.append(smoothen(record: dataHolder.x, rawValue: differenceOfMostRecentValues(dataHolder.x), 0.45))
            dataHolder.dX3_1.append(smoothen(record: dataHolder.x, rawValue: differenceOfMostRecentValues(dataHolder.x), 0.675))
            dataHolder.dX4_1.append(smoothen(record: dataHolder.x, rawValue: differenceOfMostRecentValues(dataHolder.x), 0.9))
            
            dataHolder.dX_2.append(smoothen(record: dataHolder.x2, rawValue: differenceOfMostRecentValues(dataHolder.x2), 0.225))
            dataHolder.dX2_2.append(smoothen(record: dataHolder.x2, rawValue: differenceOfMostRecentValues(dataHolder.x2), 0.45))
            dataHolder.dX3_2.append(smoothen(record: dataHolder.x2, rawValue: differenceOfMostRecentValues(dataHolder.x2), 0.675))
            dataHolder.dX4_2.append(smoothen(record: dataHolder.x2, rawValue: differenceOfMostRecentValues(dataHolder.x2), 0.9))
            
            dataHolder.dX_3.append(smoothen(record: dataHolder.x3, rawValue: differenceOfMostRecentValues(dataHolder.x3), 0.225))
            dataHolder.dX2_3.append(smoothen(record: dataHolder.x3, rawValue: differenceOfMostRecentValues(dataHolder.x3), 0.45))
            dataHolder.dX3_3.append(smoothen(record: dataHolder.x3, rawValue: differenceOfMostRecentValues(dataHolder.x3), 0.675))
            dataHolder.dX4_3.append(smoothen(record: dataHolder.x3, rawValue: differenceOfMostRecentValues(dataHolder.x3), 0.9))
            
            dataHolder.dX_4.append(smoothen(record: dataHolder.x4, rawValue: differenceOfMostRecentValues(dataHolder.x4), 0.225))
            dataHolder.dX2_4.append(smoothen(record: dataHolder.x4, rawValue: differenceOfMostRecentValues(dataHolder.x4), 0.45))
            dataHolder.dX3_4.append(smoothen(record: dataHolder.x4, rawValue: differenceOfMostRecentValues(dataHolder.x4), 0.675))
            dataHolder.dX4_4.append(smoothen(record: dataHolder.x4, rawValue: differenceOfMostRecentValues(dataHolder.x4), 0.9))
            */
            dataHolder.dThreeD.append(smoothen(record: dataHolder.threeD, rawValue: differenceOfMostRecentValues(dataHolder.threeD), 0.4))
        }
    }
}
