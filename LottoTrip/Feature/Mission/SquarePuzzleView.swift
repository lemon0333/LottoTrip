//
//  SquarePuzzleView.swift
//  LottoTrip
//
//  2x2 직소 조각이 맞물려 하나의 정사각형을 이루는 퍼즐 그래픽.
//  도착/전체완료 화면과 리스트 아이콘에서 재사용.
//

import UIKit
import SnapKit

final class SquarePuzzleView: UIView {

    private let fill: UIColor
    private let side: CGFloat
    private let pieceLayers = [CAShapeLayer(), CAShapeLayer(), CAShapeLayer(), CAShapeLayer()]

    /// - Parameters:
    ///   - fill: 조각 채움색 (완료 전 coral, 완료 pink 등)
    ///   - side: 전체 정사각 한 변 길이
    init(fill: UIColor = AppColor.coral, side: CGFloat = 130) {
        self.fill = fill
        self.side = side
        super.init(frame: .zero)
        backgroundColor = .clear
        // 네 조각을 서로 다른 방향으로 회전시켜 탭(볼록)/블랭크(오목)가 맞물리도록 배치
        for layer in pieceLayers {
            layer.fillColor = fill.cgColor
            self.layer.addSublayer(layer)
        }
        snp.makeConstraints { $0.size.equalTo(side) }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        let half = bounds.width / 2
        // (열, 행, 회전각) — 회전으로 탭 방향을 엇갈리게 하여 맞물리는 느낌
        let quads: [(CGFloat, CGFloat, CGFloat)] = [
            (0, 0, 0),                // 좌상
            (1, 0, .pi / 2),          // 우상
            (1, 1, .pi),              // 우하
            (0, 1, -.pi / 2)          // 좌하
        ]
        for (i, layer) in pieceLayers.enumerated() {
            let (cx, ry, angle) = quads[i]
            let quad = CGRect(x: cx * half, y: ry * half, width: half, height: half)
            let path = PuzzlePieceView.jigsawPath(in: CGRect(origin: .zero, size: quad.size))
            // 조각 중심 기준 회전
            let center = CGPoint(x: quad.width / 2, y: quad.height / 2)
            var t = CGAffineTransform(translationX: center.x, y: center.y)
            t = t.rotated(by: angle)
            t = t.translatedBy(x: -center.x, y: -center.y)
            path.apply(t)
            path.apply(CGAffineTransform(translationX: quad.minX, y: quad.minY))
            layer.path = path.cgPath
            layer.frame = bounds
        }
    }
}
