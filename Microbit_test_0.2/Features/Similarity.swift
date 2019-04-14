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
    /// Calculates the average value of a given ArraySlice
    ///
    /// - Parameter array: The array whose average value is desired
    /// - Returns: The average value of the array's contents as a Double
    private func average(array:ArraySlice<Double>) -> Double
    {
        var sum:Double = 0
        for element in array { sum += Double(Int32(element))}
        return sum/Double(array.count)
    }
    
    /// Uses Microsoft Excel's 'Correl' equation to assess the overall corellation/similarity between two given arrays
    ///
    /// - Parameters:
    ///   - leftArray: Array number 1
    ///   - rightArray: Array number 2
    /// - Returns: The similarity value of the two arrays as an Int
    public func overallSimilarity(leftArray:[Double], rightArray:[Double]) -> Int
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
