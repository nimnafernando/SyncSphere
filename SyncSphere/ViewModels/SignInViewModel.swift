//
//  LoginViewModel.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-07.
//

import Foundation
import FirebaseAuth

class SignInViewModel: ObservableObject{
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var errorMessage: String = ""
    
    init(){}
    
    func signIn(completion: @escaping (Bool) -> Void) {
       
        guard validateFields() else {
            completion(false)
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    completion(false)
                }
                return
            }
            
            // Sign in successful
            DispatchQueue.main.async {
                self.errorMessage = ""
                completion(true)
            }
        }
    }
    
    func validateFields()-> Bool{
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            errorMessage = "Enter Valid User name and Password"
            return false
        }
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Enter Valid Email"
            return false
        }
        return true
    }
    
}
