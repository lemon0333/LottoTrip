//
//  ShortformEditorViewController.swift
//  LottoTrip
//
//  원클릭 숏폼 — 산신령 TTS 더빙 + 슬롯 애니 믹싱.
//

import UIKit
import SnapKit

final class ShortformEditorViewController: UIViewController {

    // 타임라인 썸네일(클립1/클립2/슬롯/클립3) — 최소 1개는 선택 유지
    private var thumbs: [ShortThumb] = []
    // 옵션 칩(산신령 TTS/슬롯 애니/자막/속도) — 최소 1개는 선택 유지
    private var optionChips: [ShortToggleChip] = []
    // 하단 공유 버튼 (activity 시트 anchor 용)
    private let share = PrimaryButton(title: "SNS 공유", bg: AppColor.coral, fg: .white)

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

        // 타임라인 — 흰 카드 썸네일 (선택된 슬롯만 코랄 강조), 탭으로 토글
        let timeline = UIStackView()
        timeline.axis = .horizontal
        timeline.spacing = 8
        timeline.distribution = .fillEqually
        ["클립1", "클립2", "슬롯", "클립3"].enumerated().forEach { idx, t in
            let thumb = ShortThumb(text: t, selected: idx == 2)
            thumb.addTarget(self, action: #selector(thumbTapped(_:)), for: .touchUpInside)
            thumbs.append(thumb)
            timeline.addArrangedSubview(thumb)
        }

        // 옵션 칩 — 공통 ChipView 스타일 (선택 시 코랄 채움), 탭으로 토글
        let options = UIStackView()
        options.axis = .horizontal
        options.spacing = 8
        [("산신령 TTS", true), ("슬롯 애니", true), ("자막", false), ("속도", false)].forEach { t, on in
            let chip = ShortToggleChip(text: t, selected: on)
            chip.addTarget(self, action: #selector(optionTapped(_:)), for: .touchUpInside)
            optionChips.append(chip)
            options.addArrangedSubview(chip)
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
        save.addTarget(self, action: #selector(saveTapped), for: .touchUpInside)
        share.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
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

    // 썸네일 토글 — 마지막 남은 1개는 해제되지 않도록 유지
    @objc private func thumbTapped(_ sender: ShortThumb) {
        if sender.on && thumbs.filter({ $0.on }).count <= 1 { return }
        sender.on.toggle()
    }

    // 옵션 칩 토글 — 마지막 남은 1개는 해제되지 않도록 유지
    @objc private func optionTapped(_ sender: ShortToggleChip) {
        if sender.on && optionChips.filter({ $0.on }).count <= 1 { return }
        sender.on.toggle()
    }

    @objc private func saveTapped() {
        let alert = UIAlertController(title: "임시저장", message: "임시저장했어요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    // SNS 공유 — 실제 공유 시트를 띄운다
    @objc private func shareTapped() {
        let text = "로또트립에서 뽑은 운명의 여행 숏폼 🎬"
        let activity = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        // 아이패드 팝오버 anchor
        activity.popoverPresentationController?.sourceView = share
        activity.popoverPresentationController?.sourceRect = share.bounds
        present(activity, animated: true)
    }
}

// MARK: - ShortThumb
// 타임라인 썸네일 (선택=코랄, 미선택=흰 카드/라인)
private final class ShortThumb: UIControl {
    private let label = UILabel()

    var on: Bool { didSet { updateStyle() } }

    init(text: String, selected: Bool) {
        self.on = selected
        super.init(frame: .zero)
        layer.cornerRadius = 8
        layer.borderWidth = 1

        label.text = text
        label.font = AppFont.medium(11)
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        addSubview(label)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
        snp.makeConstraints { $0.height.equalTo(64) }
        updateStyle()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func updateStyle() {
        backgroundColor = on ? AppColor.coral : AppColor.card
        layer.borderColor = (on ? AppColor.coral : AppColor.line).cgColor
        label.textColor = on ? .white : AppColor.ink
    }
}

// MARK: - ShortToggleChip
// 옵션 칩 (ChipView와 동일 룩, 탭으로 선택/해제)
private final class ShortToggleChip: UIControl {
    private let label = UILabel()

    var on: Bool { didSet { updateStyle() } }

    init(text: String, selected: Bool) {
        self.on = selected
        super.init(frame: .zero)
        layer.cornerRadius = 15
        layer.borderWidth = 1

        label.text = text
        label.font = AppFont.medium(13)
        label.isUserInteractionEnabled = false
        addSubview(label)
        label.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(13)
        }
        updateStyle()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func updateStyle() {
        backgroundColor = on ? AppColor.coral : AppColor.card
        layer.borderColor = (on ? AppColor.coral : AppColor.line).cgColor
        label.textColor = on ? .white : AppColor.sub
    }
}
