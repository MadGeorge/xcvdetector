
# XCVDetector

## Extract project version and build number from xcodeproj from command line


## Install

**Do either:**   

- run in the shell   
```bash
git clone https://github.com/MadGeorge/xcvdetector.git /tmp/xcvdetector && /tmp/xcvdetector/make && /tmp/xcvdetector/make install && rm -rf /tmp/xcvdetector
```

- clone repo and run in the shell   
```bash
cd xcvdetector
./make
./make install
```

- clone repo and use `swift` command to build it manually
```bash
cd xcvdetector
swift build
swift build -c release
```


## Quick start  
Pass **path** to the project file and **bundle id** as arguments

```bash
$ cd $PROJECT_PATH
$ ls
SomeProjectTests README.md SomeProject SomeProject.xcodeproj
$ xcvdetector -p SomeProject.xcodeproj -b com.companyName.SomeProject
$ 1.0.0_2
$ xcvdetector -p SomeProject.xcodeproj -b com.companyName.SomeProject -f dot
$ 1.0.0.2
$ xcvdetector -p SomeProject.xcodeproj -b com.companyName.SomeProject -f brackets
$ 1.1.0 (1)
```

Use `xcvdetector -h` for detailed usage description 

## Motivation

Made for usage with CI/CD server.  Fastlane has get_version_number and get_build_number but it relies on xcodebuild's  `-showBuildSettings` which is slow and mai fail unexpectedly.   
Fastlane also has no option to return joined version + number.
