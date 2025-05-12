//
//  AppleSignUpHelper.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 22/04/25.
//

import Foundation
import AuthenticationServices
import FirebaseAuth
import CryptoKit

class AppleSignInHelper: NSObject {
    static let shared = AppleSignInHelper()
    private var completion: ((Result<UserProfile, Error>) -> Void)?
    var nonce : String?
    
    func startSignInWithAppleFlow(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        self.completion = completion
        let request = ASAuthorizationAppleIDProvider().createRequest()
        let nonce = randomNonceString()
        self.nonce = nonce
        let hashedNonce = sha256(nonce)
        request.nonce = hashedNonce
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }
}

extension AppleSignInHelper: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return  UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow } ?? UIWindow()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
           let identityToken = appleIDCredential.identityToken,
           let nonce = self.nonce{
            guard let idTokenString = String(data: identityToken, encoding: .utf8) else {
                   print("Unable to serialize token string from data: \(identityToken.debugDescription)")
                   return
                 }
            let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                                    rawNonce: nonce,
                                                                    fullName: appleIDCredential.fullName)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    self.completion?(.failure(error))
                    return
                }
                guard let user = authResult?.user else {
                    self.completion?(.failure(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                    return
                }
                
                let fullName = appleIDCredential.fullName
                let firstName = fullName?.givenName ?? "No First Name"
                let lastName = fullName?.familyName ?? "No Last Name"
                
                let userDetails = UserProfile(id: "",
                                              firstName: firstName,
                                              lastName: lastName,
                                              userVehicle: [],
                                              email: user.email ?? "No email",
                                              gender: "",
                                              dob: "",
                                              city: "",
                                              state: "",
                                              phoneNumber: user.phoneNumber ?? "",
                                              profilePic: "")
                self.completion?(.success(userDetails))
            }
        } else {
            self.completion?(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])))
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        self.completion?(.failure(error))
    }
    private func randomNonceString(length: Int = 32) -> String {
      precondition(length > 0)
      var randomBytes = [UInt8](repeating: 0, count: length)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
      if errorCode != errSecSuccess {
        fatalError(
          "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
        )
      }

      let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")

      let nonce = randomBytes.map { byte in
        // Pick a random character from the set, wrapping around if needed.
        charset[Int(byte) % charset.count]
      }

      return String(nonce)
    }

    private func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }
}

