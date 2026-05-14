//
//  MyPageCoordinatorProtocol.swift
//  FeatureMyPage
//
//  Created by jch on 5/13/26.
//

/// MyPage 화면 이동 요청 계약입니다.
@MainActor
public protocol MyPageCoordinatorProtocol: AnyObject {
    /// 설정 화면으로 이동합니다.
    func openSettings()
}
