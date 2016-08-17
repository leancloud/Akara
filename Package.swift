import PackageDescription

let package = Package(
    name: "Akara",
    dependencies: [
        .Package(url: "https://github.com/leancloud/Surl.git", majorVersion: 0, minor: 0)
    ]
)
