import Foundation

let version = "1.0.1"

private extension NSError {
    static func local(_ msg: String, code: Int) -> NSError {
        NSError(domain: "", code: code, userInfo: [NSLocalizedDescriptionKey: msg])
    }
    
    static let missingPathOrBundle = NSError.local(
        "Expected path to the project and the target bundle id as arguments. Use -h for help.",
        code: -1
    )
    
    static func nothinFound(argBundleId: String, argPath: String, argPlatform: String) -> NSError {
        .local("Nothing found for \(argBundleId) in [\(argPath)] for [\(argPlatform)]", code: -2)
    }
    
    static let missingVersion = NSError.local(
        "MARKETING_VERSION not found",
        code: -3
    )
    
    static let missingBuild = NSError.local(
        "CURRENT_PROJECT_VERSION not found",
        code: -4
    )
    
    static func readFile(path: String, origin: Error) -> NSError {
        .local("Read file at \(path) exception: \(origin)", code: -5)
    }
    
    static let missingBundle = NSError.local(
        "Expected the target bundle id as arguments. Use -h for help.",
        code: -6
    )
}

private extension String {
    var clean: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    var cleanLowercased: String {
        clean.lowercased()
    }
}

private extension Bool {
    var not: Bool { !self }
}

public protocol FileReader {
    func contentsOfFile(path: String, encoding: String.Encoding) throws -> String
}

public struct InfoPlist: Decodable {
    public let version: String?
    public let build: String?
    
    enum CodingKeys: String, CodingKey {
        case version = "CFBundleShortVersionString"
        case build = "CFBundleVersion"
    }
}

public struct Program {
    enum OutputType {
      case error
      case standard
    }
    
    func writeMessage(_ message: String, to: OutputType = .standard) {
      switch to {
      case .standard:
        print("\(message)")
      case .error:
        fputs("Error: \(message)\n", stderr)
      }
    }
    
    enum Arg {
        enum Mode: String, CaseIterable {
            case version, build, full
            static let option = "-m"
            
            static var all: String {
                Arg.Mode.allCases.map({ $0.rawValue }).joined(separator: ", ") + " (default)"
            }
        }
        
        enum Format: String, CaseIterable {
            case dot, brackets, line
            static let option = "-f"
            
            static var all: String {
                Arg.Format.allCases.map({ $0.rawValue }).joined(separator: ", ") + " (default)"
            }
        }

        enum Configuration: String, CaseIterable {
            case debug, release
            static let option = "-c"
            
            var name: String { rawValue.capitalized }
            
            static var all: String {
                Arg.Configuration.allCases.map({ $0.rawValue }).joined(separator: ", ") + " (default)"
            }
        }
        
        enum Platform: String, CaseIterable {
            case iOS = "ios", macOs = "macos", tvOs = "tvos"
            static let option = "-platform"
            
            var name: String {
                switch self {
                case .iOS: return "ios"
                case .macOs: return "macos"
                case .tvOs: return "tvos"
                }
            }
            
            var sdk: String {
                switch self {
                case .iOS: return "iphoneos"
                case .macOs: return "macosx"
                case .tvOs: return "appletvos"
                }
            }
        }
        
        enum Bundle { static let option = "-b" }
        enum Path { static let option = "-p" }
        enum Help { static let option = "-h" }
        enum Version { static let option = "--version" }
    }
    
    public let fileReader: FileReader
    
    public init(fileReader: FileReader) {
        self.fileReader = fileReader
    }
    
    private func _run(arguments: [String]) throws -> String {
        var argPath = String()
        var argBundleId = String()
        var argFormat = Arg.Format.line
        var isHelpRequest = false
        var isVersionRequest = false
        var argMode = Arg.Mode.full
        var argConfig = Arg.Configuration.release
        var argPlatform = Arg.Platform.iOS
        
        var prevArg = String()
        for arg in arguments {
            if prevArg.cleanLowercased == Arg.Path.option { argPath = arg.clean }
            if prevArg.cleanLowercased == Arg.Bundle.option { argBundleId = arg.clean }
            if prevArg.cleanLowercased == Arg.Format.option { argFormat = .init(rawValue: arg.cleanLowercased) ?? .line }
            if prevArg.cleanLowercased == Arg.Mode.option { argMode = .init(rawValue: arg.cleanLowercased) ?? .full }
            if prevArg.cleanLowercased == Arg.Configuration.option { argConfig = .init(rawValue: arg.cleanLowercased) ?? .release }
            if prevArg.cleanLowercased == Arg.Platform.option { argPlatform = .init(rawValue: arg.cleanLowercased) ?? .iOS }
            
            isHelpRequest = (arg.cleanLowercased == Arg.Help.option)
            isVersionRequest = (arg.cleanLowercased == Arg.Version.option)
            
            prevArg = arg
        }
        
        if isVersionRequest { return version }
        
        if isHelpRequest {
            return """
            Help for XCVDetector \(version)
            Extract marketing and build version numbers from iOS Xcode project.
            
            Usage: xcvdetector \(Arg.Path.option) <path to the project> \(Arg.Bundle.option) <target bundle id> \(Arg.Format.option) <format>

              \(Arg.Help.option): Show this help. All other arguments will be ignored.
              \(Arg.Configuration.option): (aka Configuration) Target configuration. Available options are: [\(Arg.Configuration.all)].
              \(Arg.Format.option): (aka Format) Rule for output how to separate build number.
                  Available options are: [\(Arg.Format.all)].
                  Can be omitted. Only valid for default [mode] (see option \(Arg.Mode.option)).
              \(Arg.Path.option): (aka Path) Path to the project. If omitted first project found in the current directory will be used.
              \(Arg.Bundle.option): (aka Bundle) Target bundle id
              \(Arg.Mode.option): (aka Mode) Mode for output.
                  Available options are: [\(Arg.Mode.all)].
                  See example mode.
            
            example usage:
              $ xcvdetector \(Arg.Path.option) ../demo/demoApp.xcodeproj \(Arg.Bundle.option) com.companyName.demo \(Arg.Format.option) \(Arg.Format.dot.rawValue)
              > 1.0.0.1
              $ xcvdetector \(Arg.Path.option) ../demo/demoApp.xcodeproj \(Arg.Bundle.option) com.companyName.demo
              > 1.0.0_1
              $ xcvdetector \(Arg.Path.option) ../demo/demoAppMac.xcodeproj \(Arg.Bundle.option) com.companyName.demo \(Arg.Platform.option) macos \(Arg.Format.option) \(Arg.Format.brackets.rawValue)
              > 1.0 (2)
            
            example format:
              \(Arg.Format.option) dot: 1.0.0.1
              \(Arg.Format.option) brackets: 1.0.0 (1)
              \(Arg.Format.option) line: 1.0.0_1
            
            example mode:
              \(Arg.Mode.option) version: 1.0.0
              \(Arg.Mode.option) build: 1
              \(Arg.Mode.option) full: 1.0.0_1 (if \(Arg.Format.option) is omitted or line)
            
            Discussion: XCVDetector will search for MARKETING_VERSION and CURRENT_PROJECT_VERSION in xcodeproj file.
            On or both of which may not be present if they was never changed in target General settings with Xcode.
            In that case the program will make attempt to located target's plist and search for CFBundleShortVersionString and CFBundleVersion,
            but result is not guaranteed.
            
            Welcome to the future!
            """
        }
        
        if argPath.isEmpty {
            let currentPath = FileManager.default.currentDirectoryPath
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: currentPath)
                for file in files {
                    if file.hasSuffix(".xcodeproj") {
                        argPath = URL(fileURLWithPath: currentPath).appendingPathComponent(file).path
                        break
                    }
                }
            } catch { /* do nothing */ }
        }
        
        if argPath.isEmpty && argBundleId.isEmpty {
            throw NSError.missingPathOrBundle
        }
        
        if argBundleId.isEmpty {
            throw NSError.missingBundle
        }
        
        let path = argPath + "/project.pbxproj"

        var isTargetSection = false
        var isBundleFound = false

        var number = String()
        var build = String()
        var sdk = String()
        var infoPlistFile = String()

        let fileContent: String
        
        do {
            fileContent = try fileReader.contentsOfFile(path: path, encoding: .utf8)
        } catch {
            throw NSError.readFile(path: path, origin: error)
        }
        
        fileContent.enumerateLines { line, stop in
            if line.contains("/* \(argConfig.name) */") {
                isTargetSection = true
            }
            
            if isTargetSection {
                if line.range(of: "MACOSX_DEPLOYMENT_TARGET") != nil {
                    sdk = Arg.Platform.macOs.sdk
                }
                if line.range(of: "IPHONEOS_DEPLOYMENT_TARGET") != nil {
                    sdk = Arg.Platform.iOS.sdk
                }
                if line.range(of: "TVOS_DEPLOYMENT_TARGET") != nil {
                    sdk = Arg.Platform.tvOs.sdk
                }
                if line.contains("PRODUCT_BUNDLE_IDENTIFIER = ") && line.contains(argBundleId) {
                    isBundleFound = true
                }
                if let range = line.range(of: "CURRENT_PROJECT_VERSION = ") {
                    build = String(line[range.upperBound..<line.index(before: line.endIndex)])
                }
                if let range = line.range(of: "MARKETING_VERSION = ") {
                    number = String(line[range.upperBound..<line.index(before: line.endIndex)])
                }
                if let range = line.range(of: "SDKROOT = ") {
                    sdk = String(line[range.upperBound..<line.index(before: line.endIndex)])
                }
                if let range = line.range(of: "INFOPLIST_FILE = ") {
                    infoPlistFile = String(line[range.upperBound..<line.index(before: line.endIndex)])
                        .replacingOccurrences(of: "\"", with: "")
                }
                
                if line.contains("name = \(argConfig.name)") {
                    isTargetSection = false
                    
                    func check() -> Bool {
                        let isSomethingFound: Bool = {
                            if sdk != argPlatform.sdk { return false }
                            
                            if argMode == .build && !build.isEmpty { return true }
                            if argMode == .version && !number.isEmpty { return true }
                            return !number.isEmpty && !build.isEmpty
                        }()
                        
                        if isBundleFound && isSomethingFound {
                            stop = true
                            return true
                        }
                        
                        return false
                    }
                    
                    if check() { return }
                    
                    if sdk == argPlatform.sdk && infoPlistFile.isEmpty.not {
                        // attempt to search in plist
                        var plistPathUrl = URL(fileURLWithPath: argPath)
                        plistPathUrl.deleteLastPathComponent()
                        plistPathUrl.appendPathComponent(infoPlistFile, isDirectory: false)
                        
                        do {
                            let data = try Data(contentsOf: plistPathUrl)
                            let decoder = PropertyListDecoder()
                            let plist = try decoder.decode(InfoPlist.self, from: data)
                            
                            number = plist.version ?? ""
                            build = plist.build ?? ""
                            
                            if check() { return }
                        } catch { /* do nothing */ }
                    }
                    
                    number  = String()
                    build   = String()
                }
            }
        }
        
        if number.isEmpty && build.isEmpty {
            throw NSError.nothinFound(argBundleId: argBundleId, argPath: argPath, argPlatform: argPlatform.name)
        }
        
        if number.isEmpty && argMode != .build {
            throw NSError.missingVersion
        }
        
        if build.isEmpty && argMode != .version {
            throw NSError.missingBuild
        }
        
        let result: String = {
            switch argMode {
            case .version: return number
            case .build: return build
            default:
                switch argFormat {
                case .dot: return "\(number).\(build)"
                case .brackets: return "\(number) (\(build))"
                default: return "\(number)_\(build)"
                }
            }
        }()

        return result
    }
    
    public func execute(arguments: [String]) throws -> String {
        try _run(arguments: arguments)
    }
    
    public func run(arguments: [String]) {
        do {
            let result = try _run(arguments: Array(arguments.dropFirst()))
            writeMessage(result)
        } catch let error as NSError {
            writeMessage(error.localizedDescription, to: .error)
        }
    }
}
