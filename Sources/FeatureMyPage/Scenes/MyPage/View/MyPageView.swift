//
//  MyPageView.swift
//  FeatureMyPage
//
//  Created by jch on 4/28/26.
//

import SwiftUI
import DesignSystem

struct MyPageView<
    LogoutUseCase: MyPageLogoutUseCaseProtocol,
    Coordinator: MyPageCoordinatorProtocol
>: View {

    @StateObject private var viewModel: MyPageViewModel<LogoutUseCase, Coordinator>

    init(viewModel: MyPageViewModel<LogoutUseCase, Coordinator>) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        List {
            Section("계정") {
                HStack(spacing: DSSpacing.sm) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: DSIconSize.xxl))
                        .foregroundStyle(DSColor.primary)

                    VStack(alignment: .leading, spacing: DSSpacing.xs) {
                        Text(viewModel.viewState.nickname)
                            .font(DSTypography.headline)
                        Text(viewModel.viewState.email)
                            .font(DSTypography.body2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, DSSpacing.sm)
            }

            Section("메뉴") {
                Button("설정") {
                    viewModel.settingsButtonTapped()
                }

                Button(role: .destructive) {
                    viewModel.logoutButtonTapped()
                } label: {
                    if viewModel.viewState.isLoggingOut {
                        ProgressView()
                    } else {
                        Text("로그아웃")
                    }
                }
                .disabled(viewModel.viewState.isLoggingOut)
            }

            if let errorMessage = viewModel.viewState.errorMessage {
                Section {
                    Text(errorMessage)
                        .font(DSTypography.body2)
                        .foregroundStyle(DSColor.error)
                }
            }
        }
        .navigationTitle("마이페이지")
    }
}
