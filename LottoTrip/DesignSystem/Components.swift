//
//  Components.swift
//  LottoTrip
//
//  재사용 UIView 컴포넌트 (SnapKit 레이아웃).
//

import UIKit
import SnapKit

// MARK: - PrimaryButton
final class PrimaryButton: UIButton {
    init(title: String, bg: UIColor = AppColor.coral, fg: UIColor = .white, bordered: Bool = false) {
        super.init(frame: .zero)
        var config = UIButton.Configuration.filled()
        config.attributedTitle = AttributedString(title, attributes: AttributeContainer([.font: AppFont.bold(16)]))
        config.baseBackgroundColor = bg
        config.baseForegroundColor = fg
        config.cornerStyle = .large
        config.contentInsets = NSDirectionalEdgeInsets(top: 15, leading: 20, bottom: 15, trailing: 20)
        configuration = config
        if bordered {
            layer.borderWidth = 1.5
            layer.borderColor = fg.cgColor
            layer.cornerRadius = 14
            clipsToBounds = true
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - ChipView
final class ChipView: UIView {
    init(text: String, filled: Bool = false) {
        super.init(frame: .zero)
        backgroundColor = filled ? AppColor.coral : AppColor.card
        layer.cornerRadius = 15
        layer.borderWidth = 1
        layer.borderColor = (filled ? AppColor.coral : AppColor.line).cgColor

        let label = UILabel.make(text, font: AppFont.medium(13), color: filled ? .white : AppColor.sub)
        addSubview(label)
        label.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(13)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

// MARK: - CardView (내부 vertical stack)
final class CardView: UIView {
    let stack = UIStackView()
    init(spacing: CGFloat = 10, padding: CGFloat = 16) {
        super.init(frame: .zero)
        backgroundColor = AppColor.card
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = AppColor.line.cgColor

        stack.axis = .vertical
        stack.spacing = spacing
        addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalToSuperview().inset(padding) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func addArranged(_ views: UIView...) { views.forEach { stack.addArrangedSubview($0) } }
}

// MARK: - FlowChipView (칩 줄바꿈 배치)
final class FlowChipView: UIView {
    private let chips: [UIView]
    private let hspacing: CGFloat = 8
    private let vspacing: CGFloat = 8

    init(items: [String], active: Set<Int> = []) {
        chips = items.enumerated().map { ChipView(text: $0.element, filled: active.contains($0.offset)) }
        super.init(frame: .zero)
        chips.forEach { addSubview($0) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func layout(width: CGFloat, apply: Bool) -> CGFloat {
        var x: CGFloat = 0, y: CGFloat = 0, rowH: CGFloat = 0
        for chip in chips {
            let size = chip.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
            if x + size.width > width, x > 0 { x = 0; y += rowH + vspacing; rowH = 0 }
            if apply { chip.frame = CGRect(x: x, y: y, width: size.width, height: size.height) }
            x += size.width + hspacing
            rowH = max(rowH, size.height)
        }
        return y + rowH
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        _ = layout(width: bounds.width, apply: true)
        invalidateIntrinsicContentSize()
    }

    override var intrinsicContentSize: CGSize {
        let width = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width - 40
        return CGSize(width: UIView.noIntrinsicMetric, height: layout(width: width, apply: false))
    }
}
