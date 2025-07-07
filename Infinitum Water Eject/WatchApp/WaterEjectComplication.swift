import SwiftUI
import ClockKit

// MARK: - Complication Controller
// Uncomment when adding Watch App target

/*
class ComplicationController: NSObject, CLKComplicationDataSource {
    
    // MARK: - Complication Configuration
    
    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "waterEject", displayName: "Water Eject", supportedFamilies: CLKComplicationFamily.allCases)
        ]
        
        handler(descriptors)
    }
    
    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
        // Handle shared complication descriptors
    }
    
    // MARK: - Timeline Configuration
    
    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        // End date is 24 hours from now
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        handler(endDate)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Get current data
        let userDefaults = UserDefaults(suiteName: "group.com.infinitumimagery.watereject")
        let sessionCount = userDefaults?.integer(forKey: "totalSessions") ?? 0
        let lastSessionDate = userDefaults?.object(forKey: "lastSessionDate") as? Date ?? Date()
        
        let template = createTemplate(for: complication, sessionCount: sessionCount, lastSessionDate: lastSessionDate)
        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        handler(entry)
    }
    
    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        // For now, we'll just return the current entry
        getCurrentTimelineEntry(for: complication, withHandler: { entry in
            handler(entry != nil ? [entry!] : nil)
        })
    }
    
    // MARK: - Sample Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        let template = createTemplate(for: complication, sessionCount: 42, lastSessionDate: Date())
        handler(template)
    }
    
    // MARK: - Template Creation
    
    private func createTemplate(for complication: CLKComplication, sessionCount: Int, lastSessionDate: Date) -> CLKComplicationTemplate {
        switch complication.family {
        case .modularSmall:
            return createModularSmallTemplate(sessionCount: sessionCount)
        case .modularLarge:
            return createModularLargeTemplate(sessionCount: sessionCount, lastSessionDate: lastSessionDate)
        case .utilitarianSmall:
            return createUtilitarianSmallTemplate(sessionCount: sessionCount)
        case .utilitarianSmallFlat:
            return createUtilitarianSmallFlatTemplate(sessionCount: sessionCount)
        case .utilitarianLarge:
            return createUtilitarianLargeTemplate(sessionCount: sessionCount, lastSessionDate: lastSessionDate)
        case .circularSmall:
            return createCircularSmallTemplate(sessionCount: sessionCount)
        case .extraLarge:
            return createExtraLargeTemplate(sessionCount: sessionCount, lastSessionDate: lastSessionDate)
        case .graphicCorner:
            return createGraphicCornerTemplate(sessionCount: sessionCount)
        case .graphicBezel:
            return createGraphicBezelTemplate(sessionCount: sessionCount, lastSessionDate: lastSessionDate)
        case .graphicCircular:
            return createGraphicCircularTemplate(sessionCount: sessionCount)
        case .graphicRectangular:
            return createGraphicRectangularTemplate(sessionCount: sessionCount, lastSessionDate: lastSessionDate)
        case .appInline:
            return createAppInlineTemplate(sessionCount: sessionCount)
        default:
            return createModularSmallTemplate(sessionCount: sessionCount)
        }
    }
    
    private func createModularSmallTemplate(sessionCount: Int) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateModularSmallStackText()
        template.line1TextProvider = CLKTextProvider(format: "💧")
        template.line2TextProvider = CLKTextProvider(format: "\(sessionCount)")
        return template
    }
    
    private func createModularLargeTemplate(sessionCount: Int, lastSessionDate: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateModularLargeTallBody()
        template.headerTextProvider = CLKTextProvider(format: "Water Eject")
        template.bodyTextProvider = CLKTextProvider(format: "\(sessionCount) sessions\nLast: \(lastSessionDate, formatter: DateFormatter.shortTime)")
        return template
    }
    
    private func createUtilitarianSmallTemplate(sessionCount: Int) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateUtilitarianSmallFlat()
        template.textProvider = CLKTextProvider(format: "💧 \(sessionCount)")
        return template
    }
    
    private func createUtilitarianSmallFlatTemplate(sessionCount: Int) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateUtilitarianSmallFlat()
        template.textProvider = CLKTextProvider(format: "💧 \(sessionCount)")
        return template
    }
    
    private func createUtilitarianLargeTemplate(sessionCount: Int, lastSessionDate: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateUtilitarianLargeFlat()
        template.textProvider = CLKTextProvider(format: "Water Eject: \(sessionCount) sessions")
        return template
    }
    
    private func createCircularSmallTemplate(sessionCount: Int) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateCircularSmallStackText()
        template.line1TextProvider = CLKTextProvider(format: "💧")
        template.line2TextProvider = CLKTextProvider(format: "\(sessionCount)")
        return template
    }
    
    private func createExtraLargeTemplate(sessionCount: Int, lastSessionDate: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateExtraLargeStackText()
        template.line1TextProvider = CLKTextProvider(format: "💧")
        template.line2TextProvider = CLKTextProvider(format: "\(sessionCount)")
        return template
    }
    
    private func createGraphicCornerTemplate(sessionCount: Int) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicCornerStackText()
        template.innerTextProvider = CLKTextProvider(format: "💧")
        template.outerTextProvider = CLKTextProvider(format: "\(sessionCount)")
        return template
    }
    
    private func createGraphicBezelTemplate(sessionCount: Int, lastSessionDate: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicBezelCircularText()
        template.circularTemplate = createGraphicCircularTemplate(sessionCount: sessionCount)
        template.textProvider = CLKTextProvider(format: "\(sessionCount) sessions")
        return template
    }
    
    private func createGraphicCircularTemplate(sessionCount: Int) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicCircularView()
        template.content = WaterEjectCircularView(sessionCount: sessionCount)
        return template
    }
    
    private func createGraphicRectangularTemplate(sessionCount: Int, lastSessionDate: Date) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateGraphicRectangularLargeView()
        template.content = WaterEjectRectangularView(sessionCount: sessionCount, lastSessionDate: lastSessionDate)
        return template
    }
    
    private func createAppInlineTemplate(sessionCount: Int) -> CLKComplicationTemplate {
        let template = CLKComplicationTemplateAppInline()
        template.textProvider = CLKTextProvider(format: "💧 \(sessionCount)")
        return template
    }
}
*/

// MARK: - SwiftUI Views for Complications

struct WaterEjectCircularView: View {
    let sessionCount: Int
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.2))
            
            VStack(spacing: 2) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.blue)
                
                Text("\(sessionCount)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
    }
}

struct WaterEjectRectangularView: View {
    let sessionCount: Int
    let lastSessionDate: Date
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "drop.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    Text("Water Eject")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                
                Text("\(sessionCount) sessions")
                    .font(.subheadline)
                
                Text("Last: \(lastSessionDate, style: .relative)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
    }
} 