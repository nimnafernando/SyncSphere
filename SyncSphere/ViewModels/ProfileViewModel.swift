import Foundation
import FirebaseAuth
import FirebaseFirestore

class ProfileViewModel: ObservableObject {
    @Published var user: SyncUser?
    @Published var isLoading = false
    @Published var error: String?
    
    init() {
        if !loadSavedUser() {
            fetchUser()
        }
    }
    
    func fetchUser() {
        guard let userId = Auth.auth().currentUser?.uid else {
            self.error = "No authenticated user"
            return
        }
        
        isLoading = true
        error = nil
        
        let db = Firestore.firestore()
        
        db.collection("user").document(userId).getDocument() { [weak self] data, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.error = error.localizedDescription
                    return
                }
                
                guard let userData = data?.data() else {
                    self?.error = "User data not found"
                    return
                }
                
                let user = SyncUser(
                    id: userData["id"] as? String ?? "",
                    username: userData["username"] as? String ?? "",
                    email: userData["email"] as? String ?? "",
                    createdAt: userData["createdAt"] as? TimeInterval ?? 0
                )
                
                self?.user = user
                self?.saveUserLocally(user)
            }
        }
    }
    
    private func saveUserLocally(_ user: SyncUser) {
        let userData: [String: Any] = [
            "id": user.id,
            "username": user.username,
            "email": user.email,
            "createdAt": user.createdAt
        ]
        
        UserDefaults.standard.set(userData, forKey: "currentUser")
    }
    
    private func loadSavedUser() -> Bool {
        guard let userData = UserDefaults.standard.dictionary(forKey: "currentUser"),
              let id = userData["id"] as? String,
              let username = userData["username"] as? String,
              let email = userData["email"] as? String,
              let createdAt = userData["createdAt"] as? TimeInterval else {
            return false
        }
        
        self.user = SyncUser(
            id: id,
            username: username,
            email: email,
            createdAt: createdAt
        )
        
        return true
    }
    
    func updateUsername(to newName: String, completion: ((Result<Void, Error>) -> Void)? = nil) {
        let db = Firestore.firestore()
        guard let user = user else {
            completion?(.failure(NSError(domain: "UserError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User not loaded"])))
            return
        }
        
        let userRef = db.collection("user").document(user.id)
        
        userRef.updateData(["username": newName]) { error in
            if let error = error {
                print("Failed to update username: \(error.localizedDescription)")
                completion?(.failure(error))
            } else {
                DispatchQueue.main.async {
                    self.user?.username = newName
                }
                print("Username updated successfully to \(newName)")
                completion?(.success(()))
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
            UserDefaults.standard.removeObject(forKey: "currentUser")
            self.user = nil
        } catch {
            print("Couldn't sign out: \(error)")
        }
    }
}
