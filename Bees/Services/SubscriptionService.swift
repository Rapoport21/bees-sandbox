import Foundation
import StoreKit
import Observation

/// Wraps StoreKit 2 product fetching + purchase. In dev/prototype the
/// scheme's `StoreKitConfigurationFileReference` points at
/// `Bees.storekit`, so all calls hit a local sandbox — Apple presents
/// its real subscription sheet, but no money moves and no App Store
/// Connect setup is required. Switching to App Store Connect later
/// is just removing the scheme reference; the API stays identical.
@Observable
final class SubscriptionService {
    private(set) var products: [Product] = []
    private(set) var isLoadingProducts = false
    private(set) var lastError: String?

    /// The set of product IDs currently entitled (active subscription).
    private(set) var entitledProductIDs: Set<String> = []

    private var transactionListener: Task<Void, Never>?

    init() {
        // Listen for transactions that arrive outside our purchase()
        // call (renewals, refunds, family-sharing changes).
        transactionListener = Task.detached { [weak self] in
            for await update in Transaction.updates {
                await self?.process(update)
            }
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    @MainActor
    func loadProducts() async {
        isLoadingProducts = true
        lastError = nil
        let ids = Tier.allCases.map(\.productID)
        do {
            let fetched = try await Product.products(for: ids)
            // Sort by tier display order (cheapest → premium).
            products = fetched.sorted { lhs, rhs in
                let lTier = Tier.from(productID: lhs.id) ?? .pollinator
                let rTier = Tier.from(productID: rhs.id) ?? .pollinator
                return tierOrder(lTier) < tierOrder(rTier)
            }
        } catch {
            lastError = error.localizedDescription
        }
        isLoadingProducts = false
    }

    /// Triggers Apple's real subscription sheet. Returns the verified
    /// transaction on success, nil on user cancel / pending review.
    @MainActor
    func purchase(_ tier: Tier) async throws -> Transaction? {
        guard let product = product(for: tier) else {
            throw SubscriptionError.productNotFound(tier.productID)
        }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
            await process(verification)
            return transaction
        case .userCancelled:
            return nil
        case .pending:
            return nil
        @unknown default:
            return nil
        }
    }

    func product(for tier: Tier) -> Product? {
        products.first(where: { $0.id == tier.productID })
    }

    // MARK: - Private

    @MainActor
    private func process(_ result: VerificationResult<Transaction>) async {
        switch result {
        case .verified(let transaction):
            if transaction.revocationDate == nil && transaction.isUpgraded == false {
                entitledProductIDs.insert(transaction.productID)
            } else {
                entitledProductIDs.remove(transaction.productID)
            }
            await transaction.finish()
        case .unverified:
            // Prototype: ignore unverified.
            break
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value): return value
        case .unverified(_, let error): throw error
        }
    }

    private func tierOrder(_ tier: Tier) -> Int {
        switch tier {
        case .pollinator:  return 0
        case .forager:     return 1
        case .queenKeeper: return 2
        }
    }

    enum SubscriptionError: LocalizedError {
        case productNotFound(String)

        var errorDescription: String? {
            switch self {
            case .productNotFound(let id):
                return "Product \(id) is not available. Did the StoreKit configuration load?"
            }
        }
    }
}
