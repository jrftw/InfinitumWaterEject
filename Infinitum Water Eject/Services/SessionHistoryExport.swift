import Foundation
import CoreTransferable
import UniformTypeIdentifiers

struct SessionHistoryExport {
    static func csv(_ sessions: [WaterEjectionSession]) -> String {
        let dates = ISO8601DateFormatter()
        var rows = ["Session ID,Device Type,Cycle,Duration (s),Start Time,End Time,Completed"]
        for session in sessions.sorted(by: { $0.startTime > $1.startTime }) {
            let cells = [session.id.uuidString, session.deviceType.rawValue, session.intensityLevel.displayName,
                String(format: "%.1f", locale: Locale(identifier: "en_US_POSIX"), max(0, session.duration)),
                dates.string(from: session.startTime), session.endTime.map(dates.string(from:)) ?? "",
                session.isCompleted ? "Yes" : "No"]
            rows.append(cells.map(escape).joined(separator: ","))
        }
        return rows.joined(separator: "\r\n") + "\r\n"
    }
    static func escape(_ value: String) -> String {
        value.contains(where: { $0 == "," || $0 == "\"" || $0.isNewline })
            ? "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\"" : value
    }
}

struct SessionHistoryDocument: Transferable {
    let csv: String
    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(exportedContentType: .commaSeparatedText) { document in
            let folder = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
            try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
            let url = folder.appendingPathComponent("WaterEjectSessions.csv")
            try document.csv.write(to: url, atomically: true, encoding: .utf8)
            return SentTransferredFile(url)
        }
    }
}
