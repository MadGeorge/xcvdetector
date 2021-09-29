# XCVDetector

## Extract project version and build number from xcodeproj from command line


## Quick start

Pass path to the project file and bundle id as arguments

```bash
$ cd $PROJECT_PATH
$ ls
SomeProjectTests     README.md     SomeProject     SomeProject.xcodeproj
$ xcvdetector -p SomeProject.xcodeproj -b com.companyName.SomeProject
$ 1.0.0_2
$ xcvdetector -p SomeProject.xcodeproj -b com.companyName.SomeProject -f dot
$ 1.0.0.2
$ xcvdetector -p SomeProject.xcodeproj -b com.companyName.SomeProject -f brackets
$ 1.1.0 (1)
```
## Motivation

Made for usage on CI/CD server.  Fastlane has get_version_number and get_build_number but it relies on xcodebuild's  `-showBuildSettings` which is slow and mai fail unexpectedly.   
Fastlane also has no option to return joined version + number.

