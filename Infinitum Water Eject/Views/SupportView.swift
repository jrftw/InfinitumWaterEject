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
                question: "How does water and dust ejection work?",
                answer: "The app plays tones through this device’s speaker. Sound may help move droplets near the speaker; it cannot remove internal moisture, clean ports, or confirm that a device is dry."
            )
            
            FAQItem(
                question: "What devices are supported?",
                answer: "This release supports iPhone and iPad with iOS 16 or later. Audio plays through the device running the app, not a nearby Watch or AirPods."
            )
            
            FAQItem(
                question: "How long should I run the ejection?",
                answer: "Duration depends on the intensity level: Low (30 seconds), Medium (1 minute), High (2 minutes), Emergency (3 minutes). Follow the on-screen timer and device-specific tips for best results."
            )
            
            FAQItem(
                question: "Is this app safe for my device?",
                answer: "Start at a low system volume, disconnect headphones, and keep the speaker away from your ears. Stop if uncomfortable. Follow your manufacturer’s guidance for wet or damaged devices."
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
                Text("• If water or dust damage is severe, consult a professional")
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
            
            Text("Last updated: November 2026")
                .font(.caption)
                .foregroundColor(.secondary)
            
            PolicySection(
                title: "Information We Collect",
                content: "Session history, saved frequencies and optional diagnostic counters are stored on your device. We receive support information only when you choose to contact us or share a report."
            )
            
            PolicySection(
                title: "How We Use Information",
                content: "Local counters help you inspect completed sessions, ad loading and purchase events. Diagnostics are not automatically uploaded. You can disable or reset them in Settings."
            )
            
            PolicySection(
                title: "Data Storage",
                content: "The app stores session history in Core Data and settings in local preferences. Widgets read a shared local summary. Advertising and purchase services use network connections separately."
            )
            
            PolicySection(
                title: "Third-Party Services",
                content: "Google AdMob supplies ads and may process information such as IP addresses, advertising interactions, device information and diagnostics under its policies. Available consent choices are presented before requesting ads. Apple processes purchases. Premium disables ad requests after entitlements are verified."
            )
            
            PolicySection(
                title: "Your Rights",
                content: "You can export session data, reset local diagnostic counters, and disable diagnostics in Settings. Where required, Advertising privacy choices lets you revisit consent. Deleting the app removes its local history; Apple retains purchase records under its own policies."
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
            
            Text("Last updated: November 2026")
                .font(.caption)
                .foregroundColor(.secondary)
            
            PolicySection(
                title: "Acceptance of Terms",
                content: "By downloading and using Infinitum Water Eject, you agree to be bound by these Terms of Service. If you do not agree to these terms, please do not use the app."
            )
            
            PolicySection(
                title: "App Purpose",
                content: "Infinitum Water Eject plays speaker tones and provides audio tests. It cannot detect water, confirm dryness, prevent damage, or replace professional repair."
            )
            
            PolicySection(
                title: "User Responsibilities",
                content: "Users are responsible for following safety guidelines, using the app as intended, and seeking professional help for severe water or dust damage. The app is not liable for any damage caused by improper use."
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
