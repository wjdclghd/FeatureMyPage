//
//  MyPageViewModel.swift
//  FeatureMyPage
//
//  Created by jch on 5/13/26.
//

import Foundation

/// MyPage 화면 상태와 사용자 Intent를 관리합니다.
@MainActor
final class MyPageViewModel<
    LogoutUseCase: MyPageLogoutUseCaseProtocol,
    Coordinator: MyPageCoordinatorProtocol
>: ObservableObject {

    // MARK: - Output

    @Published private(set) var viewState: MyPageViewState

    // MARK: - Dependencies

    private let logoutUseCase: LogoutUseCase
    private let coordinator: Coordinator

    // MARK: - Init

    init(
        logoutUseCase: LogoutUseCase,
        coordinator: Coordinator,
        nickname: String,
        email: String
    ) {
        self.logoutUseCase = logoutUseCase
        self.coordinator = coordinator
        self.viewState = MyPageViewState(nickname: nickname, email: email)
    }

    // MARK: - Intent

    @discardableResult
    func logoutButtonTapped() -> Task<Void, Never> {
        Task { await performLogout() }
    }

    func settingsButtonTapped() {
        coordinator.openSettings()
    }

    // MARK: - Private

    private func performLogout() async {
        guard viewState.isLoggingOut == false else { return }
        viewState.isLoggingOut = true
        viewState.errorMessage = nil

        do {
            try await logoutUseCase.execute()
            viewState.isLoggingOut = false
        } catch {
            viewState.isLoggingOut = false
            viewState.errorMessage = "로그아웃 처리에 실패했습니다. 다시 시도해 주세요."
        }
    }
}
