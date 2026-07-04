import ProjectDescription

let project = Project(
    name: "Grooz",
    targets: [
        .target(
            name: "Grooz",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.Grooz",
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "Grooz/Sources",
                "Grooz/Resources",
            ],
            dependencies: []
        ),
        .target(
            name: "GroozTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "dev.tuist.GroozTests",
            infoPlist: .default,
            buildableFolders: [
                "Grooz/Tests"
            ],
            dependencies: [.target(name: "Grooz")]
        ),
    ]
)
