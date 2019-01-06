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

class Home: UIViewController, UpdateConnectionStatLabelDelegate, LiveAnalysisDelegate {
    
    public static var delegate:HomeDelegate?

    //  @IBOutlet weak var logView: UITextView!
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
    
    private func labelUpdate(label:UILabel!, isConnected: Bool)
    {
        switch isConnected
        {
        case true:
            label.text = "Connected"
            label.textColor = UIColor.green
        case false:
            label.text = "Not Connected"
            label.textColor = UIColor.red
        }
    }
    
    //provide flashing effects on the circle images when attempting to connect
    private func updateLeftImage(isConnected:Bool)
    {
        switch isConnected
        {
        case true:
            UIView.transition(with: leftImage, duration: 1, options: .transitionCrossDissolve, animations: {
                self.leftImage.image = UIImage(named: "Connected")
            }, completion: nil)
        case false:
            UIView.transition(with: leftImage, duration: 1, options: .transitionCrossDissolve, animations: {
                self.leftImage.image = UIImage.init(named: "Connecting")
            }, completion: nil)
        }
    }
    
    private func updateRightImage(isConnected:Bool)
    {
        switch isConnected
        {
        case true:
            UIView.transition(with: rightImage, duration: 1, options: .transitionCrossDissolve, animations: {
                self.rightImage.image = UIImage(named: "Connected")
            }, completion: nil)
        case false:
            UIView.transition(with: rightImage, duration: 1, options: .transitionCrossDissolve, animations: {
                self.rightImage.image = UIImage.init(named: "Connecting")
            }, completion: nil)
        }
    }
    
    // MARK: Implementaiton required for UpdateConnectionStatLabelDelegate
    public func updateConnectionStatLabel(isConnected: [Bool])
    {
        labelUpdate(label: connectionRightL, isConnected: isConnected.first!)
        labelUpdate(label: connectionLeftL, isConnected: isConnected.last!)
        updateLeftImage(isConnected: isConnected.last!)
        updateRightImage(isConnected: isConnected.first!)
        
        if isConnected.first == true && isConnected.last == true
        {
            connectB.setTitle("Connected", for: .normal)
            connectB.isEnabled = false
            Home.delegate?.changeMeasuringStatusUpdateButtonStatus(true)
            disconnectB.isEnabled = true
        }
    }
    
    //MARK: Implementation required for LiveAnalysisDelegate
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
        
        Home.delegate?.changeMeasuringStatusUpdateButtonStatus(false)
        Home.delegate?.prepareForNextSet()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        headerL.isHidden = true
        disconnectB.isEnabled = false
        ViewController.updateConnectionStatLabelDelegate = self
        LiveAnalysis.liveAnalysisDelegate = self
        
        connectionLeftL.text = "Not Connected"
        connectionLeftL.textColor = UIColor.red
        connectionRightL.text = "Not Connected"
        connectionRightL.textColor = UIColor.red
        
        disconnectB.setTitleColor(UIColor.gray, for: .disabled)
        connectB.setTitleColor(UIColor.gray, for: .disabled)
        
        //connectionRightL.layer.backgroundColor  = UIColor.lightGray.cgColor
        //connectionRightL.layer.cornerRadius = 5
    }
    
     func applicationWillTerminate()
    {
        disconnectMicrobits()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
