//
//  MyPageView.swift
//  FeatureMyPage
//
//  Created by jch on 4/28/26.
//

import SwiftUI
import DesignSystem

struct MyPageView: View {
    let onOpenSettings: @MainActor () -> Void
    let onLogout: @MainActor () -> Void

    var body: some View {
        List {
            Section("계정") {
                HStack(spacing: DSSpacing.sm) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: DSIconSize.xxl))
                        .foregroundStyle(DSColor.primary)

                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text("마이페이지")
                            .font(DSTypography.headline)
                        Text("로그인된 사용자")
                            .font(DSTypography.body2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, DSSpacing.sm)
            }

            Section("메뉴") {
                Button("설정") {
                    Task { @MainActor in
                        onOpenSettings()
                    }
                }

                Button(role: .destructive) {
                    Task { @MainActor in
                        onLogout()
                    }
                } label: {
                    Text("로그아웃")
                }
            }
        }
        .navigationTitle("마이페이지")
    }
}
