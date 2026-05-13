//
//  MyPageFactory.swift
//  FeatureMyPage
//
//  Created by jch on 5/5/26.
//

import SwiftUI

/// MyPage Feature 내부 화면 조립을 담당하는 factory입니다.
@MainActor
public struct MyPageFactory {
    /// MyPageFactory를 생성합니다.
    public init() { }

    /// MyPage root 화면을 생성합니다.
    ///
    /// - Parameters:
    ///   - onOpenSettings: 설정 화면 이동을 App 레이어에 요청하는 액션입니다.
    ///   - onLogout: 로그아웃을 App 레이어에 요청하는 액션입니다.
    /// - Returns: MyPage root SwiftUI View입니다.
    public func makeMyPageView(
        onOpenSettings: @escaping @MainActor () -> Void,
        onLogout: @escaping @MainActor () -> Void
    ) -> some View {
        MyPageView(
            onOpenSettings: onOpenSettings,
            onLogout: onLogout
        )
    }
}
