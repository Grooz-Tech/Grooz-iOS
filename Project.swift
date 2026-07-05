import ProjectDescription

let teamId = "BWTLDG8C39"

let appBundleId = "tech.grooz.app"

let appDisplayName = "Grooz"

// MARKETING_VERSION comes from Version.xcconfig (source of truth, bumped per release).
// Build number is supplied by CI via TUIST_CURRENT_PROJECT_VERSION (github.run_number).
let buildNumber = Environment.currentProjectVersion.getString(default: "1")

let appSigningSettings = Settings.settings(
    base: [
        "DEVELOPMENT_TEAM": .string(teamId),
        "CODE_SIGN_STYLE": "Manual",
        "CURRENT_PROJECT_VERSION": .string(buildNumber),
        "INFOPLIST_KEY_CFBundleDisplayName": .string(appDisplayName),
    ],
    configurations: [
        .debug(
            name: "Debug",
            settings: [
                "CODE_SIGN_IDENTITY": "Apple Development",
                "PROVISIONING_PROFILE_SPECIFIER": "match Development \(appBundleId)",
            ],
            xcconfig: "Version.xcconfig"
        ),
        .release(
            name: "Release",
            settings: [
                "CODE_SIGN_IDENTITY": "Apple Distribution",
                "PROVISIONING_PROFILE_SPECIFIER": "match AppStore \(appBundleId)",
            ],
            xcconfig: "Version.xcconfig"
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
            deploymentTargets: .iOS("18.0"),
            infoPlist: .extendingDefault(
                with: [
                    "CFBundleDisplayName": "$(INFOPLIST_KEY_CFBundleDisplayName)",
                    "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                    "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                    "ITSAppUsesNonExemptEncryption": false,
                    "UISupportedInterfaceOrientations": [
                        "UIInterfaceOrientationPortrait",
                    ],
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
            dependencies: [
                .external(name: "GRDB"),
                .external(name: "Alamofire"),
                .external(name: "Collections"),
            ],
            settings: appSigningSettings
        ),
        .target(
            name: "GroozTests",
            destinations: [.iPhone],
            product: .unitTests,
            bundleId: "\(appBundleId).GroozTests",
            deploymentTargets: .iOS("18.0"),
            infoPlist: .default,
            buildableFolders: [
                "Grooz/Tests"
            ],
            dependencies: [.target(name: "Grooz")],
            settings: .settings(base: ["DEVELOPMENT_TEAM": .string(teamId)])
        ),
    ]
)
