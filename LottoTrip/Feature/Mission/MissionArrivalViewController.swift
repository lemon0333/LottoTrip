//
//  MissionArrivalViewController.swift
//  LottoTrip
//
//  목적지 도착 안내 — 산신령 임무 진입 화면.
//

import UIKit
import SnapKit

final class MissionArrivalViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.ivory
        navigationItem.title = "미션"

        let title = UILabel.make("목적지 도착!", font: AppFont.bold(24), color: AppColor.ink, align: .center)
        let subtitle = UILabel.make(
            "산신령의 임무를 완료하고 퍼즐을 모아\n지도를 완성해 보아요!",
            font: AppFont.regular(14), color: AppColor.sub, align: .center)

        let puzzle = SquarePuzzleView(fill: AppColor.coral, side: 130)

        let center = UIStackView(arrangedSubviews: [title, subtitle, puzzle])
        center.axis = .vertical
        center.alignment = .center
        center.spacing = 20
        center.setCustomSpacing(36, after: subtitle)

        let confirm = PrimaryButton(title: "확인 하기", bg: AppColor.ink, fg: .white)
        confirm.addTarget(self, action: #selector(goList), for: .touchUpInside)

        view.addSubview(center)
        view.addSubview(confirm)

        center.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        confirm.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }

    @objc private func goList() {
        navigationController?.pushViewController(MissionListViewController(), animated: true)
    }
}
