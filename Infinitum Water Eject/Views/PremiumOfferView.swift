import SwiftUI
import StoreKit

@available(iOS 16.0, *)
struct PremiumOfferView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var showingPurchaseAlert = false
    @State private var purchaseError: String?
    @State private var selectedProductId: String?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 16) {
                        Image(systemName: "crown.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.yellow)
                        
                        Text("Upgrade to Premium")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Unlock unlimited sessions and advanced features")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top)
                    
                    // Premium Features
                    VStack(spacing: 20) {
                        Text("Premium Features")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            ForEach(subscriptionService.getPremiumFeatures().filter { $0 != "Real-time device monitoring" }, id: \.self) { feature in
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .font(.title3)
                                    
                                    Text(feature)
                                        .font(.body)
                                        .foregroundColor(.primary)
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // Pricing Options
                    VStack(spacing: 16) {
                        Text("Choose Your Plan")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        if subscriptionService.isLoading {
                            ProgressView("Loading plans...")
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            VStack(spacing: 12) {
                                ForEach(subscriptionService.products, id: \.productIdentifier) { product in
                                    PricingOptionView(
                                        product: product,
                                        isSelected: selectedProductId == product.productIdentifier,
                                        action: {
                                            selectedProductId = product.productIdentifier
                                        }
                                    )
                                }
                            }
                        }
                    }
                    
                    // Purchase Button
                    VStack(spacing: 12) {
                        Button(action: purchasePremium) {
                            HStack {
                                if subscriptionService.purchaseInProgress {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "crown.fill")
                                }
                                
                                Text(selectedProductId == nil ? "Select a Plan" : "Start Premium")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedProductId == nil ? Color.gray : Color.blue)
                            .cornerRadius(12)
                        }
                        .disabled(subscriptionService.purchaseInProgress || selectedProductId == nil)
                        
                        Button(action: subscriptionService.restorePurchases) {
                            Text("Restore Purchases")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .disabled(subscriptionService.isLoading)
                    }
                    
                    // Apple Watch Widget Preview
                    VStack(spacing: 16) {
                        Text("Apple Watch Widget")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        HStack(spacing: 16) {
                            VStack(spacing: 8) {
                                Image(systemName: "applewatch")
                                    .font(.system(size: 40))
                                    .foregroundColor(.blue)
                                
                                Text("Quick Eject")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .frame(width: 80, height: 80)
                            .background(Color.blue.opacity(0.1))
                            .cornerRadius(12)
                            
                            VStack(spacing: 8) {
                                Image(systemName: "chart.bar.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                                
                                Text("Stats")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .frame(width: 80, height: 80)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)
                            
                            VStack(spacing: 8) {
                                Image(systemName: "bell.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)
                                
                                Text("Reminders")
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .frame(width: 80, height: 80)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(12)
                        }
                        
                        Text("Get instant access to water ejection controls and session statistics right on your Apple Watch")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // Terms
                    Text("By subscribing, you agree to our Terms of Service and Privacy Policy. Subscriptions automatically renew unless cancelled at least 24 hours before the renewal date.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
            }
            .navigationTitle("Premium")
            .navigationBarTitleDisplayMode(.inline)
            .navigationViewStyle(StackNavigationViewStyle())
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
            .alert("Purchase Successful", isPresented: $showingPurchaseAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Welcome to Premium! You now have access to all premium features including Apple Watch widgets.")
            }
            .alert("Purchase Failed", isPresented: .constant(purchaseError != nil)) {
                Button("OK") {
                    purchaseError = nil
                }
            } message: {
                if let error = purchaseError {
                    Text(error)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .purchaseSuccessful)) { _ in
                showingPurchaseAlert = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .purchaseFailed)) { notification in
                purchaseError = notification.object as? String ?? "Purchase failed"
            }
            .onAppear {
                if selectedProductId == nil && !subscriptionService.products.isEmpty {
                    selectedProductId = subscriptionService.products.first?.productIdentifier
                }
            }
        }
    }
    
    private func purchasePremium() {
        guard let productId = selectedProductId else { return }
        
        subscriptionService.purchasePremium(productId: productId) { success, error in
            if success {
                showingPurchaseAlert = true
            } else {
                purchaseError = error ?? "Purchase failed"
            }
        }
    }
}

@available(iOS 16.0, *)
struct PricingOptionView: View {
    let product: SKProduct
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.localizedTitle)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text(product.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(product.localizedPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if product.productIdentifier.contains("yearly") {
                        Text("Save 50%")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                }
            }
            .padding()
            .background(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

@available(iOS 16.0, *)
struct BenefitRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

@available(iOS 16.0, *)
#Preview {
    PremiumOfferView()
} 