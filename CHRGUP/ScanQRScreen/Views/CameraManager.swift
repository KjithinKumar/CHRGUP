//
//  CameraManager.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 07/04/25.
//


import AVFoundation
import UIKit

class CameraManager: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    
    private let session = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    private var onCodeScanned: (QRPayload) -> Void
    
    init(previewView: UIView, onCodeScanned: @escaping (QRPayload) -> Void) {
        self.onCodeScanned = onCodeScanned
        super.init()
        
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              session.canAddInput(input) else { return }
        
        session.addInput(input)
        
        let metadataOutput = AVCaptureMetadataOutput()
        if session.canAddOutput(metadataOutput) {
            session.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
            metadataOutput.metadataObjectTypes = [.qr]
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.videoGravity = .resizeAspectFill
        previewLayer?.frame = previewView.bounds
        previewView.layer.addSublayer(previewLayer!)
    }
    
    func startSession() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    func stopSession() {
        session.stopRunning()
    }
    
    func toggleTorch() {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        try? device.lockForConfiguration()
        device.torchMode = device.torchMode == .on ? .off : .on
        device.unlockForConfiguration()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject, let value = object.stringValue {
            session.stopRunning()
            if let qrResponse = decodeQRPayload(from: value){
                onCodeScanned(qrResponse)
            }
        }
    }
    func decodeQRPayload(from jsonString: String) -> QRPayload? {
        guard let data = jsonString.data(using: .utf8) else { return nil }
        do {
            let decoded = try JSONDecoder().decode(QRPayloadContainer.self, from: data)
            return decoded.payload
        } catch {
            print("Decoding error:", error)
            return nil
        }
    }
}
