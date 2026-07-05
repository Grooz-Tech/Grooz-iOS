import ProjectDescription

let teamId = "BWTLDG8C39"

let appBundleId = "tech.grooz.app"

let appDisplayName = "Grooz"

let appVersion = "1.0.0"

let buildNumber = Environment.currentProjectVersion.getString(default: "1")

let appSigningSettings = Settings.settings(
    base: [
        "DEVELOPMENT_TEAM": .string(teamId),
        "CODE_SIGN_STYLE": "Manual",
        "MARKETING_VERSION": .string(appVersion),
        "CURRENT_PROJECT_VERSION": .string(buildNumber),
        "INFOPLIST_KEY_CFBundleDisplayName": .string(appDisplayName),
    ],
    configurations: [
        .debug(
            name: "Debug",
            settings: [
                "CODE_SIGN_IDENTITY": "Apple Development",
                "PROVISIONING_PROFILE_SPECIFIER": "match Development \(appBundleId)",
            ]
        ),
        .release(
            name: "Release",
            settings: [
                "CODE_SIGN_IDENTITY": "Apple Distribution",
                "PROVISIONING_PROFILE_SPECIFIER": "match AppStore \(appBundleId)",
            ]
        ),
    ]
)

let project = Project(
    name: "Grooz",
    targets: [
        .target(
            name: "Grooz",
            destinations: [.iPhone],
            product: .app,
            bundleId: appBundleId,
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "$(INFOPLIST_KEY_CFBundleDisplayName)",
                    "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                    "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                    "ITSAppUsesNonExemptEncryption": false,
                    "UILaunchScreen": [
                        "UIColorName": "LaunchBackground",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "Grooz/Sources",
                "Grooz/Resources",
            ],
            dependencies: [],
            settings: appSigningSettings
        ),
        .target(
            name: "GroozTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "\(appBundleId).GroozTests",
            infoPlist: .default,
            buildableFolders: [
                "Grooz/Tests"
            ],
            dependencies: [.target(name: "Grooz")],
            settings: .settings(base: ["DEVELOPMENT_TEAM": .string(teamId)])
        ),
    ]
)
