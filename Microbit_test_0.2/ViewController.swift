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

protocol UpdateConnectionIndicators
{
    func updateConnectionIndicators(isConnected:[Bool])
}

class ViewController: UIViewController, MicrobitAccelerometerControllerDelegate {
    
    static var microbitController:MicrobitAccelerometerController?
    static var computeDelegate:ComputeDelegate?
    static var updateConnectionIndicators:UpdateConnectionIndicators?
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    static var contentSize:CGSize?
    
    // MARK: Implement required MicrobitAccelerometerControllerDelegate functions
    public func updateLogView(_ log: String)
    {
       // print(log)
    }
    
    //called whenever the accelerometer receives new values
    public func updateAccelerometerValues(isRightSide:Bool) { ViewController.computeDelegate?.computeMain(isRightSide:isRightSide) }
    
    public func connectionStatUpdate(isConnected: [Bool])
    {
        ViewController.updateConnectionIndicators?.updateConnectionIndicators(isConnected: isConnected)
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
        
        scrollView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.size.height)
        
        //setting up UI
        let recordsView:RecordsViewController = RecordsViewController(nibName: "RecordsViewController", bundle: nil)
        let liveAnalysis:LiveAnalysisViewController = LiveAnalysisViewController(nibName: "LiveAnalysisViewController", bundle: nil)
        let home:HomeViewController = HomeViewController(nibName: "HomeViewController", bundle: nil)

        self.addChild(recordsView)
        self.scrollView.addSubview(recordsView.view)
        recordsView.didMove(toParent: self)
        recordsView.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.size.height)
        //print("RecordsView: "+self.view.description)
        
        self.addChild(liveAnalysis)
        self.scrollView.addSubview(liveAnalysis.view)
        liveAnalysis.didMove(toParent: self)
        liveAnalysis.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.size.height)
        //print("LiveAnalysis: "+self.view.description)
        
        self.addChild(home)
        self.scrollView.addSubview(home.view)
        home.didMove(toParent: self)
        home.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.size.height)
       // print("LiveAnalysis: "+home.view.description)
        
        var recordsViewFrame:CGRect = recordsView.view.frame
        recordsViewFrame.origin.x = self.view.frame.width * 2
        recordsView.view.frame = recordsViewFrame
        
        var homeFrame:CGRect = home.view.frame
        homeFrame.origin.x = self.view.frame.width
        home.view.frame = homeFrame
        
        self.scrollView.contentSize = CGSize(width:self.view.frame.width*3, height:self.view.frame.size.height)
        
        scrollView.setContentOffset(CGPoint(x: self.view.frame.width, y: 0), animated: false)
        
       // self.contentSize = scrollView.contentSize
    
    }
    
    override open var shouldAutorotate: Bool { return false }
}

