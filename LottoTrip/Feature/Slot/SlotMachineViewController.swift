//
//  SlotMachineViewController.swift
//  LottoTrip
//
//  운명의 슬롯 — 취향 기반 랜덤 목적지 뽑기.
//

import UIKit
import SnapKit

// 콘 그라디언트로 만든 룰렛 휠
final class WheelView: UIView {
    private let conic = CAGradientLayer()
    private let hub = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        conic.type = .conic
        conic.startPoint = CGPoint(x: 0.5, y: 0.5)
        conic.endPoint = CGPoint(x: 0.5, y: 0.0)
        let cs = AppColor.pieceColors
        conic.colors = (cs + [cs[0]]).map { $0.cgColor }
        layer.addSublayer(conic)
        hub.backgroundColor = .white
        addSubview(hub)
        layer.borderWidth = 3
        layer.borderColor = UIColor.white.cgColor
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        conic.frame = bounds
        layer.cornerRadius = bounds.width / 2
        clipsToBounds = true
        let hs: CGFloat = 64
        hub.frame = CGRect(x: (bounds.width - hs) / 2, y: (bounds.height - hs) / 2, width: hs, height: hs)
        hub.layer.cornerRadius = hs / 2
    }
}

final class SlotMachineViewController: UIViewController {

    private let wheel = WheelView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0x5A4A88)
        navigationItem.title = "운명의 슬롯"

        let tag = ChipView(text: "강원도 · 감자 운명 공동체")
        let title = UILabel.make("운명의 목적지 뽑기", font: AppFont.bold(26), color: .white, align: .center)
        let desc = UILabel.make("여러분의 운에 여행을 맡겨보세요", font: AppFont.regular(14), color: .white, align: .center)

        let spin = UIButton(type: .system)
        spin.backgroundColor = AppColor.lime
        spin.setAttributedTitle(NSAttributedString(string: "SPIN",
            attributes: [.font: AppFont.bold(22), .foregroundColor: UIColor.white]), for: .normal)
        spin.layer.cornerRadius = 58
        spin.layer.borderWidth = 4
        spin.layer.borderColor = UIColor.white.cgColor
        spin.addTarget(self, action: #selector(spinTapped), for: .touchUpInside)

        let hint = UILabel.make("여러 번 돌릴 수 있어요 ↻", font: AppFont.medium(13), color: .white, align: .center)

        let stack = UIStackView(arrangedSubviews: [tag, title, desc, wheel, spin, hint])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20
        stack.setCustomSpacing(28, after: desc)
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.center.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        wheel.snp.makeConstraints { $0.size.equalTo(248) }
        spin.snp.makeConstraints { $0.size.equalTo(116) }
    }

    @objc private func spinTapped() {
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.fromValue = 0
        anim.toValue = CGFloat.pi * 6
        anim.duration = 1.2
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        wheel.layer.add(anim, forKey: "spin")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { [weak self] in
            self?.navigationController?.pushViewController(ResultViewController(), animated: true)
        }
    }
}
