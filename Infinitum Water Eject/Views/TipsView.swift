import SwiftUI

@available(iOS 16.0, *)
struct TipsView: View {
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            List {
                Section("Before playing audio") {
                    Text("Remove the case and gently wipe visible moisture with a soft, dry cloth. Disconnect charging cables and headphones.")
                    Text("Hold this device with its speaker facing down. Start at a low system volume and keep it away from your ears.")
                }
                Section("Know the limits") {
                    Text("Sound may help move droplets near a speaker. This app does not detect water, remove internal moisture, clean charging ports, or repair damage.")
                    Text("Cycle completion means the timer finished. It does not confirm that the device is dry. Stop if the sound is uncomfortable or distorted.")
                    Text("Audio plays only through this device. The app does not remotely eject water from a Watch, AirPods or another device.")
                }
                Section("If your device is wet") {
                    Text("Follow the manufacturer’s guidance. Do not charge a wet connector. Do not use heat, compressed air, rice, or insert objects into ports.")
                    Text("If the device is damaged, overheats or keeps malfunctioning, stop using it and contact the manufacturer or a repair professional.")
                    Link("Apple’s liquid-detection guidance", destination: URL(string: "https://support.apple.com/102643")!)
                }
            }.navigationTitle("Safety Tips").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}
