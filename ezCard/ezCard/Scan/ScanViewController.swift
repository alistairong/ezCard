//
//  ScanViewController.swift
//  ezCard
//
//  Created by Andrew Whitehead on 3/6/19.
//  Copyright © 2019 Andrew Whitehead. All rights reserved.
//

import UIKit
import AVFoundation

class ScanViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var cameraView: UIView!
    
    var qrCodeHighlightView: UIView?
    
    let captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    var isPresentingScanConfirmationViewController = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
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
        } else {
            // TODO: show "cannot find camera" UI
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        captureSession.startRunning()
        
        isPresentingScanConfirmationViewController = false
        
        qrCodeHighlightView?.removeFromSuperview()
        qrCodeHighlightView = nil
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        captureSession.stopRunning()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        videoPreviewLayer?.frame = cameraView.layer.bounds
    }
    
    // MARK: - AVCaptureMetadataOutputObjectsDelegate
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObj = metadataObjects.first(where: { $0 is AVMetadataMachineReadableCodeObject }) as? AVMetadataMachineReadableCodeObject else {
            // no QR code detected
            qrCodeHighlightView?.removeFromSuperview()
            qrCodeHighlightView = nil
            return
        }
        
        if let underlyingData = metadataObj.stringValue, metadataObj.type == .qr, underlyingData.contains(GlobalConstants.QR_UUID) {
            // found a QR code
            
            if qrCodeHighlightView == nil {
                qrCodeHighlightView = UIView()
                qrCodeHighlightView!.layer.borderColor = UIColor.green.cgColor
                qrCodeHighlightView!.layer.borderWidth = 5
                qrCodeHighlightView!.layer.cornerRadius = 5
                cameraView.addSubview(qrCodeHighlightView!)
            }
            
            let qrCodeObject = videoPreviewLayer!.transformedMetadataObject(for: metadataObj)
            qrCodeHighlightView!.frame = qrCodeObject!.bounds

            if !isPresentingScanConfirmationViewController {
                isPresentingScanConfirmationViewController = true
                
                let scanConfirmationViewController = ScanConfirmationViewController(style: .grouped)
                scanConfirmationViewController.qrMetadata = underlyingData
                present(scanConfirmationViewController, animated: true, completion: nil)
            }
        }
    }

}
