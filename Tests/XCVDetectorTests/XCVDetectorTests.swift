import XCTest
import class Foundation.Bundle
@testable import XCVDetectorLib

private extension String {
    var isHelpMessage: Bool {
        self.starts(with: "Help for XCVDetector")
    }
}

struct ValidReader: FileReader {
    func contentsOfFile(path: String, encoding: String.Encoding) throws -> String {
        validInput
    }
}

final class XCVDetectorTests: XCTestCase {
    func testNoValidArgs() throws {
        XCTAssertThrowsError(try Program(fileReader: ValidReader()).execute(arguments: [])) { error in
            XCTAssertEqual((error as NSError).code, -1)
        }
    }
    
    func testHelp() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: ["-h"])
            XCTAssertTrue(result.isHelpMessage)
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testHelpSpaced() throws {
        do {
            var result = try Program(fileReader: ValidReader()).execute(arguments: [" -h"])
            XCTAssertTrue(result.isHelpMessage)
            result = try Program(fileReader: ValidReader()).execute(arguments: ["-h "])
            XCTAssertTrue(result.isHelpMessage)
            result = try Program(fileReader: ValidReader()).execute(arguments: [" -h "])
            XCTAssertTrue(result.isHelpMessage)
            result = try Program(fileReader: ValidReader()).execute(arguments: [" -h\n"])
            XCTAssertTrue(result.isHelpMessage)
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testModeVersion() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: ["-p", "ephemeral", "-b", targetA, "-m", "version"])
            XCTAssertEqual(result, "1.6.1")
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testModeBuild() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: ["-p", "ephemeral", "-b", targetA, "-m", "build"])
            XCTAssertEqual(result, "2")
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testModeFull() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: ["-p", "ephemeral", "-b", targetA, "-m", "full"])
            XCTAssertEqual(result, "1.6.1_2")
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testModeOmitted() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: ["-p", "ephemeral", "-b", targetA])
            XCTAssertEqual(result, "1.6.1_2")
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testFormatDot() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: ["-p", "ephemeral", "-b", targetA, "-f", "dot"])
            XCTAssertEqual(result, "1.6.1.2")
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testFormatBrackets() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: ["-p", "ephemeral", "-b", targetA, "-f", "brackets"])
            XCTAssertEqual(result, "1.6.1 (2)")
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testFormatLine() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: ["-p", "ephemeral", "-b", targetA, "-f", "line"])
            XCTAssertEqual(result, "1.6.1_2")
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testFormatDefault() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: ["-p", "ephemeral", "-b", targetA])
            XCTAssertEqual(result, "1.6.1_2")
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testConfigurationDebug() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: ["-p", "ephemeral", "-b", targetA, "-c", "debug"])
            XCTAssertEqual(result, "1.6.2_5")
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testConfigurationRelease() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: ["-p", "ephemeral", "-b", targetA, "-c", "release"])
            XCTAssertEqual(result, "1.6.1_2")
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testConfigurationDefault() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: ["-p", "ephemeral", "-b", targetA])
            XCTAssertEqual(result, "1.6.1_2")
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testSecondTargetDefault() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: ["-p", "ephemeral", "-b", targetB])
            XCTAssertEqual(result, "2.1.1_32")
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testSecondTargetRelease() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: ["-p", "ephemeral", "-b", targetB, "-c", "release"])
            XCTAssertEqual(result, "2.1.1_32")
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testSecondTargetDebug() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: ["-p", "ephemeral", "-b", targetB, "-c", "debug"])
            XCTAssertEqual(result, "1.1.1_20")
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testSecondTargetDebugModeVersion() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: [
                "-p", "ephemeral",
                "-b", targetB,
                "-c", "debug",
                "-m", "version"
            ])
            XCTAssertEqual(result, "1.1.1")
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testSecondTargetDebugModeBuild() throws {
        do {
            let result = try Program(fileReader: ValidReader()).execute(arguments: [
                "-p", "ephemeral",
                "-b", targetB,
                "-c", "debug",
                "-m", "build"
            ])
            XCTAssertEqual(result, "20")
        } catch {
            XCTFail("Program not expected to throw \(error)")
        }
    }
    
    func testMissingTarget() throws {
        XCTAssertThrowsError(try Program(fileReader: ValidReader()).execute(arguments: ["-p", "ephemeral", "-b", "com.not.exist"])) { error in
            XCTAssertEqual((error as NSError).code, -2)
        }
    }
}

let targetA = "com.company.app"
let targetB = "com.company.app-dev"

let validInput = """

                    "@executable_path/Frameworks",
                );
                MARKETING_VERSION = 1.6.1;
                OTHER_SWIFT_FLAGS = "$(inherited) -D COCOAPODS -D PRODUCTION";
                PRODUCT_BUNDLE_IDENTIFIER = com.company.app;
                PRODUCT_NAME = "$(TARGET_NAME)";
                PROVISIONING_PROFILE_SPECIFIER = "";
                SWIFT_VERSION = 5.0;
                TARGETED_DEVICE_FAMILY = 1;
            };
            name = Debug;
        };
        0C09C31025BF582500937BCA /* Release */ = {
            isa = XCBuildConfiguration;
            baseConfigurationReference = 447A1F04E549677D58CC7078 /* Pods-company.release.xcconfig */;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
                CODE_SIGN_ENTITLEMENTS = company/company.entitlements;
                CODE_SIGN_IDENTITY = "Apple Development";
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 2;
                DEVELOPMENT_TEAM = 2G494W925G;
                DONT_GENERATE_INFOPLIST_FILE = NO;
                ENABLE_INCREMENTAL_DISTILL = NO;
                INFOPLIST_FILE = company/Info.plist;
                IPHONEOS_DEPLOYMENT_TARGET = 12.1;
                LD_RUNPATH_SEARCH_PATHS = (
                    "$(inherited)",
                    "@executable_path/Frameworks",
                );
                MARKETING_VERSION = 1.6.1;
                OTHER_SWIFT_FLAGS = "$(inherited) -D COCOAPODS -D PRODUCTION";
                PRODUCT_BUNDLE_IDENTIFIER = com.company.app;
                PRODUCT_NAME = "$(TARGET_NAME)";
                PROVISIONING_PROFILE_SPECIFIER = "";
                SWIFT_VERSION = 5.0;
                TARGETED_DEVICE_FAMILY = 1;
            };
            name = Release;
        };
        0C447A5825CC18C10003542D /* Debug */ = {
            isa = XCBuildConfiguration;

                MTL_ENABLE_DEBUG_INFO = NO;
                MTL_FAST_MATH = YES;
                SDKROOT = iphoneos;
                SWIFT_COMPILATION_MODE = wholemodule;
                SWIFT_OPTIMIZATION_LEVEL = "-O";
                VALIDATE_PRODUCT = YES;
            };
            name = Release;
        };
        0C09C30F25BF582500937BCA /* Debug */ = {
            isa = XCBuildConfiguration;
            baseConfigurationReference = 50D905C4DC28B27F431B62DC /* Pods-company.debug.xcconfig */;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
                CODE_SIGN_ENTITLEMENTS = company/company.entitlements;
                CODE_SIGN_IDENTITY = "Apple Development";
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 5;
                DEBUG_INFORMATION_FORMAT = dwarf;
                DEVELOPMENT_TEAM = 2G494W925G;
                DONT_GENERATE_INFOPLIST_FILE = NO;
                ENABLE_INCREMENTAL_DISTILL = NO;
                INFOPLIST_FILE = company/Info.plist;
                IPHONEOS_DEPLOYMENT_TARGET = 12.1;
                LD_RUNPATH_SEARCH_PATHS = (
                    "$(inherited)",
                    "@executable_path/Frameworks",
                );
                MARKETING_VERSION = 1.6.2;
                OTHER_SWIFT_FLAGS = "$(inherited) -D COCOAPODS -D PRODUCTION";
                PRODUCT_BUNDLE_IDENTIFIER = com.company.app;
                PRODUCT_NAME = "$(TARGET_NAME)";
                PROVISIONING_PROFILE_SPECIFIER = "";
                SWIFT_VERSION = 5.0;
                TARGETED_DEVICE_FAMILY = 1;
            };
            name = Debug;
        };
        0C09C31025BF582500937BCA /* Release */ = {
            isa = XCBuildConfiguration;
            baseConfigurationReference = 447A1F04E549677D58CC7078 /* Pods-company.release.xcconfig */;
            buildSettings = {

                MTL_ENABLE_DEBUG_INFO = NO;
                MTL_FAST_MATH = YES;
                SDKROOT = iphoneos;
                SWIFT_COMPILATION_MODE = wholemodule;
                SWIFT_OPTIMIZATION_LEVEL = "-O";
                VALIDATE_PRODUCT = YES;
            };
            name = Release;
        };
        0C09C30F25BF582500937BCA /* Debug */ = {
            isa = XCBuildConfiguration;
            baseConfigurationReference = 50D905C4DC28B27F431B62DC /* Pods-company.debug.xcconfig */;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
                ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
                CODE_SIGN_ENTITLEMENTS = company/company.entitlements;
                CODE_SIGN_IDENTITY = "Apple Development";
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 2;
                DEBUG_INFORMATION_FORMAT = dwarf;
                DEVELOPMENT_TEAM = 2G494W925G;
                DONT_GENERATE_INFOPLIST_FILE = NO;
                ENABLE_INCREMENTAL_DISTILL = NO;
                INFOPLIST_FILE = company/Info.plist;
                IPHONEOS_DEPLOYMENT_TARGET = 12.1;
                LD_RUNPATH_SEARCH_PATHS = (
                    "$(inherited)",
                    "@executable_path/Frameworks",
                );
                MARKETING_VERSION = 1.6.1;
                OTHER_SWIFT_FLAGS = "$(inherited) -D COCOAPODS -D PRODUCTION";
                PRODUCT_BUNDLE_IDENTIFIER = com.company.app;
                PRODUCT_NAME = "$(TARGET_NAME)";
                PROVISIONING_PROFILE_SPECIFIER = "";
                SWIFT_VERSION = 5.0;
                TARGETED_DEVICE_FAMILY = 1;
            };
            name = Debug;
        };
        0C09C31025BF582500937BCA /* Release */ = {
            isa = XCBuildConfiguration;
            baseConfigurationReference = 447A1F04E549677D58CC7078 /* Pods-company.release.xcconfig */;
            buildSettings = {

                OTHER_SWIFT_FLAGS = "$(inherited) -D COCOAPODS -D PRODUCTION";
                PRODUCT_BUNDLE_IDENTIFIER = com.company.app;
                PRODUCT_NAME = "$(TARGET_NAME)";
                PROVISIONING_PROFILE_SPECIFIER = "";
                SWIFT_VERSION = 5.0;
                TARGETED_DEVICE_FAMILY = 1;
            };
            name = Release;
        };
        0C447A5825CC18C10003542D /* Debug */ = {
            isa = XCBuildConfiguration;
            baseConfigurationReference = 80ABE30FF3E02C3FC45ED0CD /* Pods-company-dev.debug.xcconfig */;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = "AppIcon-dev";
                ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
                CODE_SIGN_ENTITLEMENTS = "company/company-dev.entitlements";
                CODE_SIGN_IDENTITY = "Apple Development";
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 20;
                DEVELOPMENT_TEAM = 2G494W925G;
                INFOPLIST_FILE = "company/Info-dev.plist";
                IPHONEOS_DEPLOYMENT_TARGET = 12.1;
                LD_RUNPATH_SEARCH_PATHS = (
                    "$(inherited)",
                    "@executable_path/Frameworks",
                );
                MARKETING_VERSION = 1.1.1;
                OTHER_SWIFT_FLAGS = "$(inherited) -D COCOAPODS -D DEVELOPMENT";
                PRODUCT_BUNDLE_IDENTIFIER = "com.company.app-dev";
                PRODUCT_NAME = "$(TARGET_NAME)";
                PROVISIONING_PROFILE_SPECIFIER = "";
                SWIFT_VERSION = 5.0;
                TARGETED_DEVICE_FAMILY = 1;
            };
            name = Debug;
        };
        0C447A5925CC18C10003542D /* Release */ = {
            isa = XCBuildConfiguration;
            baseConfigurationReference = 83AC41F32D8F8592EF0B201A /* Pods-company-dev.release.xcconfig */;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = "AppIcon-dev";


                PRODUCT_BUNDLE_IDENTIFIER = "com.company.app-dev";
                PRODUCT_NAME = "$(TARGET_NAME)";
                PROVISIONING_PROFILE_SPECIFIER = "";
                SWIFT_VERSION = 5.0;
                TARGETED_DEVICE_FAMILY = 1;
            };
            name = Debug;
        };
        0C447A5925CC18C10003542D /* Release */ = {
            isa = XCBuildConfiguration;
            baseConfigurationReference = 83AC41F32D8F8592EF0B201A /* Pods-company-dev.release.xcconfig */;
            buildSettings = {
                ASSETCATALOG_COMPILER_APPICON_NAME = "AppIcon-dev";
                ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
                CODE_SIGN_ENTITLEMENTS = "company/company-dev.entitlements";
                CODE_SIGN_IDENTITY = "Apple Development";
                CODE_SIGN_STYLE = Automatic;
                CURRENT_PROJECT_VERSION = 32;
                DEVELOPMENT_TEAM = 2G494W925G;
                INFOPLIST_FILE = "company/Info-dev.plist";
                IPHONEOS_DEPLOYMENT_TARGET = 12.1;
                LD_RUNPATH_SEARCH_PATHS = (
                    "$(inherited)",
                    "@executable_path/Frameworks",
                );
                MARKETING_VERSION = 2.1.1;
                OTHER_SWIFT_FLAGS = "$(inherited) -D COCOAPODS -D DEVELOPMENT";
                PRODUCT_BUNDLE_IDENTIFIER = "com.company.app-dev";
                PRODUCT_NAME = "$(TARGET_NAME)";
                PROVISIONING_PROFILE_SPECIFIER = "";
                SWIFT_VERSION = 5.0;
                TARGETED_DEVICE_FAMILY = 1;
            };
            name = Release;
        };
        5E3137E82678FEBE00BEE63B /* Debug */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                BUNDLE_LOADER = "$(TEST_HOST)";
                CODE_SIGN_STYLE = Automatic;
                DEVELOPMENT_TEAM = 2G494W925G;
                INFOPLIST_FILE = HelpersTests/Info.plist;
                IPHONEOS_DEPLOYMENT_TARGET = 12.1;


            name = Debug;
        };
        5E3137E92678FEBE00BEE63B /* Release */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                BUNDLE_LOADER = "$(TEST_HOST)";
                CODE_SIGN_STYLE = Automatic;
                DEVELOPMENT_TEAM = 2G494W925G;
                INFOPLIST_FILE = HelpersTests/Info.plist;
                IPHONEOS_DEPLOYMENT_TARGET = 12.1;
                LD_RUNPATH_SEARCH_PATHS = (
                    "$(inherited)",
                    "@executable_path/Frameworks",
                    "@loader_path/Frameworks",
                );
                PRODUCT_BUNDLE_IDENTIFIER = com.company.app.HelpersTests;
                PRODUCT_NAME = "$(TARGET_NAME)";
                SWIFT_VERSION = 5.0;
                TARGETED_DEVICE_FAMILY = "1,2";
                TEST_HOST = "$(BUILT_PRODUCTS_DIR)/company-dev.app/company-dev";
            };
            name = Release;
        };
        5E31380B2678FFC100BEE63B /* Debug */ = {
            isa = XCBuildConfiguration;


            };
            name = Release;
        };
        5E31381A267900A600BEE63B /* Debug */ = {
            isa = XCBuildConfiguration;
            buildSettings = {
                BUNDLE_LOADER = "$(TEST_HOST)";
                CODE_SIGN_STYLE = Automatic;
                DEVELOPMENT_TEAM = 2G494W925G;
                INFOPLIST_FILE = RouteParsingTests/Info.plist;
                IPHONEOS_DEPLOYMENT_TARGET = 12.1;
                LD_RUNPATH_SEARCH_PATHS = (
                    "$(inherited)",
                    "@executable_path/Frameworks",
                    "@loader_path/Frameworks",
                );
                PRODUCT_BUNDLE_IDENTIFIER = com.company.app.RouteParsingTests;
                PRODUCT_NAME = "$(TARGET_NAME)";
                SWIFT_VERSION = 5.0;
                TARGETED_DEVICE_FAMILY = "1,2";
                TEST_HOST = "$(BUILT_PRODUCTS_DIR)/company-dev.app/company-dev";
            };
            name = Debug;
        };
        5E31381B267900A600BEE63B /* Release */ = {

"""
