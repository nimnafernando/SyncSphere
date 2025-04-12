//
//  SignUpViewModel.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-07.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class SignUpViewModel: ObservableObject{
    
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var errorMessage: String = ""
    
    init(){}
    
    func signUp(completion: @escaping (Bool) -> Void) {
        guard validateFields() else {
            completion(false)
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                print("Auth error: \(error.localizedDescription)")
                completion(false)
                return
            }
            
            guard let userId = result?.user.uid else {
                completion(false)
                return
            }
            
            self?.createUser(userId: userId, completion: completion)
        }
    }

    
    private func createUser(userId: String, completion: @escaping (Bool) -> Void){
        let newUser = SyncUser(id: userId, username: username, email: email, createdAt: Date().timeIntervalSince1970)
        let db = Firestore.firestore()
        
        db.collection("user")
            .document(userId)
            .setData(newUser.asDist()) { error in
                        if let error = error {
                            print("Firestore error: \(error.localizedDescription)")
                            completion(false)
                        } else {
                            completion(true)
                        }
                    }
    }
    
    func validateFields()-> Bool{
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              !username.trimmingCharacters(in: .whitespaces).isEmpty
        else {
            errorMessage = "Enter Valid User name and Password"
            return false
        }
        guard email.contains("@") && email.contains(".") else {
            errorMessage = "Enter Valid Email"
            return false
        }
        
        guard password.count > 6 else {
            errorMessage = "Password should contain atleast 6 characters"
            return false
        }
        
        guard password == confirmPassword else {
            errorMessage = "Password does not match"
            return false
        }
        return true
    }
}
