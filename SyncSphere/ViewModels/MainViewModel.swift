//
//  MainViewModel.swift
//  SyncSphere
//
//  Created by Rashmi Liyanawadu on 2025-04-08.
//

import Foundation
import FirebaseAuth

class MainViewModel: ObservableObject{
    
    @Published var userId: String = ""
    @Published var profileViewModel = ProfileViewModel()
    private var signInHandler: AuthStateDidChangeListenerHandle?
    
    public var isSignin: Bool {
        return Auth.auth().currentUser != nil
    }
    
    init() {
        self.signInHandler = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.userId = user?.uid ?? ""
                
                if user != nil {
                    self?.profileViewModel.fetchUser()
                }
            }
        }
    }
    
    deinit {
           // Remove the listener
           if let handler = signInHandler {
               Auth.auth().removeStateDidChangeListener(handler)
           }
       }
}
