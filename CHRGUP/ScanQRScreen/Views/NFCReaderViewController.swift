//
//  NFCReaderViewController.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 09/07/25.
//

import UIKit
import CoreNFC

class NFCReaderViewController: UIViewController, NFCNDEFReaderSessionDelegate {
    var nfcSession: NFCNDEFReaderSession?
    weak var delegate : NFCReaderViewControllerDelegate?

    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            return
        }

        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold your iPhone near the NFC tag."
        nfcSession?.begin()
    }
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
    }

    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
    }
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                if record.typeNameFormat == .nfcWellKnown || record.typeNameFormat == .absoluteURI,
                   let uri = String(data: record.payload.dropFirst(), encoding: .utf8) {
                    if let payload = self.decodeQRPayload(from: uri){
                        delegate?.nfcReader(self, didReadPayload: payload)
                        session.invalidate()
                    }
                }
            }
        }
    }
    func decodeQRPayload(from scannedString: String) -> QRPayload? {
        guard let url = URL(string: scannedString),
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let encryptedPayload = components.queryItems?.first(where: { $0.name == "data" })?.value
        else {return nil}
        guard let decryptedText = DeepLinkManager.shared.decryptPayload(encryptedBase64: encryptedPayload, password: AppIdentifications.payload.password) else {return nil}
        guard let payload = DeepLinkManager.shared.decodeDecryptedPayload(decryptedText: decryptedText) else {return nil}
        return payload
    }
}

protocol NFCReaderViewControllerDelegate: AnyObject {
    func nfcReader(_ reader: NFCReaderViewController, didReadPayload payload: QRPayload)
}

