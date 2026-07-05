//
//  ShortformEditorViewController.swift
//  LottoTrip
//
//  원클릭 숏폼 — 산신령 TTS 더빙 + 슬롯 애니 믹싱.
//

import UIKit
import SnapKit

final class ShortformEditorViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0x1A1A20)
        navigationItem.title = "숏폼 만들기"

        // 미리보기
        let preview = UIView()
        preview.backgroundColor = UIColor(hex: 0x3A3A44)
        preview.layer.cornerRadius = 16
        let play = UILabel.make("▶", font: AppFont.bold(26), color: .white, align: .center)
        let cap = UILabel.make("🧙 산신령 더빙 · 아들바위 전설 · 0:14", font: AppFont.medium(12), color: .white)
        preview.addSubview(play)
        preview.addSubview(cap)
        play.snp.makeConstraints { $0.center.equalToSuperview() }
        cap.snp.makeConstraints { $0.leading.bottom.equalToSuperview().inset(16) }

        // 타임라인
        let timeline = UIStackView()
        timeline.axis = .horizontal
        timeline.spacing = 8
        timeline.distribution = .fillEqually
        ["클립1", "클립2", "슬롯", "클립3"].enumerated().forEach { idx, t in
            let thumb = UIView()
            thumb.backgroundColor = idx == 2 ? AppColor.coral : UIColor(hex: 0x2E2E36)
            thumb.layer.cornerRadius = 8
            let label = UILabel.make(t, font: AppFont.medium(11), color: .white, align: .center)
            thumb.addSubview(label)
            label.snp.makeConstraints { $0.center.equalToSuperview() }
            thumb.snp.makeConstraints { $0.height.equalTo(64) }
            timeline.addArrangedSubview(thumb)
        }

        // 옵션 칩
        let options = UIStackView()
        options.axis = .horizontal
        options.spacing = 8
        [("산신령 TTS", true), ("슬롯 애니", true), ("자막", false), ("속도", false)].forEach { t, on in
            options.addArrangedSubview(darkChip(t, on: on))
        }
        let optSpacer = UIView(); optSpacer.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        options.addArrangedSubview(optSpacer)

        // AI 카드
        let aiCard = UIView()
        aiCard.backgroundColor = UIColor(hex: 0x2E2E36)
        aiCard.layer.cornerRadius = 14
        let aiTexts = UIStackView(arrangedSubviews: [
            UILabel.make("AI 자동 믹싱", font: AppFont.bold(15), color: .white),
            UILabel.make("2~3초 클립 + 슬롯 소스 + AWS Polly TTS", font: AppFont.medium(11), color: UIColor(hex: 0xB8B8C0))
        ])
        aiTexts.axis = .vertical
        aiTexts.spacing = 3
        let toggle = UIView()
        toggle.backgroundColor = AppColor.lime
        toggle.layer.cornerRadius = 14
        let knob = UIView(); knob.backgroundColor = .white; knob.layer.cornerRadius = 11
        toggle.addSubview(knob)
        toggle.snp.makeConstraints { $0.size.equalTo(CGSize(width: 46, height: 28)) }
        knob.snp.makeConstraints { $0.trailing.equalToSuperview().inset(3); $0.centerY.equalToSuperview(); $0.size.equalTo(22) }
        let aiRow = UIStackView(arrangedSubviews: [aiTexts, toggle])
        aiRow.axis = .horizontal
        aiRow.alignment = .center
        aiTexts.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        aiCard.addSubview(aiRow)
        aiRow.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)) }

        // 하단 버튼
        let save = PrimaryButton(title: "임시저장", bg: UIColor(hex: 0x2E2E36), fg: .white)
        let share = PrimaryButton(title: "SNS 공유", bg: AppColor.coral, fg: .white)
        let buttons = UIStackView(arrangedSubviews: [save, share])
        buttons.axis = .horizontal
        buttons.spacing = 10
        buttons.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [preview, timeline, options, aiCard])
        stack.axis = .vertical
        stack.spacing = 14
        view.addSubview(stack)
        view.addSubview(buttons)
        stack.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        preview.snp.makeConstraints { $0.height.equalTo(280) }
        buttons.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }

    private func darkChip(_ text: String, on: Bool) -> UIView {
        let chip = UIView()
        chip.backgroundColor = on ? AppColor.coral : UIColor(hex: 0x2E2E36)
        chip.layer.cornerRadius = 15
        let label = UILabel.make(text, font: AppFont.medium(13), color: .white)
        chip.addSubview(label)
        label.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 8, left: 13, bottom: 8, right: 13)) }
        return chip
    }
}
