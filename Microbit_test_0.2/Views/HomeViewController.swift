//
//  Home.swift
//  Microbit_test_0.2
//
//  Created by Ethan Shin on 26/12/2018.
//  Copyright © 2018 Ethan Shin. All rights reserved.
//

import UIKit

protocol HomeDelegate
{
    func prepareForNextSet()
    func changeMeasuringStatusUpdateButtonStatus(_ bool:Bool)
}

class HomeViewController: UIViewController, UpdateConnectionIndicators, LiveAnalysisDelegate
{
    
    public static var delegate:HomeDelegate?

    @IBOutlet weak var headerL: UILabel!
    @IBOutlet weak var leftImage: UIImageView!
    @IBOutlet weak var rightImage: UIImageView!
    
    @IBOutlet weak var connectionRightL: UILabel!
    @IBOutlet weak var connectionLeftL: UILabel!
    @IBOutlet weak var connectB: UIButton!
    @IBOutlet weak var disconnectB: UIButton!
    
    @IBAction func startScanning(_ sender: UIButton)
    {
        connectB.setTitle("Connecting", for: .normal)
        connectB.isEnabled = false
        ViewController.microbitController?.startScanning()
        disconnectB.isEnabled = true
    }
    
    @IBAction func stopScanning(_ sender: UIButton)
    {
        ViewController.microbitController?.stopScanning()
    }
    
    @IBAction func disconnect(_ sender: UIButton)
    {
        disconnectMicrobits()
    }
    
    
    /// Updates the labels based on its connection status
    ///
    /// - Parameters:
    ///   - labels: The UILabels - text - under the connection icons
    ///   - isConnected: Connection statuses
    private func labelUpdate(labels:[UILabel?], _ isConnected: [Bool])
    {
        for index in 0...1
        {
            switch isConnected[index]
            {
            case true:
                labels[index]!.text = "Connected"
                labels[index]!.textColor = UIColor.green
            case false:
                labels[index]!.text = "Not Connected"
                labels[index]!.textColor = UIColor.red
            }
        }
    }
    
    /// Provide transition effects when connection status changes
    ///
    /// - Parameters:
    ///   - isConnected: Connection status
    ///   - image: The UIImageView - image icon - for the connection status
    private func updateImage(images:[UIImageView], _ isConnected:[Bool])
    {
        for index in 0...1
        {
            switch isConnected[index]
            {
            case true:
                UIView.transition(with: images[index], duration: 1, options: .transitionCrossDissolve, animations: {
                    self.rightImage.image = UIImage(named: "Connected")
                }, completion: nil)
            case false:
                UIView.transition(with: images[index], duration: 1, options: .transitionCrossDissolve, animations: {
                    self.rightImage.image = UIImage.init(named: "Connecting")
                }, completion: nil)
            }
        }
    }
    
    /// MARK: Implementation required for UpdateConnectionIndicators
    /// Updates connection label and images based on connection status of Microbits
    ///
    /// - Parameter isConnected: Connection status of both Microbits
    public func updateConnectionIndicators(isConnected: [Bool])
    {
        labelUpdate(labels: [connectionRightL, connectionLeftL], isConnected)
        updateImage(images: [rightImage, leftImage], isConnected)
        
        if isConnected.first == true && isConnected.last == true
        {
            connectB.setTitle("Connected", for: .normal)
            connectB.isEnabled = false
            HomeViewController.delegate?.changeMeasuringStatusUpdateButtonStatus(true)
            disconnectB.isEnabled = true
        }
    }
    
    /// MARK: Implementation required for LiveAnalysisDelegate; disconnect from Microbits
    public func disconnectMicrobits()
    {
        let microbit = ViewController.microbitController?.microbit
        if connectB.currentTitle == "Connecting"
        {
            microbit!.stopScanning()
            disconnectB.isEnabled = false
            connectB.setTitle("Connect", for: .normal)
            connectB.isEnabled = true
            microbit!.disconnect()
        }
        else
        {
            microbit!.disconnect()
            let after = DispatchTime.now() + 0.5
            DispatchQueue.main.asyncAfter(deadline: after)
            {
                self.connectB.isEnabled = true
                self.connectB.setTitle("Connect", for: .normal)
                self.disconnectB.isEnabled = false
            }
        }
        
        HomeViewController.delegate?.changeMeasuringStatusUpdateButtonStatus(false)
        HomeViewController.delegate?.prepareForNextSet()
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    
        headerL.isHidden = true
        disconnectB.isEnabled = false
        ViewController.updateConnectionIndicators = self
        LiveAnalysisViewController.liveAnalysisDelegate = self
        
        connectionLeftL.text = "Not Connected"
        connectionLeftL.textColor = UIColor.red
        connectionRightL.text = "Not Connected"
        connectionRightL.textColor = UIColor.red
        
        disconnectB.setTitleColor(UIColor.gray, for: .disabled)
        connectB.setTitleColor(UIColor.gray, for: .disabled)
    }
    
     /// Disconnect all microbits when app is quitting
     func applicationWillTerminate()
    {
        disconnectMicrobits()
    }
}
