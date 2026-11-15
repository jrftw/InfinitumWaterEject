import SwiftUI
import MessageUI

struct SupportHelpView: View {
    @Environment(\.openURL) private var openURL
    @State private var showingMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>?
    var body: some View {
        List {
            Section("Contact") {
                Button {
                    if MFMailComposeViewController.canSendMail() { showingMailView = true }
                    else { openURL(URL(string: "mailto:support@infinitumlive.com")!) }
                } label: { Label("Email support", systemImage: "envelope") }
                Text("support@infinitumlive.com").font(.footnote).foregroundStyle(.secondary)
                Text("Include your app version, device model and what happened. Please do not send sensitive personal information.")
            }
            Section("Getting started") {
                DisclosureGroup("How do I use Water Eject?") {
                    Text("Read Safety Tips, disconnect headphones and charging cables, then choose a cycle on Eject. Start at a low system volume with this device’s speaker facing down. You can stop audio at any time.")
                }
                DisclosureGroup("Why is there no sound?") {
                    Text("Check system volume and your audio route. Disconnect Bluetooth audio and headphones to use the built-in speaker. Stop the session before changing output, then try again.")
                }
                DisclosureGroup("What do the cycle choices mean?") {
                    Text("Short, Standard, Long and Extended choose different timers. Live tuning lets you adjust the tone during playback. These options do not indicate how wet a device is or guarantee a repair.")
                }
                DisclosureGroup("Can I use widgets or Siri?") {
                    Text("Add Water Eject from the widget gallery. In Shortcuts, search for Water Eject to start a cycle, stop audio or open Speaker Tools. Siri opens the app before audio starts.")
                }
            }
            Section("Purchases & presets") {
                DisclosureGroup("How do I restore Premium?") {
                    Text("Open Settings → Lifetime Premium → Restore purchases using the Apple Account that bought the upgrade. Lifetime Premium removes ads and enables preset saving. Your saved presets remain usable when a rewarded unlock expires.")
                }
                DisclosureGroup("Where are my sessions and presets stored?") {
                    Text("They are stored on this device. Share a CSV from Settings to export session history. Deleting history keeps your purchases, saved presets and preferences. Removing the app may remove its local data.")
                }
            }
            Section("More help") {
                NavigationLink("Safety tips") { TipsView(isPresentedAsSheet: false) }
                Link("Water Eject website", destination: URL(string: "https://infinitumlive.com/infinitum-water-eject/")!)
            }
            Section { ConditionalBannerAdView(adUnitId: AdMobService.shared.getBannerAdUnitId()) }
        }.navigationTitle("Help & Contact").navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingMailView) { MailView(result: $mailResult) }
    }
}

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
