//
//  SignUpView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-07.
//

import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    @StateObject private var signUpViewModel = SignUpViewModel()
    @State private var navigateToLogin = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .success
    
    var body: some View {
        NavigationStack {
            VStack (spacing: 20){
                
                Spacer()
                
                Text("Sign Up")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.bottom, 20)
                
                AuthTextField(iconName: "person.circle", placeholder: "Username", text: $signUpViewModel.username)
                AuthTextField(iconName: "envelope.circle", placeholder: "Email", text: $signUpViewModel.email)
                AuthTextField(iconName: "lock.circle", placeholder: "Password", text: $signUpViewModel.password, isSecure: true)
                AuthTextField(iconName: "lock.rotation", placeholder: "Confirm Password", text: $signUpViewModel.confirmPassword, isSecure: true)
                
                AuthButton(label:"Sign Up", width: 0.9) {
                        signUpViewModel.signUp { success in
                            if success {
                                toastMessage = "Account was successfully created!"
                                toastType = .success
                                showToast = true
                                    
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    navigateToLogin = true
                                }
                            } else {
                                toastMessage = signUpViewModel.errorMessage.isEmpty ?
                                    "Something went wrong. Try again." : signUpViewModel.errorMessage
                                toastType = .error
                                showToast = true
                            }
                        }
                }
        
                Spacer()
                
                HStack{
                    VStack{Divider()}
                    Text("Or")
                    VStack{Divider()}
                }.padding(.bottom, 20)
                
                
                AuthButton(label:"Countinue with Google", width: 0.8, icon: "g.circle.fill"){
                    
                }
                
//                SignInWithAppleButton(.signIn){
//                    result in
//                }onCompletion: { result in
//                    
//                }
//                .frame(width: UIScreen.main.bounds.width * 0.96)
//                .frame(height: UIScreen.main.bounds.height * 0.05)
//                .signInWithAppleButtonStyle(.whiteOutline)
                
                Spacer()
            }.padding()
             .navigationDestination(isPresented: $navigateToLogin) {
                    SignInView()
            }
        }
    }
}

#Preview {
    SignUpView()
}
