import Foundation
import XCVDetectorLib

struct DefaultReader: FileReader {
    func contentsOfFile(path: String, encoding: String.Encoding) throws -> String {
        try String(contentsOfFile: path, encoding: encoding)
    }
}

Program(fileReader: DefaultReader()).run(arguments: CommandLine.arguments)
