//
//  GoogleSignInHelper.swift
//  CHRGUP
//
//  Created by Jithin Kamatham on 05/03/25.
//

import Foundation
import UIKit
import GoogleSignIn
import FirebaseCore
import FirebaseAuth

class GoogleSignInHelper{
    static let shared = GoogleSignInHelper()
    private init(){}
    
    func signIn(with viewController: UIViewController,completion : @escaping (Result<UserProfile,Error>) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print(" Firebase client ID not found")
            return
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let user = result?.user, let idToken = user.idToken?.tokenString else{
                completion(.failure(NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "User or token not found"])))
                return
            }
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let user = authResult?.user else {
                    completion(.failure(NSError(domain: "FirebaseAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                    return
                }
                let fullName = user.displayName ?? "No Name"
                let nameComponents = fullName.split(separator: " ")
                let firstName = nameComponents.first?.trimmingCharacters(in: .whitespaces) ?? "No First Name"
                let lastName = nameComponents.dropFirst().joined(separator: " ").trimmingCharacters(in: .whitespaces) // Join remaining words

                let userDetails = UserProfile(firstName: firstName,
                                              lastName: lastName,
                                              userVehicle: [],
                                              email: user.email ?? "No email",
                                              gender: "",
                                              dob: "",
                                              city: "",
                                              state: "",
                                              phoneNumber: user.phoneNumber ?? "",
                                              profilePic: user.photoURL?.absoluteString ?? "")
                completion(.success(userDetails))
            }
        }
    }
}
