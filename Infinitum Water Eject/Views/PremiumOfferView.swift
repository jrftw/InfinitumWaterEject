import SwiftUI
import StoreKit

@available(iOS 16.0, *)
struct PremiumOfferView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var service = SubscriptionService.shared
    @State private var errorMessage: String?
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Image(systemName: "waveform.circle.fill").font(.system(size: 64)).foregroundStyle(.blue)
                    Text("Keep your sound. Lose the ads.").font(.largeTitle.bold()).multilineTextAlignment(.center)
                    Text("One purchase. No recurring subscription.").foregroundStyle(.secondary)
                    Label("Remove banner and full-screen ads", systemImage: "checkmark.circle")
                    Label("Save your own speaker test presets", systemImage: "slider.horizontal.3")
                    Text("Water ejection, basic speaker tests, widgets, Siri and Shortcuts remain free.")
                        .font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                    if service.isPremium {
                        Label("Premium is active", systemImage: "checkmark.seal.fill").foregroundStyle(.green)
                    } else if service.isLoading {
                        ProgressView("Loading Apple pricing…")
                    } else if let product = service.products.first {
                        Button {
                            service.purchasePremium(productId: product.id) { success, message in
                                if success { dismiss() } else { errorMessage = message }
                            }
                        } label: {
                            HStack {
                                if service.purchaseInProgress { ProgressView().tint(.white) }
                                Text("Lifetime upgrade · \(product.displayPrice)").font(.headline)
                            }.frame(maxWidth: .infinity).padding()
                        }.buttonStyle(.borderedProminent).disabled(service.purchaseInProgress)
                    } else {
                        Text(service.statusMessage ?? "Upgrade unavailable.").foregroundStyle(.secondary)
                        Button("Try again") { service.fetchProducts() }
                    }
                    Button("Restore purchases") { service.restorePurchases() }
                        .disabled(service.isLoading || service.purchaseInProgress)
                    if let message = service.statusMessage, !service.products.isEmpty || service.isPremium {
                        Text(message).font(.footnote).foregroundStyle(.secondary)
                    }
                    Link("Manage existing subscriptions", destination: URL(string: "https://apps.apple.com/account/subscriptions")!)
                    HStack {
                        Link("Privacy", destination: URL(string: "https://infinitumlive.com/privacy-policy/")!)
                        Link("Terms", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    }.font(.footnote)
                }.padding(24).frame(maxWidth: 600).frame(maxWidth: .infinity)
            }.navigationTitle("Premium").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
                .alert("Purchase", isPresented: Binding(get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } })) {
                    Button("OK") { errorMessage = nil }
                } message: { Text(errorMessage ?? "") }
                .onChange(of: service.isPremium) { if $0 { dismiss() } }
        }
    }
}
