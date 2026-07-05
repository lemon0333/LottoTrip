//
//  PuzzleHomeViewController.swift
//  LottoTrip
//
//  강원 지도 퍼즐 — 방문 인증으로 조각을 채워 지도를 완성.
//

import UIKit
import SnapKit

final class PuzzleHomeViewController: BaseScrollViewController {

    private let puzzle = SampleData.puzzle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "강원 지도 퍼즐"

        contentStack.addArrangedSubview(headerRow("강원 지도 퍼즐", right: "MY", rightColor: AppColor.coral))
        contentStack.addArrangedSubview(UILabel.make("방문 인증할 때마다 강원 조각이 채워져요", font: AppFont.medium(13), color: AppColor.cafe))
        contentStack.addArrangedSubview(makeProgressCard())
        contentStack.addArrangedSubview(makeGrid())

        let cta = PrimaryButton(title: "슬롯 돌려 다음 조각 열기")
        cta.addTarget(self, action: #selector(goSlot), for: .touchUpInside)
        contentStack.addArrangedSubview(cta)
    }

    private func makeProgressCard() -> CardView {
        let card = CardView()
        let row = UIStackView()
        row.axis = .horizontal
        row.distribution = .equalSpacing
        row.addArrangedSubview(UILabel.make("\(puzzle.completed) / \(puzzle.total) 조각 완성", font: AppFont.bold(18), color: AppColor.ink))
        row.addArrangedSubview(UILabel.make("\(puzzle.total - puzzle.completed)조각 남음", font: AppFont.medium(12), color: AppColor.coral))

        let track = UIView()
        track.backgroundColor = AppColor.tileEmpty
        track.layer.cornerRadius = 5
        let fill = UIView()
        fill.backgroundColor = AppColor.lime
        fill.layer.cornerRadius = 5
        track.addSubview(fill)
        track.snp.makeConstraints { $0.height.equalTo(10) }
        fill.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalTo(track.snp.width).multipliedBy(Double(puzzle.completed) / Double(puzzle.total))
        }
        card.addArranged(row, track)
        return card
    }

    private func makeGrid() -> UIStackView {
        let col = UIStackView()
        col.axis = .vertical
        col.spacing = 10
        var i = 0
        while i < puzzle.pieces.count {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 10
            rowStack.distribution = .fillEqually
            for j in i..<min(i + 2, puzzle.pieces.count) {
                let color = AppColor.pieceColors[j % AppColor.pieceColors.count]
                rowStack.addArrangedSubview(PuzzlePieceView(piece: puzzle.pieces[j], completedColor: color))
            }
            if puzzle.pieces.count - i == 1 { rowStack.addArrangedSubview(UIView()) }
            col.addArrangedSubview(rowStack)
            i += 2
        }
        return col
    }

    @objc private func goSlot() { tabBarController?.selectedIndex = 1 }
}
