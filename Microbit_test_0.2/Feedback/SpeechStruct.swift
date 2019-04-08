//
//  SpeechStruct.swift
//  Microbit_test_0.2
//
//  Created by Ethan Shin on 3/4/2019.
//  Copyright © 2019 Ethan Shin. All rights reserved.
//

import Foundation

struct SpeechStruct
{
    /// The speech String for ROM. There are 3 sentence variations in total; each are split into 2 for inserting the calculated percentage at Speech.
    let ROM = ["Your range of motion is only ", ", percent extend and contract your arms further!", "Your left arm is ", "percent faster than your right. Speed up your right arm!", "Your left arm is ", "percent slower than your right. Speed up your left arm!"]
    
    /// The speech String for ROM. There are 3 sentence variations in total; each are split into 2 for inserting the calculated percentage at Speech.
    let SPR = ["Your seconds per rep is only ", ", try moving slower!", "Your left arm is ", "percent faster than your right. Speed up your right arm!", "Your left arm is ", "percent slower than your right. Speed up your left arm!"]
}
