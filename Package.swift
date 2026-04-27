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
        
    ],
    targets: [
        .target(
            name: "FeatureMyPage",
            dependencies: [
                
            ],
            path: "Sources/FeatureMyPage",
            linkerSettings: [
                
            ]
        ),
        .testTarget(
            name: "FeatureMyPageTests",
            dependencies: [
                
            ],
            path: "Tests/FeatureMyPageTests",
            linkerSettings: [
                
            ]
        )
    ]
)
