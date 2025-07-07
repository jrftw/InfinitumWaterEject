import SwiftUI

@available(iOS 16.0, *)
struct SupportView: View {
    let title: String
    let content: String
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                switch title {
                case "Help & FAQ":
                    HelpFAQView()
                case "Contact Support":
                    ContactSupportView()
                case "Privacy Policy":
                    PrivacyPolicyView()
                case "Terms of Service":
                    TermsOfServiceView()
                default:
                    Text(content)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

@available(iOS 16.0, *)
struct HelpFAQView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Frequently Asked Questions")
                .font(.title2)
                .fontWeight(.bold)
            
            FAQItem(
                question: "How does water ejection work?",
                answer: "Infinitum Water Eject generates specific sound frequencies that help dislodge water droplets from your device's speakers and internal components. The app uses scientifically-tuned frequencies optimized for different water exposure levels."
            )
            
            FAQItem(
                question: "What devices are supported?",
                answer: "The app supports iPhone, iPad, MacBook, Apple Watch, AirPods, and other electronic devices. Each device type has optimized frequencies and specific safety tips."
            )
            
            FAQItem(
                question: "How long should I run the ejection?",
                answer: "Duration depends on the intensity level: Low (30 seconds), Medium (1 minute), High (2 minutes), Emergency (3 minutes). Follow the on-screen timer and device-specific tips for best results."
            )
            
            FAQItem(
                question: "Is this app safe for my device?",
                answer: "Yes, the app uses safe audio frequencies that won't damage your device. However, always follow the safety guidelines and consult a professional if water damage is severe."
            )
            
            FAQItem(
                question: "What's the difference between intensity levels?",
                answer: "Low: Gentle frequency for light water exposure. Medium: Standard frequency for normal water exposure. High: Strong frequency for heavy water exposure. Emergency: Maximum frequency for emergency situations."
            )
            
            FAQItem(
                question: "How do I get the best results?",
                answer: "Remove cases and accessories, use gentle motion, avoid extreme temperatures, and let your device dry completely before use. Follow the device-specific tips in the app."
            )
            
            Text("Safety Reminders")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Never use heat sources (hair dryers, ovens) to dry electronics")
                Text("• Avoid extreme shaking that could damage internal components")
                Text("• If water damage is severe, consult a professional")
                Text("• This app is for preventive measures only")
                Text("• Always remove cases and accessories before ejection")
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
        }
    }
}

@available(iOS 16.0, *)
struct ContactSupportView: View {
    @State private var email = ""
    @State private var subject = ""
    @State private var message = ""
    @State private var showingAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Get in Touch")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("We're here to help! Contact our support team for assistance with any questions or issues.")
                .foregroundColor(.secondary)
            
            VStack(spacing: 16) {
                TextField("Your Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                
                TextField("Subject", text: $subject)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("Message")
                    .font(.headline)
                
                TextEditor(text: $message)
                    .frame(minHeight: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            
            Button(action: sendMessage) {
                HStack {
                    Image(systemName: "paperplane.fill")
                    Text("Send Message")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .disabled(email.isEmpty || subject.isEmpty || message.isEmpty)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Other Ways to Reach Us")
                    .font(.headline)
                
                ContactMethod(icon: "envelope.fill", title: "Email", detail: "support@infinitumlive.com")
                ContactMethod(icon: "globe", title: "Website", detail: "infinitumlive.com")
                ContactMethod(icon: "location.fill", title: "Location", detail: "Pittsburgh, PA, USA")
            }
            .padding(.top)
        }
        .alert("Message Sent", isPresented: $showingAlert) {
            Button("OK") { }
        } message: {
            Text("Thank you for contacting us. We'll get back to you within 24 hours.")
        }
    }
    
    private func sendMessage() {
        // In a real app, this would send the message to a server
        showingAlert = true
        email = ""
        subject = ""
        message = ""
    }
}

@available(iOS 16.0, *)
struct ContactMethod: View {
    let icon: String
    let title: String
    let detail: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(detail)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
}

@available(iOS 16.0, *)
struct PrivacyPolicyView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Privacy Policy")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Last updated: July 2025")
                .font(.caption)
                .foregroundColor(.secondary)
            
            PolicySection(
                title: "Information We Collect",
                content: "We collect minimal information necessary to provide our service. This includes device type, ejection session data, and app usage statistics. We do not collect personal information unless you choose to provide it through support requests."
            )
            
            PolicySection(
                title: "How We Use Information",
                content: "We use collected information to improve our water ejection algorithms, provide personalized recommendations, and enhance app functionality. Session data helps us optimize frequencies for different devices and water exposure levels."
            )
            
            PolicySection(
                title: "Data Storage",
                content: "All data is stored locally on your device using Core Data. We do not transmit your data to external servers unless you explicitly choose to share session statistics or contact support."
            )
            
            PolicySection(
                title: "Third-Party Services",
                content: "We may use third-party services for analytics and crash reporting to improve app performance. These services are configured to respect your privacy and do not collect personal information."
            )
            
            PolicySection(
                title: "Your Rights",
                content: "You have the right to access, modify, or delete your data at any time through the app settings. You can also disable data collection features in the app preferences."
            )
            
            PolicySection(
                title: "Contact Us",
                content: "If you have questions about this privacy policy, please contact us at privacy@infinitumlive.com or through the app's support section."
            )
            
            Text("Copyright 2025 Infinitum Imagery LLC")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top)
        }
    }
}

@available(iOS 16.0, *)
struct TermsOfServiceView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Terms of Service")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Last updated: July 2025")
                .font(.caption)
                .foregroundColor(.secondary)
            
            PolicySection(
                title: "Acceptance of Terms",
                content: "By downloading and using Infinitum Water Eject, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app."
            )
            
            PolicySection(
                title: "App Purpose",
                content: "Infinitum Water Eject is designed to help prevent water damage to electronic devices through sound frequency generation. The app is for preventive measures only and should not replace professional repair services."
            )
            
            PolicySection(
                title: "User Responsibilities",
                content: "Users are responsible for following safety guidelines, using the app as intended, and seeking professional help for severe water damage. The app is not liable for any damage caused by improper use."
            )
            
            // PolicySection(
            //     title: "Subscription Terms",
            //     content: "Premium subscriptions are billed monthly at $0.99. Subscriptions automatically renew unless cancelled at least 24 hours before the renewal date. You can manage subscriptions through your App Store account settings."
            // )
            
            PolicySection(
                title: "Intellectual Property",
                content: "All content, features, and functionality of Infinitum Water Eject are owned by Infinitum Imagery LLC and are protected by copyright, trademark, and other intellectual property laws."
            )
            
            PolicySection(
                title: "Limitation of Liability",
                content: "Infinitum Imagery LLC is not liable for any direct, indirect, incidental, or consequential damages arising from the use of the app. The app is provided 'as is' without warranties of any kind."
            )
            
            PolicySection(
                title: "Changes to Terms",
                content: "We reserve the right to modify these terms at any time. Continued use of the app after changes constitutes acceptance of the new terms. Users will be notified of significant changes."
            )
            
            Text("Made by JrFTW in Pittsburgh, PA, USA")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.top)
        }
    }
}

@available(iOS 16.0, *)
struct PolicySection: View {
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(content)
                .font(.body)
                .foregroundColor(.primary)
        }
    }
}

@available(iOS 16.0, *)
struct FAQItem: View {
    let question: String
    let answer: String
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Text(question)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.blue)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            if isExpanded {
                Text(answer)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.leading)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
} 
