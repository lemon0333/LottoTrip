//
//  MissionAllClearViewController.swift
//  LottoTrip
//
//  모든 임무 완료 — 지역 해금 / 지도 완성 안내.
//

import UIKit
import SnapKit

final class MissionAllClearViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.ivory
        navigationItem.title = "임무 완료"

        let title = UILabel.make("모든 임무 완료!", font: AppFont.bold(24), color: AppColor.ink, align: .center)
        let subtitle = UILabel.make(
            "축하합니다! 산신령의 가호를 받아\n지도를 완성해 보아요.",
            font: AppFont.regular(14), color: AppColor.sub, align: .center)

        let puzzle = SquarePuzzleView(fill: AppColor.coral, side: 130)

        let center = UIStackView(arrangedSubviews: [title, subtitle, puzzle])
        center.axis = .vertical
        center.alignment = .center
        center.spacing = 20
        center.setCustomSpacing(36, after: subtitle)

        let cta = PrimaryButton(title: "가호 받기")
        cta.addTarget(self, action: #selector(receiveBlessing), for: .touchUpInside)

        view.addSubview(center)
        view.addSubview(cta)

        center.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        cta.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
    }

    @objc private func receiveBlessing() {
        navigationController?.popToRootViewController(animated: true)
    }
}
