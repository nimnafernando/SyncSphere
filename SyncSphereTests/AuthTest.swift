//
//  EventTest.swift
//  SyncSphereTests
//
//  Created by Rashmi Liyanawadu on 2025-05-04.
//

import Testing
import Foundation
import XCTest
@testable import SyncSphere

protocol TestCase {
    func runTests()
}

struct Expectation {
    let description: String
    let assertion: () -> Bool
}

class TestRunner {
    static func describe(_ name: String, tests: () -> [Expectation]) {
        print("Testing \(name)")
        let expectations = tests()
        var passed = 0
        
        for expectation in expectations {
            if expectation.assertion() {
                print("\(expectation.description)")
                passed += 1
            } else {
                print("\(expectation.description)")
            }
        }
        
        print("Results: \(passed)/\(expectations.count) passed\n")
    }
}

// MARK: - SignInViewModel Tests

class SignInViewModelTests: TestCase {
    private var viewModel: SignInViewModel!
    private var mockAuth: MockAuth!
    
    func runTests() {
        TestRunner.describe("Field Validation") {
            testEmptyEmailValidation()
            testEmptyPasswordValidation()
            testInvalidEmailFormat()
            return testValidInput()
        }
        
        TestRunner.describe("Sign In Functionality") {
            testSuccessfulSignIn()
            testFailedSignIn()
            testNetworkError()
            return testValidationPreventsAuth()
        }
    }
    
    private func setup() {
        mockAuth = MockAuth()
        viewModel = SignInViewModel()
    }
    
    private func tearDown() {
        viewModel = nil
        mockAuth = nil
    }
    
    // MARK: - Test Cases
    
    private func testEmptyEmailValidation() -> [Expectation] {
        setup()
        viewModel.email = ""
        viewModel.password = "validPassword123"
        
        return [
            Expectation(description: "Should fail validation with empty email") { [self] in
                !viewModel.validateFields()
            },
            Expectation(description: "Should set correct error message") { [self] in
                viewModel.errorMessage == "Enter Valid User name and Password"
            }
        ]
    }
    
    private func testEmptyPasswordValidation() -> [Expectation] {
        setup()
        viewModel.email = "test@example.com"
        viewModel.password = ""
        
        return [
            Expectation(description: "Should fail validation with empty password") { [self] in
                !viewModel.validateFields()
            },
            Expectation(description: "Should set correct error message") { [self] in
                viewModel.errorMessage == "Enter Valid User name and Password"
            }
        ]
    }
    
    private func testInvalidEmailFormat() -> [Expectation] {
        setup()
        viewModel.email = "notanemail"
        viewModel.password = "validPassword123"
        
        return [
            Expectation(description: "Should fail validation with invalid email") { [self] in
                !viewModel.validateFields()
            },
            Expectation(description: "Should set correct error message") { [self] in
                viewModel.errorMessage == "Enter Valid Email"
            }
        ]
    }
    
    private func testValidInput() -> [Expectation] {
        setup()
        viewModel.email = "test@example.com"
        viewModel.password = "validPassword123"
        
        return [
            Expectation(description: "Should pass validation with valid input") { [self] in
                viewModel.validateFields()
            },
            Expectation(description: "Should clear error message") { [self] in
                viewModel.errorMessage.isEmpty
            }
        ]
    }
    
    private func testSuccessfulSignIn() -> [Expectation] {
        setup()
        viewModel.email = "test@example.com"
        viewModel.password = "validPassword123"
        mockAuth.signInShouldSucceed = true
        
        var successResult: Bool?
        let expectation = Expectation(description: "Should complete successfully") { [self] in
            viewModel.signIn { success in
                successResult = success
            }
            return successResult == true && viewModel.errorMessage.isEmpty
        }
        
        return [expectation]
    }
    
    private func testFailedSignIn() -> [Expectation] {
        setup()
        viewModel.email = "test@example.com"
        viewModel.password = "wrongpassword"
        mockAuth.signInShouldSucceed = false
        mockAuth.mockError = NSError(domain: "AuthError", code: 17009, userInfo: [NSLocalizedDescriptionKey: "The password is invalid"])
        
        var successResult: Bool?
        let expectation = Expectation(description: "Should handle failed sign in") { [self] in
            viewModel.signIn { success in
                successResult = success
            }
            return successResult == false && viewModel.errorMessage == "The password is invalid"
        }
        
        return [expectation]
    }
    
    private func testNetworkError() -> [Expectation] {
        setup()
        viewModel.email = "test@example.com"
        viewModel.password = "validPassword123"
        mockAuth.signInShouldSucceed = false
        mockAuth.mockError = NSError(domain: "NetworkError", code: -1009, userInfo: [NSLocalizedDescriptionKey: "The Internet connection appears to be offline."])
        
        var successResult: Bool?
        let expectation = Expectation(description: "Should handle network error") { [self] in
            viewModel.signIn { success in
                successResult = success
            }
            return successResult == false && viewModel.errorMessage == "The Internet connection appears to be offline."
        }
        
        return [expectation]
    }
    
    private func testValidationPreventsAuth() -> [Expectation] {
        setup()
        viewModel.email = "invalidemail"
        viewModel.password = "short"
        
        var successResult: Bool?
        let expectation = Expectation(description: "Should skip auth when validation fails") { [self] in
            viewModel.signIn { success in
                successResult = success
            }
            return successResult == false && !mockAuth.signInCalled
        }
        
        return [expectation]
    }
}


class MockAuth {
    var signInShouldSucceed = true
    var mockError: Error?
    var signInCalled = false
    
    func signIn(withEmail email: String,
               password: String){
        signInCalled = true
        
        if signInShouldSucceed {
            // Create a mock successful result
           print("Successful")
        } else {
            // Return the mock error
            print("Failes")
        }
    }
}
