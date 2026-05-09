import Foundation
import Observation

enum AuthProvider: String, Hashable {
    case apple, google, email
    var displayName: String { rawValue.capitalized }
}

protocol AuthService: AnyObject {
    var isAuthenticated: Bool { get }
    var displayName: String { get }
    var email: String? { get }
    var provider: AuthProvider? { get }
    var appleUserID: String? { get }

    func signIn(provider: AuthProvider, name: String?, email: String?) async
    func signInWithApple(userID: String, name: String?, email: String?)
    func signOut()
}

@Observable
final class MockAuthService: AuthService {
    private(set) var isAuthenticated: Bool
    private(set) var displayName: String
    private(set) var email: String?
    private(set) var provider: AuthProvider?
    private(set) var appleUserID: String?

    init(isAuthenticated: Bool, displayName: String = "Nick", email: String? = nil, provider: AuthProvider? = nil) {
        self.isAuthenticated = isAuthenticated
        self.displayName = displayName
        self.email = email
        self.provider = provider
    }

    func signIn(provider: AuthProvider, name: String?, email: String?) async {
        try? await Task.sleep(for: .milliseconds(800))
        await MainActor.run {
            self.isAuthenticated = true
            self.provider = provider
            self.email = email
            if let name, !name.isEmpty {
                self.displayName = name
            }
        }
    }

    /// Synchronous Apple sign-in: the AuthenticationServices completion
    /// already returned the credential, so there's no async to wait on.
    /// We accept the userIdentifier as our stable user key (no
    /// server-side verification — prototype only).
    func signInWithApple(userID: String, name: String?, email: String?) {
        self.isAuthenticated = true
        self.provider = .apple
        self.appleUserID = userID
        if let email, !email.isEmpty {
            self.email = email
        }
        if let name, !name.isEmpty {
            self.displayName = name
        }
    }

    func signOut() {
        isAuthenticated = false
        provider = nil
        email = nil
        appleUserID = nil
    }
}
