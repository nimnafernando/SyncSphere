//
//  ProfileViewModel.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-08.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class ProfileViewModel : ObservableObject {
    
    init(){}
    
    @Published var user: SyncUser?
    
    func fetchUser(){
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        db.collection("user").document(userId).getDocument() { [weak self] data, error in
            guard let userData = data?.data(), error == nil else{
                return
            }
            
            DispatchQueue.main.async {
                self?.user = SyncUser(id: userData["id"] as? String ?? "", username: userData["username"] as? String ?? "", email: userData["email"] as? String ?? "", createdAt: userData["createdAt"] as? TimeInterval ?? 0)
            }
        }
    }
    
    func signOut(){
        do {
            try Auth.auth().signOut()
        } catch {
            print("Couldn't sign out")
        }
    }
}
