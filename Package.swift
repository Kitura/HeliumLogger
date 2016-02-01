import PackageDescription

let package = Package(
    name: "HeliumLogger",
    targets: [
        Target(
            name: "HeliumLogger",
            dependencies: []),
        Target(
            name: "sample",
            dependencies: [.Target(name: "HeliumLogger")])],
    
    dependencies: [
        
    ]
    
)