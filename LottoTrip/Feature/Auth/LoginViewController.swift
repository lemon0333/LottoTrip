//
//  LoginViewController.swift
//  LottoTrip
//

import UIKit
import SnapKit

final class LoginViewController: UIViewController {

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

        // 소셜 로그인 버튼
        let kakao = PrimaryButton(title: "카카오로 시작하기", bg: UIColor(hex: 0xFEE500), fg: AppColor.ink)
        let apple = PrimaryButton(title: "Apple로 계속하기", bg: AppColor.ink, fg: .white)
        let google = PrimaryButton(title: "Google로 계속하기", bg: .white, fg: AppColor.ink, bordered: true)
        [kakao, apple, google].forEach { $0.addTarget(self, action: #selector(enterTapped), for: .touchUpInside) }

        let browse = UIButton(type: .system)
        browse.setAttributedTitle(NSAttributedString(string: "로그인 없이 둘러보기",
            attributes: [.font: AppFont.medium(14), .foregroundColor: UIColor.white]), for: .normal)
        browse.addTarget(self, action: #selector(enterTapped), for: .touchUpInside)

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
    }

    @objc private func enterTapped() {
        let nav = UINavigationController(rootViewController: PreferenceViewController())
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}
