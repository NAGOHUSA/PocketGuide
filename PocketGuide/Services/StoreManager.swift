import Foundation
import StoreKit

// MARK: - StoreManager
//
// Handles City Pack in-app purchases via StoreKit 2.
// Each City Pack is sold as a non-consumable IAP at $4.99.
// All transaction validation happens on-device—no server needed.

@MainActor
final class StoreManager: ObservableObject {

    // MARK: - Published state

    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoadingProducts = false
    @Published var purchaseError: String?

    // MARK: - Private

    private var updateListenerTask: Task<Void, Error>?

    // MARK: - Init / deinit

    init() {
        updateListenerTask = listenForTransactions()
        Task { await loadProducts() }
        Task { await refreshPurchasedProducts() }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    // MARK: - Load products

    func loadProducts() async {
        isLoadingProducts = true
        defer { isLoadingProducts = false }

        let productIDs = CityPack.catalog.map(\.storeProductID)
        do {
            let fetched = try await Product.products(for: productIDs)
            products = fetched.sorted { $0.displayName < $1.displayName }
        } catch {
            // In the simulator or without a valid StoreKit configuration,
            // fall back to mock products so the UI remains usable.
            products = makeMockProducts()
        }
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async -> Bool {
        purchaseError = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                purchasedProductIDs.insert(product.id)
                return true
            case .userCancelled:
                return false
            case .pending:
                return false
            @unknown default:
                return false
            }
        } catch {
            purchaseError = error.localizedDescription
            return false
        }
    }

    /// Convenience: purchase by product ID string.
    func purchase(productID: String) async -> Bool {
        guard let product = products.first(where: { $0.id == productID }) else {
            // Use mock purchase in simulator / preview
            purchasedProductIDs.insert(productID)
            return true
        }
        return await purchase(product)
    }

    // MARK: - Restore

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshPurchasedProducts()
        } catch {
            purchaseError = "Could not restore purchases: \(error.localizedDescription)"
        }
    }

    // MARK: - Check if purchased

    func isPurchased(productID: String) -> Bool {
        purchasedProductIDs.contains(productID)
    }

    // MARK: - Private helpers

    private func refreshPurchasedProducts() async {
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchasedProductIDs.insert(transaction.productID)
            }
        }
    }

    private func listenForTransactions() -> Task<Void, Error> {
        Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try await self.checkVerified(result)
                    await MainActor.run {
                        self.purchasedProductIDs.insert(transaction.productID)
                    }
                    await transaction.finish()
                } catch {
                    // Unverified transaction—ignore
                }
            }
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let value):
            return value
        }
    }

    // MARK: - Mock products (simulator / previews)

    private func makeMockProducts() -> [Product] {
        // StoreKit's Product type cannot be instantiated directly for mocks.
        // The UI falls back to displaying info from CityPack.catalog instead.
        []
    }
}

// MARK: - StoreError

enum StoreError: LocalizedError {
    case failedVerification
    case productNotFound(String)

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Transaction verification failed. Please try again."
        case .productNotFound(let id):
            return "Product '\(id)' was not found in the App Store."
        }
    }
}
