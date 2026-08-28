//
//  LoginViewController.swift
//  LottoTrip
//
//  로그인 — 디자이너 시안: 가운데 아바타 + "로그인"(검정 pill) / "게스트로 시작"(흰 pill).
//  버튼 스타일은 홈 화면(여행 가기/영상 만들기)과 동일.
//

import UIKit
import SnapKit

final class LoginViewController: UIViewController {

    private let loadingOverlay = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.card

        // 중앙 아바타 (디자이너 제공 에셋, 없으면 SF Symbol 폴백)
        let avatar = UIImageView()
        avatar.contentMode = .scaleAspectFit
        if let img = UIImage(named: "login_avatar") {
            avatar.image = img
        } else {
            avatar.image = UIImage(systemName: "person.crop.circle.fill")
            avatar.tintColor = AppColor.tileEmpty
        }
        view.addSubview(avatar)
        avatar.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-70)
            $0.size.equalTo(150)
        }

        // 로그인(검정 pill) / 게스트로 시작(흰 pill) — 홈 버튼과 동일 스타일
        let login = PrimaryButton(title: "로그인", bg: AppColor.ink, fg: .white)
        login.addTarget(self, action: #selector(loginTapped), for: .touchUpInside)
        let guest = PrimaryButton(title: "게스트로 시작", bg: .white, fg: AppColor.ink, bordered: true)
        guest.addTarget(self, action: #selector(guestTapped), for: .touchUpInside)

        let buttons = UIStackView(arrangedSubviews: [login, guest])
        buttons.axis = .vertical
        buttons.spacing = 12
        view.addSubview(buttons)
        buttons.snp.makeConstraints {
            $0.top.equalTo(avatar.snp.bottom).offset(70)
            $0.leading.trailing.equalToSuperview().inset(40)
        }

        loadingOverlay.color = AppColor.ink
        loadingOverlay.hidesWhenStopped = true
        view.addSubview(loadingOverlay)
        loadingOverlay.snp.makeConstraints { $0.center.equalToSuperview() }
    }

    // MARK: - 동작

    /// 로그인 → 소셜 로그인(현재는 데모 토큰) 성공 시 온보딩 진입
    @objc private func loginTapped() {
        setLoading(true)
        APIClient.shared.auth.login(provider: .kakao, providerToken: "MOCK_KAKAO_TOKEN") { [weak self] outcome in
            guard let self else { return }
            self.setLoading(false)
            switch outcome {
            case .success:
                self.enterApp()
            case .failure(let error):
                self.showError(error)
            }
        }
    }

    /// 게스트로 시작 → 로그인 없이 온보딩 진입
    @objc private func guestTapped() { enterApp() }

    private func enterApp() {
        let nav = UINavigationController(rootViewController: PreferenceViewController())
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }

    private func setLoading(_ loading: Bool) {
        loading ? loadingOverlay.startAnimating() : loadingOverlay.stopAnimating()
        view.isUserInteractionEnabled = !loading
    }

    private func showError(_ error: NetworkError) {
        let alert = UIAlertController(title: "로그인 실패", message: error.description, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
