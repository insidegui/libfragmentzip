import Foundation
import FragmentZip
import ArgumentParser

@main
struct FZip: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "fzip",
        abstract: "Extracts one or more files from a remote zip archive, without downloading the entire zip file."
    )

    @Argument(help: "URL to the remote zip file.")
    var zipURL: String

    @Argument(help: "Paths of files to extract from the remote zip file.")
    var paths: [String]

    @Option(name: .shortAndLong, help: "Path to directory where files should be saved.")
    var output: String

    func run() async throws {
        let outputURL = output.resolvedFileURL
        guard outputURL.isDirectory else { throw ValidationError("Output path must be an existing directory.") }

        guard !paths.isEmpty else { throw ValidationError("At least one file path to extract from the remote zip file must be specified.") }

        guard let url = URL(string: zipURL) else { throw ValidationError("Invalid URL: \"\(zipURL)\".") }

        /// Create a directory in the output location with the same name as the remote zip file.
        let directoryURL = outputURL.appending(path: url.deletingPathExtension().lastPathComponent, directoryHint: .isDirectory)

        do {
            if !directoryURL.isDirectory {
                try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)
            }
        } catch {
            fputs("Failed to create output directory: \(error)\n", stderr)
            throw ExitCode(1)
        }

        let zip = FragmentZip(url: url)

        for path in paths {
            do {
                fputs("⌛️ Downloading \"\(path)\"...\n", stderr)

                /// Download into temporary location.
                let tempURL = try await zip.download(filePath: path)

                /// Create final file URL by appending the full file path to the container directory path.
                let finalURL = directoryURL.appending(path: path)

                /// Get the full path to where the file will be, so that we can create the directory tree up to the file if needed.
                let containerURL = finalURL.deletingLastPathComponent()

                if !containerURL.isDirectory {
                    try FileManager.default.createDirectory(at: containerURL, withIntermediateDirectories: true)
                }

                try FileManager.default.moveItem(at: tempURL, to: finalURL)

                fputs("✅ Downloaded \"\(path)\"\n\n", stderr)
            } catch {
                fputs("🟥 Error processing \"\(path)\": \(error)\n", stderr)
            }
        }
    }
}

private extension String {
    var resolvedFileURL: URL { URL(fileURLWithPath: (self as NSString).expandingTildeInPath) }
}

private extension URL {
    var isDirectory: Bool {
        var isDir: ObjCBool = .init(false)
        guard FileManager.default.fileExists(atPath: path, isDirectory: &isDir) else { return false }
        return isDir.boolValue
    }
}
