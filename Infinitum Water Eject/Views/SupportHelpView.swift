import SwiftUI
import MessageUI

@available(iOS 16.0, *)
struct SupportHelpView: View {
    @State private var selectedFAQ: String? = nil
    @State private var showingMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Support & Help")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                            .lineLimit(nil)
                            .minimumScaleFactor(0.8)
                        
                        Text("We're here to help you get the most out of Infinitum Water Eject")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .minimumScaleFactor(0.9)
                    }
                    .padding(.top, 8)
                    .padding(.horizontal)
                    
                    // Contact Section
                    ContactSection(showingMailView: $showingMailView)
                        .padding(.horizontal)
                    
                    // FAQ Section
                    FAQSection(selectedFAQ: $selectedFAQ)
                        .padding(.horizontal)
                    
                    // Additional Resources
                    AdditionalResourcesSection()
                        .padding(.horizontal)
                    
                    // Banner Ad at the bottom
                    VStack(spacing: 0) {
                        ConditionalBannerAdView(adUnitId: AdMobService.shared.getBannerAdUnitId())
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .navigationTitle("Support & Help")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingMailView) {
                MailView(result: $mailResult)
            }
        }
    }
}

@available(iOS 16.0, *)
struct ContactSection: View {
    @Binding var showingMailView: Bool
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
                
                Text("Contact Support")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Email Button
                Button(action: {
                    showingMailView = true
                }) {
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Email Support")
                                .font(.headline)
                                .fontWeight(.semibold)
                            
                            Text("support@infinitumlive.com")
                                .font(.caption)
                                .opacity(0.9)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .opacity(0.8)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                
                // Contact Info Cards
                VStack(spacing: 8) {
                    ContactInfoCard(
                        icon: "globe",
                        title: "Website",
                        detail: "infinitumlive.com",
                        color: .green
                    )
                    
                    ContactInfoCard(
                        icon: "location.fill",
                        title: "Location",
                        detail: "Pittsburgh, PA, USA",
                        color: .orange
                    )
                    
                    ContactInfoCard(
                        icon: "clock.fill",
                        title: "Response Time",
                        detail: "Within 24 hours",
                        color: .purple
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

@available(iOS 16.0, *)
struct ContactInfoCard: View {
    let icon: String
    let title: String
    let detail: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

@available(iOS 16.0, *)
struct FAQSection: View {
    @Binding var selectedFAQ: String?
    
    private let faqs: [FAQItemSupport] = [
        FAQItemSupport(
            id: "how-it-works",
            question: "How does water ejection work?",
            answer: "Infinitum Water Eject generates specific sound frequencies that help dislodge water droplets from your device's speakers and internal components. The app uses scientifically-tuned frequencies optimized for different water exposure levels and device types."
        ),
        FAQItemSupport(
            id: "devices-supported",
            question: "What devices are supported?",
            answer: "The app supports iPhone, iPad, MacBook, Apple Watch, AirPods, and other electronic devices. Each device type has optimized frequencies and specific safety tips tailored to their unique characteristics."
        ),
        FAQItemSupport(
            id: "duration",
            question: "How long should I run the ejection?",
            answer: "Duration depends on the intensity level: Low (30 seconds), Medium (1 minute), High (2 minutes), Emergency (3 minutes), Realtime (5 minutes). Follow the on-screen timer and device-specific tips for best results."
        ),
        FAQItemSupport(
            id: "safety",
            question: "Is this app safe for my device?",
            answer: "Yes, the app uses safe audio frequencies that won't damage your device. However, always follow the safety guidelines and consult a professional if water damage is severe. The frequencies are carefully calibrated to be effective yet safe."
        ),
        FAQItemSupport(
            id: "intensity-levels",
            question: "What's the difference between intensity levels?",
            answer: "Low: Gentle frequency for light water exposure. Medium: Standard frequency for normal water exposure. High: Strong frequency for heavy water exposure. Emergency: Maximum frequency for emergency situations. Realtime: Adjust frequency in real-time while running."
        ),
        FAQItemSupport(
            id: "best-results",
            question: "How do I get the best results?",
            answer: "Remove cases and accessories, use gentle motion, avoid extreme temperatures, and let your device dry completely before use. Follow the device-specific tips in the app and use the appropriate intensity level for your situation."
        ),
        FAQItemSupport(
            id: "realtime-mode",
            question: "What is Realtime mode?",
            answer: "Realtime mode allows you to adjust the frequency while the water ejection is running. This is perfect for finding the optimal frequency for your specific situation. You can see the current frequency in real-time and adjust it using the slider."
        ),
        FAQItemSupport(
            id: "data-privacy",
            question: "Is my data private?",
            answer: "Yes, all your data is stored locally on your device using Core Data. We do not transmit your data to external servers unless you explicitly choose to share session statistics or contact support. Your privacy is our priority."
        )
    ]
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.orange)
                    .font(.title2)
                
                Text("Frequently Asked Questions")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ForEach(faqs) { faq in
                    FAQAccordionItem(
                        faq: faq,
                        isExpanded: selectedFAQ == faq.id,
                        onTap: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if selectedFAQ == faq.id {
                                    selectedFAQ = nil
                                } else {
                                    selectedFAQ = faq.id
                                }
                            }
                        }
                    )
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct FAQItemSupport: Identifiable {
    let id: String
    let question: String
    let answer: String
}

@available(iOS 16.0, *)
struct FAQAccordionItem: View {
    let faq: FAQItemSupport
    let isExpanded: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    Text(faq.question)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(nil)
                        .minimumScaleFactor(0.9)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(width: 20, height: 20)
                }
                .padding()
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    Divider()
                        .padding(.horizontal)
                    
                    Text(faq.answer)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .minimumScaleFactor(0.9)
                        .padding(.horizontal)
                        .padding(.bottom)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        .frame(maxWidth: .infinity)
    }
}

@available(iOS 16.0, *)
struct AdditionalResourcesSection: View {
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "book.fill")
                    .foregroundColor(.purple)
                    .font(.title2)
                
                Text("Additional Resources")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                ResourceCard(
                    icon: "lightbulb.fill",
                    title: "Safety Tips",
                    description: "Learn best practices for water ejection",
                    color: .yellow
                )
                
                ResourceCard(
                    icon: "hand.raised.fill",
                    title: "Privacy Policy",
                    description: "How we protect your data",
                    color: .green
                )
                
                ResourceCard(
                    icon: "doc.text.fill",
                    title: "Terms of Service",
                    description: "App usage terms and conditions",
                    color: .blue
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

@available(iOS 16.0, *)
struct ResourceCard: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}

// Mail View for email composition
struct MailView: UIViewControllerRepresentable {
    @Binding var result: Result<MFMailComposeResult, Error>?
    
    func makeUIViewController(context: Context) -> UIViewController {
        if MFMailComposeViewController.canSendMail() {
            let vc = MFMailComposeViewController()
            vc.mailComposeDelegate = context.coordinator
            vc.setToRecipients(["support@infinitumlive.com"])
            vc.setSubject("Priority Subscriber - Infinitum Water Eject User")
            return vc
        } else {
            // Fallback view when mail is not available
            let fallbackVC = UIViewController()
            let label = UILabel()
            label.text = "Mail is not available on this device"
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            fallbackVC.view.addSubview(label)
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: fallbackVC.view.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: fallbackVC.view.centerYAnchor)
            ])
            return fallbackVC
        }
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let parent: MailView
        
        init(_ parent: MailView) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            if let error = error {
                parent.result = .failure(error)
            } else {
                parent.result = .success(result)
            }
            controller.dismiss(animated: true)
        }
    }
}

#Preview {
    if #available(iOS 16.0, *) {
        SupportHelpView()
    } else {
        Text("Requires iOS 16.0 or newer")
    }
} 