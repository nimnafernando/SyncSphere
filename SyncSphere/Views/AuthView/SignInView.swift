//
//  SignInView.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-07.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices

struct SignInView: View {
    @StateObject private var signInViewModel = SignInViewModel()
    @EnvironmentObject var mainViewModel: MainViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel

    @State private var navigateToDashboard = false
    @State private var showToast = false
    @State private var toastMessage = ""
    @State private var toastType: ToastType = .success
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                if showToast {
                    VStack {
                        ToastView(message: toastMessage, type: toastType)
                            .padding(.top, 20)
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    withAnimation {
                                        showToast = false
                                    }
                                }
                            }
                        Spacer()
                    }
                    .zIndex(1)
                }
                
                GradientBackground()
                
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image("logo")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.height * 0.18)
                        .padding(.top, 30)
                    
                    Spacer()
                    
                    AuthTextField(placeholder: "Email", text: $signInViewModel.email)
                    AuthTextField(placeholder: "Password", text: $signInViewModel.password, isSecure: true)
                    
                    Spacer()
                    
                    AuthButton(label:"Sign in", width: 0.9) {
                        signInViewModel.signIn { success in
                            if success, let userId = Auth.auth().currentUser?.uid {
                                profileViewModel.fetchUser()
                                toastMessage = "Sign in successful!"
                                toastType = .success
                                showToast = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    navigateToDashboard = true
                                }
                            } else {
                                toastMessage = signInViewModel.errorMessage.isEmpty ?
                                    "Something went wrong. Try again." : signInViewModel.errorMessage
                                toastType = .error
                                showToast = true
                            }
                        }
                    }
                    
                    HStack{
                        Text("New to SyncSphere?")
                        NavigationLink(destination: SignUpView()) {
                            Text("Sign up")
                        }
                    }.font(.footnote)
                }
                .padding(.bottom, 30)
                .padding()
                
               
            }
            .navigationBarBackButtonHidden(true)
            .navigationDestination(isPresented: $navigateToDashboard) {
                DashboardView()
            }
        }
    }
}

#Preview {
    let mockViewModel = ProfileViewModel()
        mockViewModel.user = SyncUser(
            id: "123",
            username: "Jane Doe",
            email: "jane@example.com",
            createdAt: Date().timeIntervalSince1970
        )
    return SignInView()
            .environmentObject(mockViewModel)
}
