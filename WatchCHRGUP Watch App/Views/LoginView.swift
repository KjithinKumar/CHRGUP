//
//  LoginView.swift
//  WatchCHRGUP Watch App
//
//  Created by Jithin Kamatham on 23/06/25.
//

import SwiftUI

struct LoginView: View {
    var body: some View {
        VStack{
            Image("AppLogo")
            Text("Welcome")
                .font(.title2)
                .fontWeight(.bold)
            Text("Login using Mobile App")
                .minimumScaleFactor(0.8)
        }
    }
}

#Preview {
    LoginView()
}
