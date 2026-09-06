//
//  MissionCaptureViewController.swift
//  LottoTrip
//
//  운명 미션 — 산신령 스토리텔링 + 촬영 인증.
//

import UIKit
import SnapKit

final class MissionCaptureViewController: UIViewController {

    // 레거시 화면 — 실제 미션 데이터 연동 전까지 중립 placeholder 표시

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0x1A1A20)
        navigationItem.title = "포토 미션"

        // 산신령 스토리 카드
        let story = UIView()
        story.backgroundColor = UIColor(hex: 0x2E2E36)
        story.layer.cornerRadius = 14
        story.layer.borderWidth = 1.5
        story.layer.borderColor = UIColor(hex: 0xF5C542).cgColor
        let storyStack = UIStackView(arrangedSubviews: [
            UILabel.make("🧙 산신령 가라사대", font: AppFont.bold(14), color: UIColor(hex: 0xF5C542)),
            UILabel.make("", font: AppFont.medium(13), color: .white)
        ])
        storyStack.axis = .vertical
        storyStack.spacing = 8
        story.addSubview(storyStack)
        storyStack.snp.makeConstraints { $0.edges.equalToSuperview().inset(14) }

        // 뷰파인더 + 가이드
        let viewfinder = UIView()
        viewfinder.backgroundColor = UIColor(hex: 0x33333B)
        viewfinder.layer.cornerRadius = 16
        let guide = UIView()
        guide.layer.borderColor = AppColor.coral.cgColor
        guide.layer.borderWidth = 2
        guide.layer.cornerRadius = 12
        let guideLabel = UILabel.make("가이드에 맞춰 · 3초 촬영", font: AppFont.medium(13), color: .white, align: .center)
        viewfinder.addSubview(guide)
        viewfinder.addSubview(guideLabel)
        guide.snp.makeConstraints { $0.edges.equalToSuperview().inset(28) }
        guideLabel.snp.makeConstraints { $0.center.equalToSuperview() }

        // 촬영 버튼
        let capture = UIButton(type: .system)
        capture.backgroundColor = .white
        capture.layer.cornerRadius = 37
        capture.layer.borderWidth = 4
        capture.layer.borderColor = AppColor.coral.cgColor
        capture.addTarget(self, action: #selector(captureTapped), for: .touchUpInside)

        // 리워드 배너
        let reward = UIView()
        reward.backgroundColor = UIColor(hex: 0x2E2E36)
        reward.layer.cornerRadius = 14
        let rewardLabel = UILabel.make("🎁 로컬 럭키 드로우", font: AppFont.bold(13), color: AppColor.lime, align: .center)
        reward.addSubview(rewardLabel)
        rewardLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)) }

        view.addSubview(story)
        view.addSubview(viewfinder)
        view.addSubview(capture)
        view.addSubview(reward)

        story.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        reward.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        capture.snp.makeConstraints {
            $0.bottom.equalTo(reward.snp.top).offset(-16)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(74)
        }
        viewfinder.snp.makeConstraints {
            $0.top.equalTo(story.snp.bottom).offset(14)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(capture.snp.top).offset(-16)
        }
    }

    @objc private func captureTapped() {
        navigationController?.pushViewController(MissionCompleteViewController(), animated: true)
    }
}
