//
//  Similarity.swift
//  Microbit_test_0.1
//
//  Created by Ethan Shin on 25/12/2018.
//  Copyright © 2018 Peter Wallen. All rights reserved.
//

import Foundation

class Similarity
{
    private func average(array:ArraySlice<Int16>) -> Double
    {
        var sum:Double = 0
        for element in array { sum += Double(Int32(element))}
        return sum/Double(array.count)
    }
    
    /*
    
    //gets the 'd' - difference - between most recent data points for the given
    //array - in DataHolder - and presents it as a percentage.
    //
    //The percentage is given as the difference between the right and
    //left side, divided by the smaller of the two
    //
    //Assesses the percentage difference between rate of change of the most recent measurements
    public func liveSimilarity(leftArray:[Int16], rightArray:[Int16]) -> Double
    {
        var sum = 0.0
        let leftLast = leftArray.endIndex-1
        let rightLast = rightArray.endIndex-1
        if leftArray.count>=32 && rightArray.count>=32
        {
            for index in 0...31
            {
                sum += Double(min(abs(leftArray[leftLast-index]), abs(rightArray[rightLast-index])))/Double(max(abs(leftArray[leftLast-index]), abs(rightArray[rightLast-index])))*100
            }
            return sum/Double(32)
        }
        return 0
    }
    
    */
    
    //uses Microsoft Excel's 'Correl' equation
    //Assesses the overall corellation between the motion of the two given arrays
    public func overallSimilarity(leftArray:[Int16], rightArray:[Int16]) -> Int
    {
        if leftArray.count>32 && rightArray.count>32
        {
            
            var leftArraySuff = leftArray.suffix(from: leftArray.count-32)
            var rightArraySuff = rightArray.suffix(from: rightArray.count-32)
            
            let leftAverage = average(array: leftArraySuff)
            let rightAverage = average(array: rightArraySuff)
        
            var numerater:Double = 0
            var denominatorLeft:Double = 0
            var denominatorRight:Double = 0
            
            for idx in 1...32
            {
                numerater += (Double(leftArraySuff[leftArray.endIndex-idx])-leftAverage)*(Double(rightArraySuff[rightArray.endIndex-idx])-rightAverage)
            }
            
            for idx in 1...32
            {
                denominatorLeft += (Double(leftArraySuff[leftArray.endIndex-idx])-leftAverage)*(Double(leftArraySuff[leftArray.endIndex-idx])-leftAverage)
            }
            
            for idx in 1...32
            {
                denominatorRight += (Double(rightArraySuff[rightArray.endIndex-idx])-rightAverage)*(Double(rightArraySuff[rightArray.endIndex-idx])-rightAverage)
            }
            
            let returnDoubleValue = numerater/(pow(denominatorRight*denominatorLeft, 0.5))
            
            if returnDoubleValue.isNormal
            {
                return Int(abs(returnDoubleValue*100))
            }
            else
            {
                return -1
            }
        }
     return 0
    }
}
