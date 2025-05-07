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
            ZStack{
                GradientBackground()
                VStack (spacing: 12){
                    
                    Spacer()
                    
                    Image("logo")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.height * 0.18)
                        .padding(.top, 30)
                    
                    Spacer()
                    
                    Text("Sign Up")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 20)
                    
                    AuthTextField(placeholder: "Username", text: $signUpViewModel.username)
                    AuthTextField(placeholder: "Email", text: $signUpViewModel.email)
                    AuthTextField(placeholder: "Password", text: $signUpViewModel.password, isSecure: true)
                    AuthTextField(placeholder: "Confirm Password", text: $signUpViewModel.confirmPassword, isSecure: true)
                    
                    Spacer()
                    
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
                    
                    HStack{
                        Text("Already have an account?")
                        NavigationLink(destination: SignInView()) {
                            Text("Sign in")
                        }
                    }.font(.footnote)
                    
                }.padding()
                    .navigationDestination(isPresented: $navigateToLogin) {
                        SignInView()
                    }
            }
        }
    }
}

#Preview {
    SignUpView()
}
