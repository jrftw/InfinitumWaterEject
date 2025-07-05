/*
import SwiftUI
import StoreKit

struct PremiumOfferView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subscriptionService = SubscriptionService.shared
    @State private var showingPurchaseAlert = false
    @State private var purchaseError: String?
    
    var body: some View {
        NavigationView {
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
                            ForEach(subscriptionService.getPremiumFeatures(), id: \.self) { feature in
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
                    
                    // Pricing
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Monthly Premium")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text("Cancel anytime")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("$0.99")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                
                                Text("per month")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // Benefits
                    VStack(spacing: 16) {
                        Text("Why Choose Premium?")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(spacing: 12) {
                            BenefitRow(
                                icon: "infinity",
                                title: "Unlimited Sessions",
                                description: "No daily limits on water ejection sessions"
                            )
                            
                            BenefitRow(
                                icon: "chart.bar.fill",
                                title: "Advanced Analytics",
                                description: "Detailed insights into your device protection habits"
                            )
                            
                            BenefitRow(
                                icon: "xmark.circle.fill",
                                title: "Ad-Free Experience",
                                description: "Enjoy the app without any advertisements"
                            )
                            
                            BenefitRow(
                                icon: "person.crop.circle.badge.checkmark",
                                title: "Priority Support",
                                description: "Get help faster with premium support"
                            )
                        }
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: purchasePremium) {
                            HStack {
                                if subscriptionService.isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "crown.fill")
                                }
                                
                                Text("Start Premium Trial")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .disabled(subscriptionService.isLoading)
                        
                        Button(action: subscriptionService.restorePurchases) {
                            Text("Restore Purchases")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        .disabled(subscriptionService.isLoading)
                    }
                    
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
                Text("Welcome to Premium! You now have access to all premium features.")
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
        }
    }
    
    private func purchasePremium() {
        subscriptionService.purchasePremium { success, error in
            if success {
                showingPurchaseAlert = true
            } else {
                purchaseError = error ?? "Purchase failed"
            }
        }
    }
}

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

#Preview {
    PremiumOfferView()
}
*/ 