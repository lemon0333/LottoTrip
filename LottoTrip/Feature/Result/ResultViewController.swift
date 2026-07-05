//
//  ResultViewController.swift
//  LottoTrip
//
//  추천 결과 — 강원 숨은명소 + 채울 퍼즐 조각 배지.
//

import UIKit
import SnapKit

final class ResultViewController: BaseScrollViewController {

    private let dest = SampleData.destination

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "추천 결과"

        contentStack.addArrangedSubview(headerRow("운명의 목적지 도착!", right: "다시 SPIN ↻", rightColor: AppColor.coral))
        contentStack.addArrangedSubview(mapView())
        contentStack.addArrangedSubview(resultCard())
        contentStack.addArrangedSubview(missionBadge())

        let actions = UIStackView(arrangedSubviews: [
            makeButton("길찾기", bg: AppColor.coral, fg: .white, action: #selector(goRoute)),
            makeButton("코스에 저장", bg: .white, fg: AppColor.coral, bordered: true, action: #selector(save))
        ])
        actions.axis = .horizontal
        actions.spacing = 10
        actions.distribution = .fillEqually
        contentStack.addArrangedSubview(actions)

        let shortform = PrimaryButton(title: "숏폼으로 남기기", bg: AppColor.cafe, fg: .white)
        shortform.addTarget(self, action: #selector(goShortform), for: .touchUpInside)
        contentStack.addArrangedSubview(shortform)
    }

    private func mapView() -> UIView {
        let map = UIView()
        map.backgroundColor = UIColor(hex: 0xD7E6D8)
        map.layer.cornerRadius = 14
        let pin = UIView()
        pin.backgroundColor = AppColor.coral
        pin.layer.cornerRadius = 22
        pin.layer.borderWidth = 3
        pin.layer.borderColor = UIColor.white.cgColor
        let star = UILabel.make("★", font: AppFont.bold(18), color: .white, align: .center)
        pin.addSubview(star)
        star.snp.makeConstraints { $0.center.equalToSuperview() }
        let label = UILabel.make("TourAPI · 강원 강릉시", font: AppFont.medium(13), color: AppColor.sub)
        map.addSubview(pin)
        map.addSubview(label)
        map.snp.makeConstraints { $0.height.equalTo(170) }
        pin.snp.makeConstraints { $0.size.equalTo(44); $0.centerX.equalToSuperview(); $0.centerY.equalToSuperview().offset(-14) }
        label.snp.makeConstraints { $0.top.equalTo(pin.snp.bottom).offset(8); $0.centerX.equalToSuperview() }
        return map
    }

    private func resultCard() -> CardView {
        let card = CardView()
        let titleRow = UIStackView()
        titleRow.axis = .horizontal
        titleRow.alignment = .center
        titleRow.spacing = 8
        let name = UILabel.make(dest.name, font: AppFont.bold(20), color: AppColor.ink)
        let hiddenChip = ChipView(text: "숨은 명소", filled: true)
        titleRow.addArrangedSubview(name)
        titleRow.addArrangedSubview(hiddenChip)
        let spacer = UIView(); spacer.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        titleRow.addArrangedSubview(spacer)

        let category = UILabel.make(dest.category, font: AppFont.medium(13), color: AppColor.cafe)

        let meta = UIStackView()
        meta.axis = .horizontal
        meta.spacing = 14
        meta.addArrangedSubview(UILabel.make("리뷰 적음 ✦", font: AppFont.bold(13), color: AppColor.coral))
        meta.addArrangedSubview(UILabel.make("자차 \(Int(dest.distanceKm))km", font: AppFont.regular(13), color: AppColor.sub))
        meta.addArrangedSubview(UILabel.make("예산 ~\(dest.budget / 10000)만원", font: AppFont.regular(13), color: AppColor.sub))
        let metaSpacer = UIView(); metaSpacer.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        meta.addArrangedSubview(metaSpacer)

        // 퍼즐 조각 연동 배지
        let piece = pieceBadge("이 장소는 ‘강릉’ 조각을 채워요")

        card.addArranged(titleRow, category, meta, piece)
        return card
    }

    private func pieceBadge(_ text: String) -> UIView {
        let badge = UIView()
        badge.backgroundColor = AppColor.lime.withAlphaComponent(0.15)
        badge.layer.cornerRadius = 10
        let label = UILabel.make("🧩 " + text, font: AppFont.bold(13), color: UIColor(hex: 0x3E7A18))
        badge.addSubview(label)
        label.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)) }
        return badge
    }

    private func missionBadge() -> UIView {
        let badge = UIView()
        badge.backgroundColor = UIColor(hex: 0xFAEBE8)
        badge.layer.cornerRadius = 12
        let label = UILabel.make("🎲 운명 미션 · \(dest.missionTitle)", font: AppFont.bold(13), color: AppColor.coral)
        badge.addSubview(label)
        label.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 11, left: 12, bottom: 11, right: 12)) }
        return badge
    }

    private func makeButton(_ title: String, bg: UIColor, fg: UIColor, bordered: Bool = false, action: Selector) -> PrimaryButton {
        let b = PrimaryButton(title: title, bg: bg, fg: fg, bordered: bordered)
        b.addTarget(self, action: action, for: .touchUpInside)
        return b
    }

    @objc private func goRoute() { navigationController?.pushViewController(RouteViewController(), animated: true) }
    @objc private func goShortform() { navigationController?.pushViewController(ShortformEditorViewController(), animated: true) }
    @objc private func save() {}
}
