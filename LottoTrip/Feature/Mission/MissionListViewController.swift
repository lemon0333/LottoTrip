//
//  MissionListViewController.swift
//  LottoTrip
//
//  산신령 임무 리스트 — 조각별 임무 진입.
//

import UIKit
import SnapKit

final class MissionListViewController: BaseScrollViewController {

    private var missions = MissionSampleData.missions

    /// 디버그 훅: ALL_CLEAR=1 이면 전체 완료 처리 + 지역 해금 배지 노출
    private var allClearDebug: Bool {
        ProcessInfo.processInfo.environment["ALL_CLEAR"] == "1"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "임무"

        if allClearDebug {
            for i in missions.indices { missions[i].completed = true }
            addUnlockBadge()
        }

        contentStack.addArrangedSubview(headerRow("산신령의 임무", right: "\(completedCount)/\(missions.count)", rightColor: AppColor.coral))
        contentStack.addArrangedSubview(UILabel.make("임무를 완료하면 퍼즐 조각이 채워져요", font: AppFont.medium(13), color: AppColor.cafe))
        for mission in missions {
            contentStack.addArrangedSubview(makeRow(mission))
        }
    }

    private var completedCount: Int { missions.filter { $0.completed }.count }

    // MARK: - 임무 행

    private func makeRow(_ mission: MissionItem) -> UIControl {
        let row = MissionRow(mission: mission)
        row.addTarget(self, action: #selector(rowTapped(_:)), for: .touchUpInside)
        return row
    }

    @objc private func rowTapped(_ sender: MissionRow) {
        guard !sender.mission.completed else { return }   // 완료된 임무는 진입 불가
        navigationController?.pushViewController(MissionDetailViewController(mission: sender.mission), animated: true)
    }

    // MARK: - 지역 해금 배지 (디버그)

    private func addUnlockBadge() {
        let badge = UIView()
        badge.backgroundColor = AppColor.coral
        badge.layer.cornerRadius = 4
        badge.isUserInteractionEnabled = true
        badge.snp.makeConstraints { $0.size.equalTo(16) }
        badge.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goAllClear)))

        // 깜빡이는 애니메이션
        let blink = CABasicAnimation(keyPath: "opacity")
        blink.fromValue = 1.0
        blink.toValue = 0.2
        blink.duration = 0.6
        blink.autoreverses = true
        blink.repeatCount = .infinity
        badge.layer.add(blink, forKey: "blink")

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: badge)
    }

    @objc private func goAllClear() {
        navigationController?.pushViewController(MissionAllClearViewController(), animated: true)
    }
}

// MARK: - MissionRow

private final class MissionRow: UIControl {

    let mission: MissionItem

    init(mission: MissionItem) {
        self.mission = mission
        super.init(frame: .zero)

        backgroundColor = AppColor.card
        layer.cornerRadius = 16
        layer.borderWidth = 1
        layer.borderColor = AppColor.line.cgColor

        // 완료 시 pink 조각, 미완료 coral 조각
        let icon = SquarePuzzleView(fill: mission.completed ? AppColor.dustyPink : AppColor.coral, side: 54)
        icon.isUserInteractionEnabled = false

        let title = UILabel.make(mission.title, font: AppFont.bold(16), color: AppColor.ink)

        let chevron = UIImageView(image: UIImage(systemName: "chevron.right"))
        chevron.tintColor = AppColor.sub
        chevron.contentMode = .scaleAspectFit
        chevron.setContentHuggingPriority(.required, for: .horizontal)

        addSubview(icon)
        addSubview(title)
        addSubview(chevron)

        icon.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(14)
            $0.top.bottom.equalToSuperview().inset(14)
        }
        title.snp.makeConstraints {
            $0.leading.equalTo(icon.snp.trailing).offset(14)
            $0.centerY.equalToSuperview()
        }
        chevron.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(title.snp.trailing).offset(8)
            $0.width.equalTo(12)
        }

        // 완료된 임무는 흐리게 표시
        alpha = mission.completed ? 0.4 : 1.0
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}
