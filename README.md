# FeatureMyPage Module

Clean Architecture + MVVM 환경에서 App Target이 SPM 모듈로 의존하는 형태를 전제로 만든 마이페이지 Feature 모듈입니다.
이 모듈은 **로그인된 사용자의 프로필 표시, 설정 이동, 로그아웃 요청** 역할에 집중하며, App layer의 세션 관리 타입과 인프라 구현을 직접 알지 않고 **공개 계약 + ViewModel + View**로 역할을 분리합니다.

모듈 내부는 로그아웃 UseCase Protocol을 자체 정의해 App layer가 구현을 주입하는 방식으로 동작하며,
상위 계층은 `MyPageFactory.makeMyPageView(...)`를 통해 화면을 즉시 조립할 수 있습니다.

**요약**
- 조립 진입점: `MyPageFactory`
- 공개 계약: `MyPageCoordinatorProtocol`, `MyPageLogoutUseCaseProtocol`
- 화면: `MyPageView` — 프로필 표시, 설정 이동, 로그아웃
- 상태 관리: `MyPageViewModel` + `MyPageViewState`
- 로그아웃: ViewModel이 `MyPageLogoutUseCaseProtocol`을 직접 `execute()`
- 화면 이동: `MyPageCoordinatorProtocol.showSettings()`만 담당
- 프로필 데이터: `nickname`, `email` primitive를 App layer에서 주입
- 모듈 의존: DesignSystem 전용 (AppDomain 의존 없음)

---

**모듈 구조**
```text
FeatureMyPage/
├── Package.swift
├── Sources/
│   └── FeatureMyPage/
│       ├── Coordinator/
│       │   └── MyPageCoordinatorProtocol.swift
│       ├── UseCases/
│       │   └── MyPageLogoutUseCaseProtocol.swift
│       ├── Factory/
│       │   └── MyPageFactory.swift
│       └── Scenes/
│           └── MyPage/
│               ├── View/
│               │   └── MyPageView.swift
│               └── ViewModel/
│                   ├── MyPageViewModel.swift
│                   └── MyPageViewState.swift
└── Tests/
    └── FeatureMyPageTests/
        ├── ViewModels/
        │   └── MyPageViewModelTests.swift
        └── TestDoubles/
            ├── Stubs/
            │   └── StubMyPageLogoutUseCase.swift
            ├── Spies/
            │   └── SpyMyPageCoordinator.swift
            └── Fixtures/
```

---

**빠른 시작**

`MyPageFactory.makeMyPageView(...)`는 조립된 `MyPageView`를 즉시 반환합니다.

```swift
import FeatureMyPage

// App layer — AccountRouteBuilder에서 조립
let view = MyPageFactory.makeMyPageView(
    logoutUseCase: sessionLogoutAdapter,   // MyPageLogoutUseCaseProtocol 구현체
    coordinator: navigator,                 // MyPageCoordinatorProtocol 구현체
    nickname: session.nickname,
    email: session.email
)
```

App layer는 `SessionLogoutUseCase`를 `MyPageLogoutUseCaseProtocol`로 감싼 어댑터를 생성해 주입합니다.

```swift
// App Target — SessionLogoutUseCase 어댑터
struct MyPageLogoutUseCaseAdapter: MyPageLogoutUseCaseProtocol {
    private let sessionLogoutUseCase: SessionLogoutUseCase

    func execute() async throws {
        try await sessionLogoutUseCase.execute()
    }
}
```

로그아웃 성공 후 화면 전환은 App layer의 `SessionController` 상태 변화로 자동 처리됩니다. Feature는 화면 전환에 직접 관여하지 않습니다.

테스트 환경에서는 Stub을 주입합니다.

```swift
import FeatureMyPage

let view = MyPageFactory.makeMyPageView(
    logoutUseCase: StubMyPageLogoutUseCase(),
    coordinator: SpyMyPageCoordinator(),
    nickname: "테스트유저",
    email: "test@example.com"
)
```

---

**핵심 설계 방향**

- **Feature 자체 UseCase Protocol 정의 (Dependency Inversion)**
  App layer의 `SessionLogoutUseCase`는 refreshToken을 내부에서 처리하는 App Target 전용 타입입니다. Feature → App Target 직접 의존은 아키텍처 원칙상 금지이므로, FeatureMyPage가 `MyPageLogoutUseCaseProtocol { func execute() async throws }`를 직접 정의합니다. App layer는 이 계약에 맞는 어댑터를 주입합니다.

- **CoordinatorProtocol은 화면 이동 계약만 담당**
  `MyPageCoordinatorProtocol`은 `showSettings()` 하나만 선언합니다. 로그아웃은 비즈니스 액션이므로 Coordinator 책임에 포함하지 않습니다. App layer의 `AccountNavigator`가 이 Protocol을 채택합니다.

- **ViewModel이 UseCase를 직접 실행**
  `MyPageViewModel`이 `MyPageLogoutUseCaseProtocol.execute()`를 직접 호출합니다. 로그아웃 성공·실패 결과는 `viewState.loadState`에 반영됩니다. Coordinator에 비즈니스 위임을 하지 않습니다.

- **프로필 데이터는 primitive 주입**
  App Target의 `UserSession` 타입을 Feature에 직접 노출하면 Feature → App Target 의존이 생깁니다. App layer가 `nickname: String`, `email: String`을 추출해 Factory에 전달합니다.

---

**MyPageCoordinatorProtocol**

`MyPageCoordinatorProtocol`은 MyPage 화면에서 App layer로 전달하는 화면 이동 계약입니다.

```swift
@MainActor
public protocol MyPageCoordinatorProtocol: AnyObject {
    func showSettings()
}
```

규칙:
- 메서드만 선언합니다.
- 로그아웃 관련 메서드는 포함하지 않습니다.
- App layer의 `AccountNavigator`가 이 Protocol을 채택해 `AccountRoute.settings`로 push합니다.

---

**MyPageLogoutUseCaseProtocol**

`MyPageLogoutUseCaseProtocol`은 FeatureMyPage가 직접 정의하는 로그아웃 실행 계약입니다.

```swift
public protocol MyPageLogoutUseCaseProtocol: Sendable {
    func execute() async throws
}
```

규칙:
- refreshToken 파라미터를 받지 않습니다. 인프라 관심사는 App layer 구현체 내부에서 처리합니다.
- App layer가 `SessionLogoutUseCase`를 감싼 어댑터를 구현해 주입합니다.
- 테스트에서는 `StubMyPageLogoutUseCase`로 대체합니다.

---

**MyPageFactory**

`MyPageFactory`는 MyPage Feature 화면 조립을 담당하는 진입점입니다.

```swift
@MainActor
public enum MyPageFactory {
    public static func makeMyPageView<
        LogoutUseCase: MyPageLogoutUseCaseProtocol,
        Coordinator: MyPageCoordinatorProtocol
    >(
        logoutUseCase: LogoutUseCase,
        coordinator: Coordinator,
        nickname: String,
        email: String
    ) -> MyPageView<LogoutUseCase, Coordinator>
}
```

규칙:
- `UseCase`와 `Coordinator`를 제네릭으로 주입받습니다.
- ViewModel 생성과 View 조립만 담당합니다.
- `SessionLogoutUseCase`, `SessionController`, `DIContainer`를 직접 알지 않습니다.

---

**MyPageViewModel**

`MyPageViewModel`은 MyPage 화면의 ViewState와 사용자 Intent를 관리합니다.

```swift
@MainActor
public final class MyPageViewModel<
    LogoutUseCase: MyPageLogoutUseCaseProtocol,
    Coordinator: MyPageCoordinatorProtocol
>: ObservableObject {

    @Published public private(set) var viewState: MyPageViewState

    private let logoutUseCase: LogoutUseCase
    private let coordinator: Coordinator

    // Intent
    public func settingsButtonTapped()
    public func logoutButtonTapped() -> Task<Void, Never>
}
```

규칙:
- `viewState`를 단일 Output으로 노출합니다.
- `settingsButtonTapped()` → `coordinator.showSettings()` 호출합니다.
- `logoutButtonTapped()` → `logoutUseCase.execute()` 직접 호출 → `viewState.loadState` 갱신합니다.
- 로그아웃 성공 후 화면 전환은 App layer `SessionController` 상태 변화로 자동 처리되므로 ViewModel이 관여하지 않습니다.
- `App Target` 타입(`AccountNavigator`, `SessionController`, `DIContainer`)을 직접 알지 않습니다.

---

**MyPageViewState**

`MyPageViewState`는 ViewModel이 View에 노출하는 UI 상태 전체를 하나의 타입으로 묶은 구조체입니다.

```swift
public struct MyPageViewState: Equatable {
    public var nickname: String
    public var email: String
    public var loadState: LoadState = .idle
}

extension MyPageViewState {
    public enum LoadState: Equatable {
        case idle
        case loading
        case failure
    }
}
```

규칙:
- 값 타입(`struct`)으로 선언합니다.
- `LoadState`는 로그아웃 진행 중 상태와 실패 상태를 표현합니다.
- 로그아웃 성공은 App layer `SessionController` 상태 전환으로 처리되므로 `.success` case는 없습니다.
- View는 `viewState`를 직접 변경하지 않습니다. ViewModel Intent 메서드를 통해서만 변경됩니다.

---

**테스트**

ViewModel Intent와 ViewState 전환을 중심으로 단위 테스트를 작성합니다.

```swift
/// `MyPageViewModel`의 viewState.loadState 전환과 Intent 흐름을 검증합니다.
final class MyPageViewModelTests: XCTestCase {

    @MainActor
    func test_logoutButtonTapped_onSuccess_doesNotUpdateLoadStateToFailure() async {
        // given
        let (sut, logoutUseCase, _) = makeSUT()
        logoutUseCase.stubbedResult = .success(())

        // when
        await sut.logoutButtonTapped().value

        // then
        XCTAssertEqual(sut.viewState.loadState, .idle)
    }

    @MainActor
    func test_logoutButtonTapped_onFailure_updatesLoadStateToFailure() async {
        // given
        let (sut, logoutUseCase, _) = makeSUT()
        logoutUseCase.stubbedResult = .failure(NSError(domain: "test", code: -1))

        // when
        await sut.logoutButtonTapped().value

        // then
        XCTAssertEqual(sut.viewState.loadState, .failure)
    }

    @MainActor
    func test_settingsButtonTapped_callsCoordinatorShowSettings() {
        // given
        let (sut, _, coordinator) = makeSUT()

        // when
        sut.settingsButtonTapped()

        // then
        XCTAssertEqual(coordinator.showSettingsCallCount, 1)
    }

    @MainActor
    private func makeSUT() -> (
        sut: MyPageViewModel<StubMyPageLogoutUseCase, SpyMyPageCoordinator>,
        logoutUseCase: StubMyPageLogoutUseCase,
        coordinator: SpyMyPageCoordinator
    ) {
        let logoutUseCase = StubMyPageLogoutUseCase()
        let coordinator = SpyMyPageCoordinator()
        let sut = MyPageViewModel(
            logoutUseCase: logoutUseCase,
            coordinator: coordinator,
            nickname: "테스트유저",
            email: "test@example.com"
        )
        return (sut, logoutUseCase, coordinator)
    }
}
```

테스트 전략:
- `StubMyPageLogoutUseCase`로 로그아웃 성공·실패 시나리오를 주입합니다.
- `SpyMyPageCoordinator`로 `showSettings()` 호출 여부와 횟수를 검증합니다.
- `@MainActor makeSUT()` helper 패턴을 사용합니다. 테스트 클래스 전체에 `@MainActor`를 선언하지 않습니다.
- 비동기 Intent는 `Task.value`로 완료를 보장합니다. `Task.yield()`는 사용하지 않습니다.

---

**권장 사용 전략**
- App layer는 `MyPageFactory`와 공개 계약 타입(`MyPageCoordinatorProtocol`, `MyPageLogoutUseCaseProtocol`)을 기준으로 의존성을 설계합니다.
- `MyPageViewModel`, `MyPageViewState`, `MyPageView` 내부 타입을 App layer에서 직접 참조하지 않습니다.
- `AccountNavigator`는 `MyPageCoordinatorProtocol`을 채택해 `showSettings()`만 구현합니다.
- `SessionLogoutUseCase`를 `MyPageLogoutUseCaseProtocol`로 감싼 어댑터는 `AccountRouteBuilder` 또는 `DIContainer` 조립 단계에서 생성합니다.
- 로그아웃 성공 후 화면 전환은 `SessionController.signOut()`에 의한 `loginState` 변화로 처리합니다. Feature 내부에서 화면 전환 로직을 작성하지 않습니다.

---

**권장 확장 방식**
1. `Coordinator/MyPageCoordinatorProtocol.swift`에 화면 이동 메서드 추가 (예: `showProfileEdit()`)
2. `UseCases/`에 새 UseCase Protocol 추가 (예: `MyPageFetchProfileUseCaseProtocol`)
3. `Scenes/`에 새 화면 폴더 추가 (예: `Scenes/ProfileEdit/`)
4. `Package.swift`에 AppDomain 의존성 추가 (프로필 수정 등 도메인 로직이 필요한 시점)
5. 기능 전용 테스트 추가

---

Created by: jch  
Updated: May 2026
