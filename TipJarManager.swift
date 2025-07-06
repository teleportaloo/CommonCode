//
//  TipJarManager.swift
//  Trail Map Locator
//
//  Created by Andy Wallace on 3/21/25.
//

// How to use:  in the root view controller start a listener like this:
// [TipJarManager.shared fetchProductsAndStartListener:@[
//    @"com.teleportaloo.tml.tip.small", @"com.teleportaloo.tml.tip.medium",
//    @"com.teleportaloo.tml.tip.large" ] parent:self];
//
// Then can show the tip jar: TipJarManager.shared.showTipJar(viewController)
//

import Foundation
import StoreKit

@objc @MainActor class TipJarManager: NSObject {
    @objc static let shared = TipJarManager()

    var productTask: Task<Void, Never>?
    var products: [Product]?

    public override init() {
    }

    @objc public func fetchProductsAndStartListener(
        _ productIds: [String],
        parent: UIViewController
    ) {
        if products == nil && productTask == nil {
            productTask = Task {
                let products = await fetchProducts(productIds)
                DispatchQueue.main.async {
                    self.products = products
                    self.productTask = nil
                    self.startTransactionListener(parent)
                }
            }
        }
    }

    func fetchProducts(_ productIds: [String]) async -> [Product]? {
        do {
            let products = try await Product.products(
                for: Set<String>(productIds))
            return products.sorted { $0.price < $1.price }
        } catch {
            return nil
        }
    }

    // Purchase a product by ID
    func purchaseProduct(_ product: Product) async -> (
        completed: Bool, ok: Bool
    ) {
        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    return (true, true)
                }
            case .userCancelled:
                DEBUG_LOG(.LogUI, "User cancelled purchase")
                return (false, true)
            default:
                return (false, false)
            }
        } catch {
            print("Purchase failed: \(error)")
            return (false, false)
        }
        return (false, false)
    }

    public func startTransactionListener(_ parent: UIViewController) {
        Task { [weak parent, weak self] in
            // Listen for ongoing transaction updates
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    if let parent = parent {
                        if let self = self {
                            self.showThankYouAlert(parent)
                        }
                    }
                    // Mark the transaction as finished
                    await transaction.finish()
                }
            }
        }
    }

    @objc public func showTipJar(
        _ parent: UIViewController, message: String? = nil
    ) {
        if let products = self.products, !products.isEmpty {
            let alert = UIAlertController(
                title: "Support Us!",
                message: message == nil
                    ? "Leave a tip to support the app ❤️. There are no extra features to buy - the app is free and fully featured."
                    : message,
                preferredStyle: .alert
            )

            for product in products {
                addTipAction(with: product, to: alert, parent: parent)
            }

            // Add a cancel button
            let cancelAction = UIAlertAction(
                title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)

            parent.present(alert, animated: true)
        } else {
            return showTipErrorAlert(
                parent,
                message:
                    "Sorry, the tip jar isn't ready. Please try again in a moment."
            )
        }
    }

    // Helper to add a tip action
    func addTipAction(
        with product: Product, to alert: UIAlertController,
        parent: UIViewController
    ) {
        let title = "\(product.displayName) - \(product.displayPrice)"

        let tipAction = UIAlertAction(title: title, style: .default) { _ in
            Task {
                let result = await self.purchaseProduct(product)
                if result.completed {
                    self.showThankYouAlert(parent)
                } else if !result.ok {
                    self.showTipErrorAlert(parent)
                } else {
                    self.showTipErrorAlert(
                        parent, message: "The tip was cancelled 😢")
                }
            }
        }

        alert.addAction(tipAction)
    }

    // Show thank you alert
    func showThankYouAlert(_ parent: UIViewController) {
        let thankYou = UIAlertController(
            title: "Thank You!",
            message: "Your tip helps keep the app going 🙌",
            preferredStyle: .alert
        )
        thankYou.addAction(
            UIAlertAction(
                title: "You're Welcome!", style: .default, handler: nil))
        parent.present(thankYou, animated: true, completion: nil)
    }

    // Show error alert
    func showTipErrorAlert(_ parent: UIViewController, message: String? = nil) {
        let errorAlert = UIAlertController(
            title: "Tip Jar",
            message: message == nil
                ? "Something went wrong. Please try again!" : message,
            preferredStyle: .alert
        )
        errorAlert.addAction(
            UIAlertAction(title: "OK", style: .default, handler: nil))
        parent.present(errorAlert, animated: true, completion: nil)
    }
}
