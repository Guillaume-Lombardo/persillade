// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PersilladeCore",
    platforms: [.iOS("27.0"), .macOS(.v15)],
    products: [
        .library(name: "PersilladeCore", targets: ["PersilladeCore"]),
        .library(name: "PersilladePlateforme", targets: ["PersilladePlateforme"]),
    ],
    targets: [
        .target(name: "PersilladeCore"),
        .target(name: "PersilladePlateforme", dependencies: ["PersilladeCore"]),
        .testTarget(
            name: "PersilladeCoreTests", dependencies: ["PersilladeCore"],
            resources: [.copy("Fixtures")]),
        .testTarget(
            name: "PersilladePlateformeTests", dependencies: ["PersilladeCore", "PersilladePlateforme"],
            resources: [.copy("CorpusExtraction")]),
    ],
    swiftLanguageModes: [.v6]
)
