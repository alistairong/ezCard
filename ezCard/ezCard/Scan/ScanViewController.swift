//
//  ScanViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseDatabase

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    
    var qrCodeHighlightView: UIView?
    
    let captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    let usersRef = Database.database().reference(withPath: "users")
    let cardsRef = Database.database().reference(withPath: "cards")
    
    var isPresentingScanConfirmationViewController = false
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Set up back camera for QR Code Scanning
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back)
        
        if let captureDevice = deviceDiscoverySession.devices.first {
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice)
                captureSession.addInput(input)
                
                let captureMetadataOutput = AVCaptureMetadataOutput()
                captureSession.addOutput(captureMetadataOutput)
                
                captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                captureMetadataOutput.metadataObjectTypes = captureMetadataOutput.availableMetadataObjectTypes // [AVMetadataObject.ObjectType.qr]
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer!.frame = cameraView.layer.bounds
                cameraView.layer.addSublayer(videoPreviewLayer!)
            } catch {
                print("Error initializing AVCaptureDeviceInput:", error)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Start scanning
        captureSession.startRunning()
        
        isPresentingScanConfirmationViewController = false
        
        // Get rid of box highlighting a previous QR code
        qrCodeHighlightView?.removeFromSuperview()
        qrCodeHighlightView = nil
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        // Stop camera when switching views
        captureSession.stopRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoPreviewLayer?.frame = cameraView.layer.bounds
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObj = metadataObjects.first(where: { $0 is AVMetadataMachineReadableCodeObject }) as? AVMetadataMachineReadableCodeObject else {
            // No QR code detected
            qrCodeHighlightView?.removeFromSuperview()
            qrCodeHighlightView = nil
            return
        }
        
        // Found a QR code
        if let underlyingData = metadataObj.stringValue, metadataObj.type == .qr, underlyingData.contains(GlobalConstants.QR_UUID) {
            
            // Highlight QR code with green box
            if qrCodeHighlightView == nil {
                qrCodeHighlightView = UIView()
                qrCodeHighlightView!.layer.borderColor = UIColor.green.cgColor
                qrCodeHighlightView!.layer.borderWidth = 5
                qrCodeHighlightView!.layer.cornerRadius = 5
                cameraView.addSubview(qrCodeHighlightView!)
            }
            
            let qrCodeObject = videoPreviewLayer!.transformedMetadataObject(for: metadataObj)
            qrCodeHighlightView!.frame = qrCodeObject!.bounds

            // Show the ScanConfirmationViewController after the scan
            if !isPresentingScanConfirmationViewController {
                isPresentingScanConfirmationViewController = true
                
                // Check if QR code is a valid ezCard QR code
                let qrMetadata = underlyingData.split(separator: " ")
                cardsRef.child(String(qrMetadata[1])).observeSingleEvent(of: .value) { [weak self] (snapshot) in
                    // Don't do anything if code is not valid
                    guard let strongSelf = self, let card = Card(snapshot: snapshot) else {
                        return
                    }
                    
                    // Show scanConfirmationViewController if code is valid
                    let scanConfirmationViewController = ScanConfirmationViewController(style: .grouped)
                    
                    scanConfirmationViewController.card = card
                    
                    strongSelf.usersRef.child(card.userId).observeSingleEvent(of: .value, with: { (snapshot) in
                        guard let user = User(snapshot: snapshot) else {
                            return
                        }
                        
                        scanConfirmationViewController.sharingUser = user
                        
                        strongSelf.present(scanConfirmationViewController, animated: true, completion: nil)
                    })
                }
            }
        }
    }

}
