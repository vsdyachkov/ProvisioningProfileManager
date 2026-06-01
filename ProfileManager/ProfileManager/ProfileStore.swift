import Foundation
import Observation

@MainActor
@Observable
final class ProfileStore {
    var profiles: [ProvisioningProfile] = []
    var errorMessage: String?
    var isLoading = false

    func reloadIfNeeded() {
        if profiles.isEmpty {
            reload()
        }
    }

    func reload() {
        isLoading = true
        errorMessage = nil

        Task {
            profiles = await Task.detached {
                Self.loadProfiles()
            }.value
            isLoading = false
        }
    }

    func delete(_ ids: Set<ProvisioningProfile.ID>) {
        var deleted = Set<ProvisioningProfile.ID>()
        var failures: [String] = []

        for profile in profiles where ids.contains(profile.id) {
            do {
                try FileManager.default.removeItem(at: profile.fileURL)
                deleted.insert(profile.id)
            } catch {
                failures.append(profile.name)
            }
        }

        profiles.removeAll { deleted.contains($0.id) }
        errorMessage = failures.isEmpty ? nil : "Could not delete: \(failures.joined(separator: ", "))"
    }

    private nonisolated static func loadProfiles() -> [ProvisioningProfile] {
        let libraryURL = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library", isDirectory: true)

        let directories = [
            libraryURL.appendingPathComponent("Developer/Xcode/UserData/Provisioning Profiles", isDirectory: true),
            libraryURL.appendingPathComponent("MobileDevice/Provisioning Profiles", isDirectory: true)
        ]

        let urls = Set(directories.flatMap(profileURLs(in:))).sorted {
            $0.path.localizedStandardCompare($1.path) == .orderedAscending
        }

        return urls.compactMap(ProvisioningProfile.init(fileURL:))
    }

    private nonisolated static func profileURLs(in directory: URL) -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: directory,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }

        return enumerator.compactMap { item -> URL? in
            guard let url = item as? URL, url.pathExtension == "mobileprovision" else {
                return nil
            }
            return url
        }
    }
}
