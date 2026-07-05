//
//  PuzzlePieceView.swift
//  LottoTrip
//
//  강원 지도 퍼즐 한 조각 — 직소(탭/블랭크) 실루엣. status로 채움/예약/잠김 시각화.
//

import UIKit
import SnapKit

final class PuzzlePieceView: UIView {
    private let shapeLayer = CAShapeLayer()
    private let borderLayer = CAShapeLayer()
    private let statusLabel = UILabel()
    private let nameLabel = UILabel()
    private var dashed = false

    init(piece: PuzzlePieceDTO, completedColor: UIColor) {
        super.init(frame: .zero)

        let fg: UIColor
        switch piece.status {
        case .completed:
            shapeLayer.fillColor = completedColor.cgColor
            statusLabel.text = "완성"; fg = .white
        case .reserved:
            shapeLayer.fillColor = AppColor.coral.withAlphaComponent(0.28).cgColor
            statusLabel.text = "인증 대기"; fg = AppColor.coral
            borderLayer.strokeColor = AppColor.coral.cgColor; dashed = true
        case .locked:
            shapeLayer.fillColor = AppColor.tileEmpty.cgColor
            statusLabel.text = "잠김"; fg = AppColor.sub
            borderLayer.strokeColor = AppColor.line.cgColor; dashed = true
        }

        layer.insertSublayer(shapeLayer, at: 0)
        borderLayer.fillColor = nil
        borderLayer.lineWidth = 1
        if dashed { borderLayer.lineDashPattern = [6, 4] }
        layer.addSublayer(borderLayer)

        statusLabel.font = AppFont.medium(11)
        statusLabel.textColor = fg
        nameLabel.font = AppFont.bold(15)
        nameLabel.textColor = fg

        let stack = UIStackView(arrangedSubviews: [statusLabel, nameLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 4
        addSubview(stack)
        stack.snp.makeConstraints { $0.center.equalToSuperview() }
        snp.makeConstraints { $0.height.equalTo(92) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let path = Self.jigsawPath(in: bounds).cgPath
        shapeLayer.path = path
        borderLayer.path = path
    }

    /// 우측 탭(볼록) + 상단 블랭크(오목)를 가진 직소 조각 실루엣.
    static func jigsawPath(in b: CGRect) -> UIBezierPath {
        let rect = b.insetBy(dx: 5, dy: 5)
        guard rect.width > 0, rect.height > 0 else { return UIBezierPath(rect: b) }
        let n = min(rect.width, rect.height) * 0.15
        let p = UIBezierPath()
        p.move(to: CGPoint(x: rect.minX, y: rect.minY))
        // 상단: 가운데 블랭크(안으로 오목)
        p.addLine(to: CGPoint(x: rect.midX - n, y: rect.minY))
        p.addArc(withCenter: CGPoint(x: rect.midX, y: rect.minY), radius: n, startAngle: .pi, endAngle: 0, clockwise: false)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        // 우측: 가운데 탭(밖으로 볼록)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY - n))
        p.addArc(withCenter: CGPoint(x: rect.maxX, y: rect.midY), radius: n, startAngle: -.pi / 2, endAngle: .pi / 2, clockwise: true)
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.close()
        return p
    }
}
