import Foundation

struct ProvisioningProfile: Identifiable, Hashable, Sendable {
    let id: URL
    let fileURL: URL
    let name: String
    let teamName: String
    let appName: String
    let bundleIdentifier: String
    let teamIdentifier: String
    let creationDate: Date

    var createdText: String {
        Self.dateFormatter.string(from: creationDate)
    }

    init?(fileURL: URL) {
        guard let info = Self.plist(from: fileURL) else {
            return nil
        }

        let entitlements = info["Entitlements"] as? [String: Any]
        let appIdentifier = entitlements?["application-identifier"] as? String ?? ""

        self.id = fileURL
        self.fileURL = fileURL
        self.name = info["Name"] as? String ?? fileURL.deletingPathExtension().lastPathComponent
        self.teamName = info["TeamName"] as? String ?? ""
        self.appName = info["AppIDName"] as? String ?? name
        self.bundleIdentifier = Self.bundleIdentifier(from: appIdentifier)
        self.teamIdentifier = entitlements?["com.apple.developer.team-identifier"] as? String ?? ""
        self.creationDate = info["CreationDate"] as? Date ?? .distantPast
    }

    func matches(_ query: String) -> Bool {
        [name, teamName, appName, bundleIdentifier, teamIdentifier].contains {
            $0.localizedCaseInsensitiveContains(query)
        }
    }

    private static func bundleIdentifier(from appIdentifier: String) -> String {
        let parts = appIdentifier.split(separator: ".", maxSplits: 1)
        return parts.count == 2 ? String(parts[1]) : appIdentifier
    }

    private static func plist(from fileURL: URL) -> [String: Any]? {
        guard
            let data = try? Data(contentsOf: fileURL),
            let text = String(data: data, encoding: .isoLatin1),
            let start = text.range(of: "<plist"),
            let end = text.range(of: "</plist>", range: start.lowerBound..<text.endIndex)
        else {
            return nil
        }

        let plistText = String(text[start.lowerBound..<end.upperBound])
        guard
            let plistData = plistText.data(using: .isoLatin1),
            let object = try? PropertyListSerialization.propertyList(from: plistData, format: nil)
        else {
            return nil
        }

        return object as? [String: Any]
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}
