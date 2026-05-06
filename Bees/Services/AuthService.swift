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

    func signIn(provider: AuthProvider, name: String?, email: String?) async
    func signOut()
}

@Observable
final class MockAuthService: AuthService {
    private(set) var isAuthenticated: Bool
    private(set) var displayName: String
    private(set) var email: String?
    private(set) var provider: AuthProvider?

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

    func signOut() {
        isAuthenticated = false
        provider = nil
        email = nil
    }
}
