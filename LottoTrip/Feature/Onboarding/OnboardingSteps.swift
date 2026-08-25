//
//  OnboardingSteps.swift
//  LottoTrip
//
//  5단계 취향 설정 화면 구현.
//  1) 여행 스타일  2) 일정(일수)  3) 예산(원)  4) 이동수단  5) 숙소
//

import UIKit
import SnapKit

// MARK: - 1. 여행 스타일 (최대 2개 중복 선택)

final class StyleStepViewController: OnboardingStepViewController {
    override var introQuestion: String { "나의 여행 스타일은?" }
    override var inputTitle: String { "아-이번 여행은___" }
    override var lobes: PuzzleInputView.Lobes { .init(top: true, right: true, bottom: true, left: true) }

    private var selected: [TravelStyle] = []
    private var rows: [TravelStyle: StyleRow] = [:]

    override func makeInputContent() -> UIView {
        let hint = UILabel.make("최대 2가지 중복 선택 가능", font: AppFont.regular(12), color: AppColor.sub)
        let list = UIStackView()
        list.axis = .vertical
        list.spacing = 10
        for style in TravelStyle.allCases {
            let row = StyleRow(style: style)
            row.addTarget(self, action: #selector(toggle(_:)), for: .touchUpInside)
            rows[style] = row
            list.addArrangedSubview(row)
        }
        let col = UIStackView(arrangedSubviews: [hint, list])
        col.axis = .vertical
        col.spacing = 12
        col.alignment = .fill
        return col
    }

    @objc private func toggle(_ sender: StyleRow) {
        let style = sender.style
        if let idx = selected.firstIndex(of: style) {
            selected.remove(at: idx)
        } else {
            guard selected.count < 2 else { return }   // 최대 2개
            selected.append(style)
        }
        rows[style]?.setSelected(selected.contains(style))
        updateConfirm()
    }

    override var isValid: Bool { !selected.isEmpty }
    override func saveValue() { TripPreferenceStore.shared.current.styles = selected }
}

/// 스타일 한 줄: [자음배지] [이름] [설명] — 선택 시 코랄 테두리.
final class StyleRow: UIControl {
    let style: TravelStyle
    init(style: TravelStyle) {
        self.style = style
        super.init(frame: .zero)
        backgroundColor = AppColor.card
        layer.cornerRadius = 22
        layer.borderWidth = 1.5
        layer.borderColor = AppColor.line.cgColor

        let badge = LetterBadge(style.badge)
        let name = UILabel.make(style.title, font: AppFont.bold(14), color: AppColor.ink)
        let desc = UILabel.make(style.desc, font: AppFont.regular(13), color: AppColor.sub)
        [badge, name, desc].forEach { $0.isUserInteractionEnabled = false }

        let stack = UIStackView(arrangedSubviews: [badge, name, desc])
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 10
        stack.isUserInteractionEnabled = false
        addSubview(stack)
        stack.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.trailing.lessThanOrEqualToSuperview().inset(14)
            $0.centerY.equalToSuperview()
        }
        snp.makeConstraints { $0.height.equalTo(48) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setSelected(_ on: Bool) {
        // 치수 가이드: 선택=초록 테두리, 미선택=투명도 80%
        layer.borderColor = (on ? LetterBadge.mint : AppColor.line).cgColor
        layer.borderWidth = on ? 2 : 1.5
        alpha = on ? 1.0 : 0.8
    }
}

// MARK: - 2. 일정 (일수, 슬라이더)

final class DurationStepViewController: OnboardingStepViewController {
    override var introQuestion: String { "이번 여행 일정은?" }
    override var inputTitle: String { "___정도 머무를 거야!" }
    override var lobes: PuzzleInputView.Lobes { .init(top: true, right: false, bottom: true, left: false) }

    private let valueLabel = UILabel.make("2", font: AppFont.bold(30), color: AppColor.ink, align: .right)
    private let slider = UISlider()
    private var days = 2

    override func makeInputContent() -> UIView {
        let card = UIView()
        card.backgroundColor = AppColor.card
        card.layer.cornerRadius = 18
        card.layer.borderWidth = 1
        card.layer.borderColor = AppColor.line.cgColor

        let unit = UILabel.make("일", font: AppFont.bold(20), color: AppColor.ink)
        let row = UIStackView(arrangedSubviews: [valueLabel, unit])
        row.axis = .horizontal
        row.alignment = .firstBaseline
        row.spacing = 6

        slider.minimumValue = 1
        slider.maximumValue = 14
        slider.value = 2
        slider.minimumTrackTintColor = AppColor.coral
        slider.thumbTintColor = AppColor.coral
        slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

        let stack = UIStackView(arrangedSubviews: [row, slider])
        stack.axis = .vertical
        stack.spacing = 18
        stack.alignment = .fill
        card.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 22, left: 22, bottom: 22, right: 22)) }
        row.snp.makeConstraints { $0.centerX.equalToSuperview() }
        return card
    }

    @objc private func sliderChanged() {
        days = Int(slider.value.rounded())
        valueLabel.text = "\(days)"
        updateConfirm()
    }

    override var isValid: Bool { days >= 1 }
    override func saveValue() { TripPreferenceStore.shared.current.durationDays = days }

    override func viewDidLoad() {
        super.viewDidLoad()
        updateConfirm()   // 기본값 2일 → 바로 활성
    }
}

// MARK: - 3. 예산 (원, 숫자 키패드)

final class BudgetStepViewController: OnboardingStepViewController {
    override var introQuestion: String { "생각 중인 예산은?" }
    override var inputTitle: String { "___정도 생각 중이야." }
    override var lobes: PuzzleInputView.Lobes { .init(top: false, right: false, bottom: true, left: true) }

    private let amountLabel = UILabel.make("원", font: AppFont.bold(26), color: AppColor.ink, align: .right)
    private let subLabel = UILabel.make(" ", font: AppFont.medium(12), color: AppColor.sub, align: .right)
    private var amount = 0
    private var keyButtons: [String: UIButton] = [:]

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 검증용 디버그 훅: BUDGET_AUTOTYPE="550000" 이면 실제 버튼 탭 경로로 입력 재현
        if let seq = ProcessInfo.processInfo.environment["BUDGET_AUTOTYPE"] {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                for ch in seq { self.keyButtons[String(ch)]?.sendActions(for: .touchUpInside) }
            }
        }
    }

    override func makeInputContent() -> UIView {
        let card = UIView()
        card.backgroundColor = AppColor.card
        card.layer.cornerRadius = 18
        card.layer.borderWidth = 1
        card.layer.borderColor = AppColor.line.cgColor

        let display = UIStackView(arrangedSubviews: [amountLabel, subLabel])
        display.axis = .vertical
        display.alignment = .trailing
        display.spacing = 2

        let keypad = makeKeypad()
        let stack = UIStackView(arrangedSubviews: [display, keypad])
        stack.axis = .vertical
        stack.spacing = 18
        stack.alignment = .fill
        card.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)) }
        return card
    }

    private func makeKeypad() -> UIView {
        let keys = ["1","2","3","4","5","6","7","8","9","00","0","⌫"]
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 8
        grid.distribution = .fillEqually
        for r in 0..<4 {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 8
            rowStack.distribution = .fillEqually
            for c in 0..<3 {
                let key = keys[r * 3 + c]
                let btn = UIButton(type: .system)
                btn.setAttributedTitle(NSAttributedString(string: key,
                    attributes: [.font: AppFont.bold(20), .foregroundColor: AppColor.ink]), for: .normal)
                btn.accessibilityIdentifier = key   // 탭 처리에서 키 식별 (attributedTitle 이라 title(for:)는 nil)
                btn.addTarget(self, action: #selector(keyTapped(_:)), for: .touchUpInside)
                btn.snp.makeConstraints { $0.height.equalTo(46) }
                keyButtons[key] = btn
                rowStack.addArrangedSubview(btn)
            }
            grid.addArrangedSubview(rowStack)
        }
        return grid
    }

    @objc private func keyTapped(_ sender: UIButton) {
        let key = sender.accessibilityIdentifier ?? ""
        switch key {
        case "⌫": amount /= 10
        case "00": amount = min(amount * 100, 99_999_999)
        default:
            if let d = Int(key) { amount = min(amount * 10 + d, 99_999_999) }
        }
        refresh()
    }

    private func refresh() {
        amountLabel.text = "\(Self.comma(amount)) 원"
        subLabel.text = amount >= 10_000 ? "\(amount / 10_000)만원" : " "
        updateConfirm()
    }

    override var isValid: Bool { amount > 0 }
    override func saveValue() { TripPreferenceStore.shared.current.budgetWon = amount }

    private static func comma(_ n: Int) -> String {
        let f = NumberFormatter(); f.numberStyle = .decimal
        return f.string(from: NSNumber(value: n)) ?? "\(n)"
    }
}

// MARK: - 4. 이동수단 (2x2 그리드, 단일 선택)

final class TransportStepViewController: OnboardingStepViewController {
    override var introQuestion: String { "주 이동수단은?" }
    override var inputTitle: String { "주 이동수단은 ___!" }
    override var lobes: PuzzleInputView.Lobes { .init(top: true, right: true, bottom: true, left: true) }

    private var selected: TransportOption?
    private var tiles: [TransportOption: UIControl] = [:]

    override func makeInputContent() -> UIView {
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 12
        grid.distribution = .fillEqually
        let options = TransportOption.allCases
        for pair in stride(from: 0, to: options.count, by: 2) {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 12
            rowStack.distribution = .fillEqually
            for opt in options[pair..<min(pair + 2, options.count)] {
                let tile = makeTile(opt)
                tiles[opt] = tile
                rowStack.addArrangedSubview(tile)
            }
            grid.addArrangedSubview(rowStack)
        }
        return grid
    }

    private func makeTile(_ opt: TransportOption) -> UIControl {
        let tile = UIControl()
        tile.backgroundColor = AppColor.card
        tile.layer.cornerRadius = 16
        tile.layer.borderWidth = 1.5
        tile.layer.borderColor = AppColor.line.cgColor
        let label = UILabel.make(opt.title, font: AppFont.bold(16), color: AppColor.ink, align: .center)
        label.isUserInteractionEnabled = false
        tile.addSubview(label)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
        tile.snp.makeConstraints { $0.height.equalTo(96) }
        tile.addTarget(self, action: #selector(tileTapped(_:)), for: .touchUpInside)
        tile.tag = TransportOption.allCases.firstIndex(of: opt)!
        return tile
    }

    @objc private func tileTapped(_ sender: UIControl) {
        let opt = TransportOption.allCases[sender.tag]
        selected = opt
        for (o, tile) in tiles {
            let on = o == opt
            tile.layer.borderColor = (on ? AppColor.coral : AppColor.line).cgColor
            tile.layer.borderWidth = on ? 2 : 1.5
        }
        updateConfirm()
    }

    override var isValid: Bool { selected != nil }
    override func saveValue() { TripPreferenceStore.shared.current.transport = selected }
}

// MARK: - 5. 숙소 (주소 검색)

final class AccommodationStepViewController: OnboardingStepViewController {
    override var introQuestion: String { "이번 여행의 숙소는?" }
    override var inputTitle: String { "이번엔 ___에서!" }
    override var lobes: PuzzleInputView.Lobes { .init(top: false, right: false, bottom: false, left: true) }

    private let searchField = UITextField()
    private let detailField = UITextField()

    override func makeInputContent() -> UIView {
        let card = UIView()
        card.backgroundColor = AppColor.card
        card.layer.cornerRadius = 18
        card.layer.borderWidth = 1
        card.layer.borderColor = AppColor.line.cgColor

        let searchTitle = UILabel.make("도로명 주소 검색", font: AppFont.bold(13), color: AppColor.ink)
        searchField.placeholder = "예) 도움6로42, 국립중앙…"
        searchField.font = AppFont.regular(14)
        searchField.borderStyle = .roundedRect
        searchField.addTarget(self, action: #selector(textChanged), for: .editingChanged)
        searchField.snp.makeConstraints { $0.height.equalTo(40) }

        let mapButton = PrimaryButton(title: "지도로 찾을래요.", bg: AppColor.ink, fg: .white)
        mapButton.addTarget(self, action: #selector(mapTapped), for: .touchUpInside)

        let detailTitle = UILabel.make("상세 주소 입력", font: AppFont.bold(13), color: AppColor.ink)
        detailField.placeholder = "상세 주소"
        detailField.font = AppFont.regular(14)
        detailField.borderStyle = .roundedRect
        detailField.snp.makeConstraints { $0.height.equalTo(40) }

        let stack = UIStackView(arrangedSubviews: [searchTitle, searchField, mapButton, detailTitle, detailField])
        stack.axis = .vertical
        stack.spacing = 12
        stack.alignment = .fill
        stack.setCustomSpacing(18, after: mapButton)
        card.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 20, left: 18, bottom: 20, right: 18)) }
        return card
    }

    @objc private func textChanged() { updateConfirm() }
    @objc private func mapTapped() {
        // 실제 지도/주소 검색 SDK 연동 전 자리표시
        let alert = UIAlertController(title: "안내", message: "지도 검색은 준비 중이에요. 주소를 직접 입력해 주세요.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }

    override var isValid: Bool { !(searchField.text ?? "").trimmingCharacters(in: .whitespaces).isEmpty }
    override func saveValue() {
        let base = searchField.text ?? ""
        let detail = detailField.text ?? ""
        TripPreferenceStore.shared.current.accommodationAddress =
            detail.isEmpty ? base : "\(base) \(detail)"
    }
}
