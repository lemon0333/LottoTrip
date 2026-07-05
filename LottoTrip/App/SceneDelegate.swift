//
//  SceneDelegate.swift
//  LottoTrip
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        // 스크린샷/미리보기용 디버그 훅: SIMCTL_CHILD_SCREEN 환경변수로 특정 화면 바로 진입.
        let screen = ProcessInfo.processInfo.environment["SCREEN"] ?? "login"
        window.rootViewController = Self.rootViewController(for: screen)
        window.makeKeyAndVisible()
        self.window = window
    }

    private static func rootViewController(for screen: String) -> UIViewController {
        func nav(_ vc: UIViewController) -> UIViewController { UINavigationController(rootViewController: vc) }
        switch screen {
        case "tab":        return RootTabBarController()
        case "home":       return nav(PuzzleHomeViewController())
        case "slot":       return nav(SlotMachineViewController())
        case "result":     return nav(ResultViewController())
        case "mission":    return nav(MissionCaptureViewController())
        case "complete":   return nav(MissionCompleteViewController())
        case "community":  return nav(CommunityFeedViewController())
        case "chat":       return nav(ChatRoomViewController())
        case "shortform":  return nav(ShortformEditorViewController())
        case "route":      return nav(RouteViewController())
        case "preference": return nav(PreferenceViewController())
        default:           return LoginViewController()
        }
    }

    /// 로그인 성공 → 루트를 탭바로 전환 (플로우 진입점)
    static func switchRoot(to viewController: UIViewController) {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = scene.delegate as? SceneDelegate,
              let window = delegate.window else { return }
        window.rootViewController = viewController
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}
