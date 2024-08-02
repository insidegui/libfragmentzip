import Foundation
import CFragmentZip

public struct ZipError: LocalizedError, CustomStringConvertible {
    public var errorDescription: String?

    init(_ message: String) {
        self.errorDescription = message
    }

    public var failureReason: String? { errorDescription }

    public var description: String { errorDescription ?? "" }

}

public actor FragmentZip {
    public let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func contents(ofFile path: String) throws -> Data {
        let tempURL = try download(filePath: path)

        return try Data(contentsOf: tempURL, options: .mappedIfSafe)
    }

    public func download(filePath path: String, as filename: String? = nil) throws -> URL {
        var zip = try instance

        let effectiveName = filename ?? URL(fileURLWithPath: path).lastPathComponent
        let tempURL = URL.tempFileURL(name: effectiveName)

        #if DEBUG
        fputs("Temporary file: \(tempURL.path)\n", stderr)
        #endif

        try path.withCString { remotePath in
            try tempURL.path.withCString { localPath in
                let code = fragmentzip_download_file(&zip, remotePath, localPath, nil)
                if code != 0 {
                    throw ZipError("libfragmentzip error \(code)")
                }
            }
        }

        return tempURL
    }

    public func close() {
        guard var _instance else { return }
        fragmentzip_close(&_instance)
    }

    // MARK: - Private API

    private var _instance: fragmentzip_t?

    private var instance: fragmentzip_t {
        get throws {
            if let _instance { return _instance }

            let newInstance = try open()

            self._instance = newInstance

            return newInstance
        }
    }

    private func open() throws -> fragmentzip_t {
        let zip = url.absoluteString.withCString { ptr in
            fragmentzip_open(ptr)
        }

        guard let newInstance = zip?.pointee else {
            throw ZipError("Error opening remote zip at \(url.absoluteString)")
        }

        return newInstance
    }
}

private extension URL {
    static func tempFileURL(name: String) -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
    }
}
