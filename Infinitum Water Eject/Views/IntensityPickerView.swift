import SwiftUI

struct IntensityPickerView: View {
    @Binding var selectedIntensity: IntensityLevel
    @Environment(\.dismiss) private var dismiss
    @State private var draftIntensity: IntensityLevel
    @State private var useCustom: Bool
    @State private var tonePosition: Double
    @State private var duration: Double

    init(selectedIntensity: Binding<IntensityLevel>) {
        _selectedIntensity = selectedIntensity
        let defaults = UserDefaults.standard
        _draftIntensity = State(initialValue: selectedIntensity.wrappedValue)
        _useCustom = State(initialValue: defaults.bool(forKey: "useCustomIntensity"))
        let position = defaults.object(forKey: "customIntensityValue") as? Double ?? 50
        let seconds = defaults.object(forKey: "customDuration") as? Double ?? 60
        _tonePosition = State(initialValue: position.isFinite ? min(100, max(0, position)) : 50)
        _duration = State(initialValue: seconds.isFinite ? min(300, max(10, seconds)) : 60)
    }
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Choose a cycle length and tone. These settings change frequency and duration, not system volume.").foregroundStyle(.secondary)
                }
                Section("Preset cycles") {
                    ForEach(IntensityLevel.allCases, id: \.self) { level in
                        Button { draftIntensity = level; useCustom = false } label: {
                            HStack {
                                Label { VStack(alignment: .leading, spacing: 4) {
                                    Text(level.displayName).foregroundStyle(.primary)
                                    Text("\(Int(level.duration)) seconds").font(.caption).foregroundStyle(.secondary)
                                }} icon: { Image(systemName: level.icon).foregroundStyle(level.color) }
                                Spacer()
                                if !useCustom && draftIntensity == level { Image(systemName: "checkmark.circle.fill").foregroundStyle(.blue) }
                            }.padding(.vertical, 4)
                        }.buttonStyle(.plain).accessibilityAddTraits(!useCustom && draftIntensity == level ? .isSelected : [])
                    }
                }
                Section("Custom cycle") {
                    Toggle("Use custom settings", isOn: $useCustom)
                    if useCustom {
                        LabeledContent("Tone position", value: "\(Int(tonePosition))%")
                        Slider(value: $tonePosition, in: 0...100, step: 1).accessibilityLabel("Tone position")
                        LabeledContent("Duration", value: "\(Int(duration)) seconds")
                        Slider(value: $duration, in: 10...300, step: 5).accessibilityLabel("Cycle duration")
                    }
                }
                Section {
                    Text("Start at a comfortable system volume. A longer or higher-frequency cycle does not guarantee a better result. Stop if uncomfortable.").font(.footnote).foregroundStyle(.secondary)
                }
            }.navigationTitle("Cycle settings").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) { Button("Done") {
                        let defaults = UserDefaults.standard
                        defaults.set(useCustom, forKey: "useCustomIntensity")
                        defaults.set(tonePosition, forKey: "customIntensityValue")
                        defaults.set(duration, forKey: "customDuration")
                        selectedIntensity = useCustom ? .medium : draftIntensity
                        dismiss()
                    } }
                }
        }
    }
}
