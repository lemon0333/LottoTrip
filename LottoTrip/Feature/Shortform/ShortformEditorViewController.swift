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
        // 앱 공통 라이트 톤: 아이보리 배경 + 잉크 텍스트 + 코랄 강조
        view.backgroundColor = AppColor.ivory
        navigationItem.title = "숏폼 만들기"

        // 미리보기 — 영상 자체는 자연스럽게 어두운 톤 유지 (다크 라운드 사각형 + ▶)
        let preview = UIView()
        preview.backgroundColor = UIColor(hex: 0x2B2B2E)
        preview.layer.cornerRadius = 16
        let play = UILabel.make("▶", font: AppFont.bold(26), color: .white, align: .center)
        let cap = UILabel.make("🧙 산신령 더빙 · 아들바위 전설 · 0:14", font: AppFont.medium(12), color: .white)
        preview.addSubview(play)
        preview.addSubview(cap)
        play.snp.makeConstraints { $0.center.equalToSuperview() }
        cap.snp.makeConstraints { $0.leading.bottom.equalToSuperview().inset(16) }

        // 타임라인 — 흰 카드 썸네일 (선택된 슬롯만 코랄 강조)
        let timeline = UIStackView()
        timeline.axis = .horizontal
        timeline.spacing = 8
        timeline.distribution = .fillEqually
        ["클립1", "클립2", "슬롯", "클립3"].enumerated().forEach { idx, t in
            let selected = idx == 2
            let thumb = UIView()
            thumb.backgroundColor = selected ? AppColor.coral : AppColor.card
            thumb.layer.cornerRadius = 8
            thumb.layer.borderWidth = 1
            thumb.layer.borderColor = (selected ? AppColor.coral : AppColor.line).cgColor
            let label = UILabel.make(t, font: AppFont.medium(11), color: selected ? .white : AppColor.ink, align: .center)
            thumb.addSubview(label)
            label.snp.makeConstraints { $0.center.equalToSuperview() }
            thumb.snp.makeConstraints { $0.height.equalTo(64) }
            timeline.addArrangedSubview(thumb)
        }

        // 옵션 칩 — 공통 ChipView 스타일 (선택 시 코랄 채움)
        let options = UIStackView()
        options.axis = .horizontal
        options.spacing = 8
        [("산신령 TTS", true), ("슬롯 애니", true), ("자막", false), ("속도", false)].forEach { t, on in
            options.addArrangedSubview(ChipView(text: t, filled: on))
        }
        let optSpacer = UIView(); optSpacer.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        options.addArrangedSubview(optSpacer)

        // AI 카드 — 흰 카드 + 라인 보더
        let aiCard = UIView()
        aiCard.backgroundColor = AppColor.card
        aiCard.layer.cornerRadius = 14
        aiCard.layer.borderWidth = 1
        aiCard.layer.borderColor = AppColor.line.cgColor
        let aiTexts = UIStackView(arrangedSubviews: [
            UILabel.make("AI 자동 믹싱", font: AppFont.bold(15), color: AppColor.ink),
            UILabel.make("2~3초 클립 + 슬롯 소스 + AWS Polly TTS", font: AppFont.medium(11), color: AppColor.sub)
        ])
        aiTexts.axis = .vertical
        aiTexts.spacing = 3
        // 표준 UISwitch (켜짐, 코랄/라임 틴트)
        let toggle = UISwitch()
        toggle.isOn = true
        toggle.onTintColor = AppColor.lime
        toggle.thumbTintColor = .white
        let aiRow = UIStackView(arrangedSubviews: [aiTexts, toggle])
        aiRow.axis = .horizontal
        aiRow.alignment = .center
        aiTexts.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        aiCard.addSubview(aiRow)
        aiRow.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 14, left: 16, bottom: 14, right: 16)) }

        // 하단 버튼 — 임시저장(흰 배경 코랄 보더) / SNS 공유(코랄 채움)
        let save = PrimaryButton(title: "임시저장", bg: AppColor.card, fg: AppColor.coral, bordered: true)
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
}
