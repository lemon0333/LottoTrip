//
//  PuzzleHomeViewController.swift
//  LottoTrip
//
//  홈 — v2. 동양화풍 한국 지도(방문 인증으로 해금) + 여행 가기 / 영상 만들기.
//  ※ 지역 해금 시 지도 위 퍼즐 오버레이 제거 연출은 다음 단계.
//

import UIKit
import SnapKit

final class PuzzleHomeViewController: UIViewController {

    private let mapImageView = UIImageView()
    private let stamp = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.ivory

        // 우상단 도장(스탬프) — 동양화 컨셉 포인트
        stamp.backgroundColor = AppColor.coral
        stamp.layer.cornerRadius = 6
        view.addSubview(stamp)
        stamp.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(30)
        }

        // 초록 지형 지도 (Figma 에셋)
        mapImageView.image = UIImage(named: "korea_map")
        mapImageView.contentMode = .scaleAspectFit
        view.addSubview(mapImageView)

        // 하단 버튼: 여행 가기(진한 pill) / 영상 만들기(흰 pill)
        let goTrip = PrimaryButton(title: "여행 가기", bg: AppColor.ink, fg: .white)
        goTrip.addTarget(self, action: #selector(goTripTapped), for: .touchUpInside)
        let makeVideo = PrimaryButton(title: "영상 만들기", bg: .white, fg: AppColor.ink, bordered: true)
        makeVideo.addTarget(self, action: #selector(makeVideoTapped), for: .touchUpInside)

        let buttons = UIStackView(arrangedSubviews: [goTrip, makeVideo])
        buttons.axis = .vertical
        buttons.spacing = 12
        view.addSubview(buttons)
        buttons.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(24)
        }

        mapImageView.snp.makeConstraints {
            $0.top.equalTo(stamp.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.bottom.equalTo(buttons.snp.top).offset(-24)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    // 여행 가기 → 슬롯(퍼즐 뽑기) 탭으로
    @objc private func goTripTapped() { tabBarController?.selectedIndex = 1 }
    // 영상 만들기 → 숏폼 에디터
    @objc private func makeVideoTapped() {
        navigationController?.pushViewController(ShortformEditorViewController(), animated: true)
    }
}
