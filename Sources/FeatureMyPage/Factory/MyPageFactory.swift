//
//  MyPageFactory.swift
//  FeatureMyPage
//
//  Created by jch on 5/5/26.
//

import SwiftUI

/// MyPage Feature 내부 화면 조립을 담당하는 factory입니다.
@MainActor
public enum MyPageFactory {
    /// MyPage root 화면을 생성합니다.
    ///
    /// - Parameters:
    ///   - logoutUseCase: 로그아웃을 수행하는 UseCase입니다.
    ///   - coordinator: MyPage 화면 이동 계약 구현체입니다.
    ///   - nickname: 표시할 사용자 닉네임입니다.
    ///   - email: 표시할 사용자 이메일입니다.
    /// - Returns: MyPage root SwiftUI View입니다.
    public static func makeMyPageView<
        LogoutUseCase: MyPageLogoutUseCaseProtocol,
        Coordinator: MyPageCoordinatorProtocol
    >(
        logoutUseCase: LogoutUseCase,
        coordinator: Coordinator,
        nickname: String,
        email: String
    ) -> some View {
        let viewModel = MyPageViewModel(
            logoutUseCase: logoutUseCase,
            coordinator: coordinator,
            nickname: nickname,
            email: email
        )
        return MyPageView(viewModel: viewModel)
    }
}
