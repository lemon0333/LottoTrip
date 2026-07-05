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

        // 메뉴
        let card = CardView(spacing: 0, padding: 4)
        ["내 코스 기록", "획득 뱃지", "포인트 · 쿠폰", "알림 설정", "로그아웃"].forEach {
            card.addArranged(menuRow($0))
        }
        contentStack.addArrangedSubview(card)
    }

    private func menuRow(_ title: String) -> UIView {
        let row = UIView()
        let label = UILabel.make(title, font: AppFont.medium(15), color: AppColor.ink)
        let chevron = UILabel.make("›", font: AppFont.bold(18), color: AppColor.sub)
        row.addSubview(label)
        row.addSubview(chevron)
        label.snp.makeConstraints { $0.leading.equalToSuperview().inset(12); $0.centerY.equalToSuperview() }
        chevron.snp.makeConstraints { $0.trailing.equalToSuperview().inset(12); $0.centerY.equalToSuperview() }
        row.snp.makeConstraints { $0.height.equalTo(50) }
        return row
    }
}
