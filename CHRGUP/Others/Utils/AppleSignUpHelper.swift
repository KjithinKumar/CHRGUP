////
////  AppleSignUpHelper.swift
////  CHRGUP
////
////  Created by Jithin Kamatham on 22/04/25.
////
//
//import Foundation
//import AuthenticationServices
//import FirebaseAuth
//
//class AppleSignInHelper: NSObject {
//    static let shared = AppleSignInHelper()
//    private var completion: ((Result<UserProfile, Error>) -> Void)?
//    
//    
//    func startSignInWithAppleFlow(completion: @escaping (Result<UserProfile, Error>) -> Void) {
//        self.completion = completion
//        let request = ASAuthorizationAppleIDProvider().createRequest()
//        request.requestedScopes = [.fullName, .email]
//        
//        let controller = ASAuthorizationController(authorizationRequests: [request])
//        controller.delegate = self
//        controller.presentationContextProvider = self
//        controller.performRequests()
//    }
//}
//
//extension AppleSignInHelper: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
//    
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//        return  UIApplication.shared.connectedScenes
//            .compactMap { $0 as? UIWindowScene }
//            .flatMap { $0.windows }
//            .first { $0.isKeyWindow } ?? UIWindow()
//    }
//    
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
//           let identityToken = appleIDCredential.identityToken,
//           let tokenString = String(data: identityToken, encoding: .utf8) {
//            
//            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: "")
//            Auth.auth().signIn(with: credential) { authResult, error in
//                if let error = error {
//                    self.completion?(.failure(error))
//                    return
//                }
//                guard let user = authResult?.user else {
//                    self.completion?(.failure(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
//                    return
//                }
//                
//                let fullName = appleIDCredential.fullName
//                let firstName = fullName?.givenName ?? "No First Name"
//                let lastName = fullName?.familyName ?? "No Last Name"
//                
//                let userDetails = UserProfile(firstName: firstName,
//                                              lastName: lastName,
//                                              userVehicle: [],
//                                              email: user.email ?? "No email",
//                                              gender: "",
//                                              dob: "",
//                                              city: "",
//                                              state: "",
//                                              phoneNumber: user.phoneNumber ?? "",
//                                              profilePic: "")
//                self.completion?(.success(userDetails))
//            }
//        } else {
//            self.completion?(.failure(NSError(domain: "AppleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to fetch identity token"])))
//        }
//    }
//    
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//        self.completion?(.failure(error))
//    }
//}
