//
//  MyPageViewState.swift
//  FeatureMyPage
//
//  Created by jch on 5/13/26.
//

/// MyPage View가 표시할 상태 값입니다.
struct MyPageViewState: Equatable {
    let nickname: String
    let email: String
    var isLoggingOut: Bool = false
    var errorMessage: String?
}
