import Foundation

/// On-device diagnostics only. No identifiers or session data leave the app automatically.
final class GrowthMetrics: ObservableObject {
    static let shared = GrowthMetrics()
    @Published private(set) var revision = 0
    private let defaults = UserDefaults.standard
    var enabled: Bool {
        get { defaults.object(forKey: "diagnosticsEnabled") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "diagnosticsEnabled"); revision += 1 }
    }
    var cohort: String {
        if let value = defaults.string(forKey: "monetizationCohort") { return value }
        let value = Int.random(in: 0..<5) == 0 ? "banner_only" : "post_session"
        defaults.set(value, forKey: "monetizationCohort")
        return value
    }
    func record(_ event: String) {
        guard enabled else { return }
        var counts = defaults.dictionary(forKey: "growthCounts") as? [String: Int] ?? [:]
        counts[event, default: 0] += 1
        defaults.set(counts, forKey: "growthCounts")
        revision += 1
    }
    func recordRevenue(value: Decimal, currency: String, precision: Int) {
        guard enabled else { return }
        // Keep currencies and estimated precision separate; do not mislabel estimates as settled revenue.
        let key = "\(currency)_precision_\(precision)"
        var totals = defaults.dictionary(forKey: "growthRevenue") as? [String: String] ?? [:]
        totals[key] = NSDecimalNumber(decimal: (Decimal(string: totals[key] ?? "0") ?? 0) + value).stringValue
        defaults.set(totals, forKey: "growthRevenue")
        record("ad_paid_event")
    }
    func recordVisit() {
        guard enabled else { return }
        let day = ISO8601DateFormatter().string(from: Calendar.current.startOfDay(for: Date()))
        var days = defaults.stringArray(forKey: "growthActiveDays") ?? []
        guard !days.contains(day) else { return }
        days.append(day)
        defaults.set(Array(days.suffix(90)), forKey: "growthActiveDays")
        record("active_day")
    }
    func reset() {
        for key in ["growthCounts", "growthRevenue", "growthActiveDays"] { defaults.removeObject(forKey: key) }
        revision += 1
    }
    var export: String {
        let object: [String: Any] = [
            "scope": "This installation only; not an account-wide revenue or retention report",
            "cohort": cohort,
            "events": defaults.dictionary(forKey: "growthCounts") ?? [:],
            "estimated_ad_revenue_by_currency_and_precision": defaults.dictionary(forKey: "growthRevenue") ?? [:],
            "active_days_last_90": defaults.stringArray(forKey: "growthActiveDays") ?? []
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys]) else { return "{}" }
        return String(decoding: data, as: UTF8.self)
    }
}

/// Pure rules shared by the placement code and executable regression checks.
struct AdPlacementPolicy {
    static func allows(completed: Int, shownToday: Int, lastShown: Date?, now: Date) -> Bool {
        guard completed >= 2, completed % 2 == 0, shownToday < 3 else { return false }
        return lastShown.map { now.timeIntervalSince($0) >= 180 } ?? true
    }
}
