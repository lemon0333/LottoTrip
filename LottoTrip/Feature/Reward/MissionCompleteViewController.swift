//
//  MissionCompleteViewController.swift
//  LottoTrip
//
//  미션 성공 — 리워드 + 퍼즐 조각 unlock.
//

import UIKit
import SnapKit

final class MissionCompleteViewController: BaseScrollViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "미션 성공"
        contentStack.spacing = 14
        contentStack.layoutMargins = UIEdgeInsets(top: 40, left: 24, bottom: 28, right: 24)

        // 체크 원
        let circleWrap = UIView()
        let circle = UIView()
        circle.backgroundColor = AppColor.lime
        circle.layer.cornerRadius = 54
        circle.layer.borderWidth = 5
        circle.layer.borderColor = UIColor.white.cgColor
        let check = UILabel.make("✓", font: AppFont.bold(52), color: .white, align: .center)
        circle.addSubview(check)
        check.snp.makeConstraints { $0.center.equalToSuperview() }
        circleWrap.addSubview(circle)
        circle.snp.makeConstraints { $0.center.equalToSuperview(); $0.size.equalTo(108) }
        circleWrap.snp.makeConstraints { $0.height.equalTo(108) }
        contentStack.addArrangedSubview(circleWrap)

        contentStack.addArrangedSubview(UILabel.make("운명 미션 성공!", font: AppFont.bold(26), color: AppColor.ink, align: .center))
        contentStack.addArrangedSubview(UILabel.make("강릉 아들바위공원 인증 완료", font: AppFont.medium(15), color: AppColor.sub, align: .center))

        // 리워드 카드
        let card = CardView(spacing: 12, padding: 18)
        card.stack.alignment = .center
        card.addArranged(
            UILabel.make("+200P · 강릉 카페 쿠폰 획득", font: AppFont.bold(20), color: AppColor.coral, align: .center),
            UILabel.make("새 뱃지 · 강원 운명 공동체 🥔", font: AppFont.medium(14), color: AppColor.sub, align: .center),
            beforeAfter(),
            unlockNote()
        )
        contentStack.addArrangedSubview(card)

        let brag = PrimaryButton(title: "운명 공동체에 자랑하기")
        brag.addTarget(self, action: #selector(bragTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(brag)
        let next = PrimaryButton(title: "다음 SPIN 돌리기", bg: .white, fg: AppColor.coral, bordered: true)
        next.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        contentStack.addArrangedSubview(next)
    }

    // 자랑하기 → 운명 공동체 피드로 이동
    @objc private func bragTapped() {
        navigationController?.pushViewController(CommunityFeedViewController(), animated: true)
    }

    // 다음 SPIN → 가호(리워드) 확인 알림 후 지도(루트)로 복귀
    @objc private func nextTapped() {
        let alert = UIAlertController(title: nil, message: "가호를 받았어요! 지도에 새 조각이 열렸어요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popToRootViewController(animated: true)
        })
        present(alert, animated: true)
    }

    private func beforeAfter() -> UIStackView {
        let make: (String) -> UIView = { text in
            let v = UIView()
            v.backgroundColor = UIColor(hex: 0xDCD6CC)
            v.layer.cornerRadius = 10
            let l = UILabel.make(text, font: AppFont.bold(12), color: AppColor.sub, align: .center)
            v.addSubview(l)
            l.snp.makeConstraints { $0.center.equalToSuperview() }
            v.snp.makeConstraints { $0.height.equalTo(116) }
            return v
        }
        let row = UIStackView(arrangedSubviews: [make("BEFORE"), make("AFTER")])
        row.axis = .horizontal
        row.spacing = 12
        row.distribution = .fillEqually
        return row
    }

    // 퍼즐 조각 unlock 연동
    private func unlockNote() -> UIView {
        let note = UIView()
        note.backgroundColor = AppColor.lime.withAlphaComponent(0.15)
        note.layer.cornerRadius = 10
        let label = UILabel.make("🧩 ‘강릉’ 조각 완성!  퍼즐 5 → 6", font: AppFont.bold(13), color: UIColor(hex: 0x3E7A18), align: .center)
        note.addSubview(label)
        label.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)) }
        return note
    }
}
