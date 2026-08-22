//
//  LoginViewController.swift
//  LottoTrip
//

import UIKit
import SnapKit

final class LoginViewController: UIViewController {

    private var socialButtons: [UIButton] = []
    private let loadingOverlay = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.coral

        // 히어로 (로고 + 슬로건)
        let logo = UIView()
        logo.backgroundColor = .white
        logo.layer.cornerRadius = 60
        let logoLabel = UILabel.make("로또\n트립", font: AppFont.bold(22), color: AppColor.coral, align: .center)
        logo.addSubview(logoLabel)
        logoLabel.snp.makeConstraints { $0.center.equalToSuperview() }
        logo.snp.makeConstraints { $0.size.equalTo(120) }

        let title = UILabel.make("여행을 운에 맡기다", font: AppFont.bold(30), color: .white, align: .center)
        let desc = UILabel.make("강원도 랜덤 슬롯 · 지도 퍼즐 완성", font: AppFont.regular(15), color: .white, align: .center)

        let hero = UIStackView(arrangedSubviews: [logo, title, desc])
        hero.axis = .vertical
        hero.alignment = .center
        hero.spacing = 16

        // 소셜 로그인 버튼 (tag = OAuthProvider rawValue 매핑용)
        let kakao = PrimaryButton(title: "카카오로 시작하기", bg: UIColor(hex: 0xFEE500), fg: AppColor.ink)
        kakao.tag = 1   // KAKAO
        let apple = PrimaryButton(title: "Apple로 계속하기", bg: AppColor.ink, fg: .white)
        let google = PrimaryButton(title: "Google로 계속하기", bg: .white, fg: AppColor.ink, bordered: true)
        google.tag = 3  // GOOGLE

        kakao.addTarget(self, action: #selector(socialTapped(_:)), for: .touchUpInside)
        google.addTarget(self, action: #selector(socialTapped(_:)), for: .touchUpInside)
        // Apple 은 백엔드 oauth_provider(KAKAO/NAVER/GOOGLE) 미지원 → 안내
        apple.addTarget(self, action: #selector(appleTapped), for: .touchUpInside)
        socialButtons = [kakao, apple, google]

        let browse = UIButton(type: .system)
        browse.setAttributedTitle(NSAttributedString(string: "로그인 없이 둘러보기",
            attributes: [.font: AppFont.medium(14), .foregroundColor: UIColor.white]), for: .normal)
        browse.addTarget(self, action: #selector(browseTapped), for: .touchUpInside)

        let bottom = UIStackView(arrangedSubviews: [kakao, apple, google, browse])
        bottom.axis = .vertical
        bottom.spacing = 12

        view.addSubview(hero)
        view.addSubview(bottom)
        hero.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(110)
            $0.leading.trailing.equalToSuperview().inset(28)
        }
        bottom.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(28)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
        }

        loadingOverlay.color = .white
        loadingOverlay.hidesWhenStopped = true
        view.addSubview(loadingOverlay)
        loadingOverlay.snp.makeConstraints { $0.center.equalToSuperview() }

        // 스크린샷/미리보기용 디버그 훅: AUTO_LOGIN=KAKAO|GOOGLE 이면 진입 직후 자동 로그인
        if let provider = ProcessInfo.processInfo.environment["AUTO_LOGIN"] {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                let proxy = UIButton(); proxy.tag = (provider == "GOOGLE" ? 3 : 1)
                self?.socialTapped(proxy)
            }
        }
    }

    // MARK: - 로그인

    @objc private func socialTapped(_ sender: UIButton) {
        let provider: OAuthProvider = sender.tag == 3 ? .google : .kakao

        // 실제 소셜 SDK 연동 전이므로 데모용 providerToken 사용.
        // (실 서버는 AUTH_001 로 거절 가능 → 에러 처리에서 안내)
        let providerToken = "MOCK_\(provider.rawValue)_TOKEN"

        setLoading(true)
        APIClient.shared.auth.login(provider: provider, providerToken: providerToken) { [weak self] outcome in
            guard let self else { return }
            self.setLoading(false)
            switch outcome {
            case .success:
                // 토큰은 AuthService 가 TokenStore 에 저장함 → 온보딩 진입
                self.enterApp()
            case .failure(let error):
                self.showLoginError(error)
            }
        }
    }

    @objc private func appleTapped() {
        let alert = UIAlertController(title: "안내",
                                      message: "Apple 로그인은 준비 중이에요. 카카오/구글로 시작해 주세요.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    /// 로그인 없이 둘러보기 (오프라인 — 네트워크 호출 없음)
    @objc private func browseTapped() { enterApp() }

    private func enterApp() {
        let nav = UINavigationController(rootViewController: PreferenceViewController())
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    // MARK: - 상태 표시

    private func setLoading(_ loading: Bool) {
        socialButtons.forEach { $0.isEnabled = !loading; $0.alpha = loading ? 0.5 : 1 }
        loading ? loadingOverlay.startAnimating() : loadingOverlay.stopAnimating()
    }

    private func showLoginError(_ error: NetworkError) {
        let message: String
        switch error.errorCode {
        case .invalidProviderToken: message = "소셜 로그인 토큰이 유효하지 않습니다."
        default:                    message = error.description
        }
        let alert = UIAlertController(title: "로그인 실패", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
