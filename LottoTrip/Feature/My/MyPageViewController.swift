//
//  MyPageViewController.swift
//  LottoTrip
//

import UIKit
import SnapKit

final class MyPageViewController: BaseScrollViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "MY"
        contentStack.spacing = 16

        // 프로필
        let avatar = UIView()
        avatar.backgroundColor = AppColor.cafe
        avatar.layer.cornerRadius = 32
        avatar.snp.makeConstraints { $0.size.equalTo(64) }
        // 아바타 이니셜 (닉네임 첫 글자)
        let initial = UILabel.make("감", font: AppFont.bold(24), color: .white, align: .center)
        avatar.addSubview(initial)
        initial.snp.makeConstraints { $0.center.equalToSuperview() }
        let name = UILabel.make("감자탐험가", font: AppFont.bold(18), color: AppColor.ink)
        let sub = UILabel.make("강원 운명 공동체 · 5/8 조각", font: AppFont.medium(13), color: AppColor.sub)
        let nameCol = UIStackView(arrangedSubviews: [name, sub])
        nameCol.axis = .vertical
        nameCol.spacing = 4
        let profile = UIStackView(arrangedSubviews: [avatar, nameCol])
        profile.axis = .horizontal
        profile.spacing = 14
        profile.alignment = .center
        contentStack.addArrangedSubview(profile)

        // 메뉴 — 흰 카드 리스트 (행 사이 구분선)
        let card = CardView(spacing: 0, padding: 4)
        let items = ["내 코스 기록", "획득 뱃지", "포인트 · 쿠폰", "알림 설정", "로그아웃"]
        for (index, title) in items.enumerated() {
            // 로그아웃은 코랄 강조
            card.addArranged(menuRow(title, isAccent: title == "로그아웃"))
            if index < items.count - 1 { card.addArranged(divider()) }
        }
        contentStack.addArrangedSubview(card)
    }

    /// 탭 가능한 메뉴 행 (누르면 하이라이트 + 동작)
    private func menuRow(_ title: String, isAccent: Bool = false) -> UIView {
        let row = UIControl()
        let color = isAccent ? AppColor.coral : AppColor.ink
        let label = UILabel.make(title, font: AppFont.medium(15), color: color)
        let chevron = UILabel.make("›", font: AppFont.bold(18), color: AppColor.sub)
        [label, chevron].forEach { $0.isUserInteractionEnabled = false; row.addSubview($0) }
        label.snp.makeConstraints { $0.leading.equalToSuperview().inset(12); $0.centerY.equalToSuperview() }
        chevron.snp.makeConstraints { $0.trailing.equalToSuperview().inset(12); $0.centerY.equalToSuperview() }
        row.snp.makeConstraints { $0.height.equalTo(50) }

        // 누름 하이라이트
        row.addAction(UIAction { _ in row.backgroundColor = AppColor.line.withAlphaComponent(0.3) }, for: .touchDown)
        let clear = UIAction { _ in UIView.animate(withDuration: 0.15) { row.backgroundColor = .clear } }
        row.addAction(clear, for: .touchUpInside)
        row.addAction(clear, for: .touchUpOutside)
        row.addAction(clear, for: .touchCancel)

        // 동작
        row.addAction(UIAction { [weak self] _ in
            if title == "로그아웃" { self?.confirmLogout() } else { self?.comingSoon(title) }
        }, for: .touchUpInside)
        return row
    }

    private func confirmLogout() {
        let alert = UIAlertController(title: "로그아웃", message: "로그아웃 하시겠어요?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "로그아웃", style: .destructive) { _ in
            APIClient.shared.auth.logout { _ in
                TokenStore.clear()   // 서버 실패와 무관하게 로컬 로그아웃
                SceneDelegate.switchRoot(to: LoginViewController())
            }
        })
        present(alert, animated: true)
    }

    private func comingSoon(_ title: String) {
        let alert = UIAlertController(title: title, message: "준비 중인 기능이에요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    /// 메뉴 행 구분선 (좌우 12 여백)
    private func divider() -> UIView {
        let wrap = UIView()
        let line = UIView()
        line.backgroundColor = AppColor.line
        wrap.addSubview(line)
        line.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.top.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
        return wrap
    }
}
