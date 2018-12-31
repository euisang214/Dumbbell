//
//  ViewController.swift
//  Microbit_test_0.2
//
//  Created by Ethan Shin on 26/12/2018.
//  Copyright © 2018 Ethan Shin. All rights reserved.
//

import UIKit

protocol ComputeDelegate
{
    func computeMain(isRightSide:Bool)
}

protocol UpdateConnectionStatLabelDelegate
{
    func updateConnectionStatLabel(isConnected:[Bool])
}

class ViewController: UIViewController, MicrobitAccelerometerControllerDelegate {
    
    static var microbitController:MicrobitAccelerometerController?
    static var computeDelegate:ComputeDelegate?
    static var updateConnectionStatLabelDelegate:UpdateConnectionStatLabelDelegate?

    @IBOutlet weak var scrollView: UIScrollView!
    
    // MARK: Implement required MicrobitAccelerometerControllerDelegate functions
    public func updateLogView(_ log: String)
    {
       // print(log)
    }
    
    //called whenever the accelerometer receives new values
    public func updateAccelerometerValues(isRightSide:Bool) { ViewController.computeDelegate?.computeMain(isRightSide:isRightSide) }
    
    public func connectionStatUpdate(isConnected: [Bool])
    {
        ViewController.updateConnectionStatLabelDelegate?.updateConnectionStatLabel(isConnected: isConnected)
        if isConnected.first! == true && isConnected.last! == true { scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false) }
    }
    //
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //logView.isEditable = false
        //logView.isScrollEnabled = true
        
        //MAKE TWO MICROBITS, ONE RIGHT AND ONE LEFT SIDE
        ViewController.microbitController = MicrobitAccelerometerController(isRightSide: true)
        ViewController.microbitController?.delegate = self
        
        //setting up UI
        let recordsView:RecordsView = RecordsView(nibName: "RecordsView", bundle: nil)
        let liveAnalysis:LiveAnalysis = LiveAnalysis(nibName: "LiveAnalysis", bundle: nil)
        let home:Home = Home(nibName: "Home", bundle: nil)
        
        self.addChild(recordsView)
        self.scrollView.addSubview(recordsView.view)
        recordsView.didMove(toParent: self)
        
        self.addChild(liveAnalysis)
        self.scrollView.addSubview(liveAnalysis.view)
        liveAnalysis.didMove(toParent: self)
        
        self.addChild(home)
        self.scrollView.addSubview(home.view)
        home.didMove(toParent: self)
        
        var recordsViewFrame:CGRect = recordsView.view.frame
        recordsViewFrame.origin.x = self.view.frame.width * 2
        recordsView.view.frame = recordsViewFrame
        
        var homeFrame:CGRect = home.view.frame
        homeFrame.origin.x = self.view.frame.width
        home.view.frame = homeFrame
        
        self.scrollView.contentSize = CGSize(width:self.view.frame.width*3, height:self.view.frame.size.height)
        
        scrollView.setContentOffset(CGPoint(x: self.view.frame.width, y: 0), animated: false)
    }
    
    override open var shouldAutorotate: Bool { return false }
}

