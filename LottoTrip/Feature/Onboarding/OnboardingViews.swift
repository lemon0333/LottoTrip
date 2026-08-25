//
//  OnboardingViews.swift
//  LottoTrip
//
//  온보딩 공통 위젯: 퍼즐 입력 히어로 / 진행 도트 / 확인 체크 버튼 / 자음 배지.
//

import UIKit
import SnapKit

// MARK: - 퍼즐 입력 히어로

/// 코랄 퍼즐 조각 + 가운데 흰 입력 필드(커서 깜빡임). 탭하면 입력 화면으로 진입.
final class PuzzleInputView: UIControl {

    /// 조각 네 변의 볼록(탭) 여부 — 단계별로 실루엣을 조금씩 다르게.
    struct Lobes { let top, right, bottom, left: Bool }

    private let base = UIView()
    private let pill = UIView()
    private let cursor = UIView()

    init(lobes: Lobes) {
        super.init(frame: .zero)

        // 볼록 lobe(원)들을 base 뒤에 깔아 꽃/직소 실루엣을 만든다 (모두 코랄이라 자연스럽게 합쳐짐)
        let d: CGFloat = 46
        func lobe(_ on: Bool) -> UIView {
            let v = UIView()
            v.backgroundColor = on ? AppColor.coral : .clear
            v.layer.cornerRadius = d / 2
            addSubview(v)
            v.snp.makeConstraints { $0.size.equalTo(d) }
            return v
        }
        let top = lobe(lobes.top), right = lobe(lobes.right)
        let bottom = lobe(lobes.bottom), left = lobe(lobes.left)

        base.backgroundColor = AppColor.coral
        base.layer.cornerRadius = 28
        addSubview(base)

        pill.backgroundColor = .white
        pill.layer.cornerRadius = 12
        addSubview(pill)

        cursor.backgroundColor = AppColor.coral
        pill.addSubview(cursor)

        base.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(150); $0.height.equalTo(116)
        }
        top.snp.makeConstraints { $0.centerX.equalTo(base); $0.centerY.equalTo(base.snp.top).offset(6) }
        bottom.snp.makeConstraints { $0.centerX.equalTo(base); $0.centerY.equalTo(base.snp.bottom).offset(-6) }
        left.snp.makeConstraints { $0.centerY.equalTo(base); $0.centerX.equalTo(base.snp.left).offset(6) }
        right.snp.makeConstraints { $0.centerY.equalTo(base); $0.centerX.equalTo(base.snp.right).offset(-6) }

        pill.snp.makeConstraints {
            $0.center.equalTo(base)
            $0.width.equalTo(96); $0.height.equalTo(40)
        }
        cursor.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(14)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(2); $0.height.equalTo(20)
        }
        snp.makeConstraints { $0.width.equalTo(210); $0.height.equalTo(180) }

        startBlink()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func startBlink() {
        UIView.animate(withDuration: 0.55, delay: 0, options: [.repeat, .autoreverse]) {
            self.cursor.alpha = 0.1
        }
    }
}

// MARK: - 진행 도트 (n/total)

final class PageDots: UIView {
    private let stack = UIStackView()
    private var dots: [UIView] = []

    init(total: Int, current: Int) {
        super.init(frame: .zero)
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview() }

        for i in 0..<total {
            let active = i == current
            let dot = UIView()
            dot.backgroundColor = active ? AppColor.coral : AppColor.line
            dot.layer.cornerRadius = 3.5
            stack.addArrangedSubview(dot)
            dot.snp.makeConstraints {
                $0.height.equalTo(7)
                $0.width.equalTo(active ? 20 : 7)   // 현재 단계는 길쭉하게
            }
            dots.append(dot)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - 확인(체크) 버튼

/// 원형 체크 버튼. 비활성=회색, 활성=코랄.
final class ConfirmCheckButton: UIButton {
    init() {
        super.init(frame: .zero)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "checkmark",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .bold))
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule
        configuration = config
        setEnabled(false)
        snp.makeConstraints { $0.size.equalTo(58) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func setEnabled(_ on: Bool) {
        isEnabled = on
        configuration?.baseBackgroundColor = on ? AppColor.coral : UIColor(hex: 0xCFC9BF)
    }
}

// MARK: - 자음 배지 (ㄱ/ㄴ/…)

final class LetterBadge: UIView {
    /// 치수 가이드: 스타일 배지는 초록(mint)
    static let mint = UIColor(hex: 0x6FBF9E)
    init(_ text: String) {
        super.init(frame: .zero)
        backgroundColor = LetterBadge.mint
        layer.cornerRadius = 13
        let label = UILabel.make(text, font: AppFont.bold(13), color: .white, align: .center)
        addSubview(label)
        label.snp.makeConstraints { $0.center.equalToSuperview() }
        snp.makeConstraints { $0.size.equalTo(26) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - 뒤로가기 원형 버튼 (좌하단)

final class CircleBackButton: UIButton {
    init() {
        super.init(frame: .zero)
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "chevron.left",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold))
        config.baseForegroundColor = AppColor.ink
        config.baseBackgroundColor = AppColor.card
        config.cornerStyle = .capsule
        configuration = config
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowRadius = 6
        layer.shadowOffset = CGSize(width: 0, height: 2)
        snp.makeConstraints { $0.size.equalTo(44) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
