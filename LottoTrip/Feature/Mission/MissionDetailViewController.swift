//
//  MissionDetailViewController.swift
//  LottoTrip
//
//  산신령 챗봇 스토리텔링 + GPS 인증 촬영.
//

import UIKit
import SnapKit

final class MissionDetailViewController: BaseScrollViewController {

    private let mission: MissionItem

    init(mission: MissionItem) {
        self.mission = mission
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = mission.title

        contentStack.addArrangedSubview(chatHeader())
        for line in mission.narratorLines {
            contentStack.addArrangedSubview(speechBubble(line))
        }
        contentStack.addArrangedSubview(missionCard())
        contentStack.addArrangedSubview(captureArea())

        // 촬영 버튼에 가리지 않도록 하단 여백
        let bottomSpacer = UIView()
        bottomSpacer.snp.makeConstraints { $0.height.equalTo(90) }
        contentStack.addArrangedSubview(bottomSpacer)

        addFloatingCaptureButton()
    }

    // MARK: - 챗봇 헤더 (아바타 + 이름)

    private func chatHeader() -> UIStackView {
        let avatar = UIView()
        avatar.backgroundColor = AppColor.tileEmpty
        avatar.layer.cornerRadius = 20
        avatar.snp.makeConstraints { $0.size.equalTo(40) }
        let face = UILabel.make("🧙", font: AppFont.regular(20), color: AppColor.ink, align: .center)
        avatar.addSubview(face)
        face.snp.makeConstraints { $0.center.equalToSuperview() }

        let name = UILabel.make("산신령", font: AppFont.bold(15), color: AppColor.ink)

        let row = UIStackView(arrangedSubviews: [avatar, name])
        row.axis = .horizontal
        row.alignment = .center
        row.spacing = 10
        let spacer = UIView(); spacer.setContentHuggingPriority(UILayoutPriority(1), for: .horizontal)
        row.addArrangedSubview(spacer)
        return row
    }

    // MARK: - 말풍선

    private func speechBubble(_ text: String) -> UIView {
        let bubble = UIView()
        bubble.backgroundColor = AppColor.card
        bubble.layer.cornerRadius = 14
        bubble.layer.borderWidth = 1
        bubble.layer.borderColor = AppColor.line.cgColor
        let label = UILabel.make(text, font: AppFont.medium(14), color: AppColor.ink)
        bubble.addSubview(label)
        label.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 12, left: 14, bottom: 12, right: 14)) }

        // 왼쪽 정렬 — 화면 폭을 다 채우지 않도록 우측에 여백
        let container = UIView()
        container.addSubview(bubble)
        bubble.snp.makeConstraints {
            $0.top.bottom.leading.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview().inset(40)
        }
        return container
    }

    // MARK: - 임무 카드

    private func missionCard() -> CardView {
        let card = CardView()
        card.addArranged(
            UILabel.make(mission.title, font: AppFont.bold(16), color: AppColor.coral),
            UILabel.make(mission.guide, font: AppFont.medium(13), color: AppColor.sub)
        )
        return card
    }

    // MARK: - 카메라 프리뷰 자리 (회색 캡처 영역)

    private func captureArea() -> UIView {
        let area = UIView()
        area.backgroundColor = AppColor.tileEmpty
        area.layer.cornerRadius = 16
        area.snp.makeConstraints { $0.height.equalTo(260) }

        let plus = UIImageView(image: UIImage(systemName: "plus"))
        plus.tintColor = AppColor.sub
        plus.contentMode = .scaleAspectFit
        area.addSubview(plus)
        plus.snp.makeConstraints { $0.center.equalToSuperview(); $0.size.equalTo(36) }
        return area
    }

    // MARK: - 촬영 버튼 (하단 고정)

    private func addFloatingCaptureButton() {
        let button = UIButton(type: .system)
        button.backgroundColor = AppColor.coral
        button.layer.cornerRadius = 32
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.white.cgColor
        button.addTarget(self, action: #selector(captureTapped), for: .touchUpInside)

        view.addSubview(button)
        button.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.size.equalTo(64)
        }
    }

    // MARK: - GPS 인증 완료

    @objc private func captureTapped() {
        // GPS 인증이 확정 방식, 사진은 선택 → mediaUrl nil 로 완료 요청
        LocationProvider.shared.current { [weak self] coord in
            guard let self else { return }
            APIClient.shared.mission.complete(
                missionId: self.mission.missionId,
                latitude: coord.latitude,
                longitude: coord.longitude
            ) { [weak self] result in
                switch result {
                case .success:
                    self?.showComplete()
                case .failure(let error):
                    self?.showFailure(error)
                }
            }
        }
    }

    private func showComplete() {
        let alert = UIAlertController(title: "미션 완료!", message: "산신령이 흡족해하며 퍼즐 조각을 내어줍니다.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }

    private func showFailure(_ error: NetworkError) {
        let message: String
        switch error.errorCode {
        case .verificationFailed: message = "위치 인증에 실패했어요. 장소 근처에서 다시 시도해주세요."
        case .alreadyCompleted:   message = "이미 완료한 미션이에요."
        default:                  message = error.description
        }
        let alert = UIAlertController(title: "인증 실패", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
