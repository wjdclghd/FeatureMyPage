// swift-tools-version: 6.0
//
//  Package.swift
//  FeatureMyPage
//
//  Created by jch on 4/27/26.
//

import PackageDescription

let package = Package(
    name: "FeatureMyPage",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "FeatureMyPage",
            targets: ["FeatureMyPage"]
        )
    ],
    dependencies: [
        .package(path: "../../Core/UI/DesignSystem")
    ],
    targets: [
        .target(
            name: "FeatureMyPage",
            dependencies: [
                "DesignSystem"
            ],
            path: "Sources/FeatureMyPage",
            linkerSettings: [

            ]
        ),
        .testTarget(
            name: "FeatureMyPageTests",
            dependencies: [
                "FeatureMyPage",
                "DesignSystem"
            ],
            path: "Tests/FeatureMyPageTests",
            linkerSettings: [

            ]
        )
    ]
)
