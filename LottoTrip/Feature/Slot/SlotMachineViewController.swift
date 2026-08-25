//
//  SlotMachineViewController.swift
//  LottoTrip
//
//  운명의 슬롯 — v2 퍼즐 뽑기.
//  "나만의 여행 퍼즐이 준비됐어요!" → [뽑기] → 한 조각 당첨 → "운명의 목적지 당첨! 눌러서 확인 / 한 번 더"
//

import UIKit
import SnapKit

// MARK: - 직소 조각 칩 (회색=대기 / 코랄=당첨)

final class PuzzleChip: UIView {
    private let shape = CAShapeLayer()
    init() {
        super.init(frame: .zero)
        shape.fillColor = AppColor.tileEmpty.cgColor
        layer.addSublayer(shape)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func layoutSubviews() {
        super.layoutSubviews()
        shape.path = PuzzlePieceView.jigsawPath(in: bounds).cgPath
    }
    func setWon(_ won: Bool) {
        shape.fillColor = (won ? AppColor.coral : AppColor.tileEmpty).cgColor
    }
}

/// 검정 원형 버튼 (뽑기 / 한 번 더) — 치수 가이드 기준.
final class CircleButton: UIButton {
    init(title: String) {
        super.init(frame: .zero)
        backgroundColor = AppColor.ink
        setAttributedTitle(NSAttributedString(string: title, attributes: [
            .font: AppFont.semibold(17), .foregroundColor: UIColor.white, .kern: -0.5
        ]), for: .normal)
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
    func setEnabledLook(_ on: Bool) {
        isEnabled = on
        backgroundColor = on ? AppColor.ink : AppColor.tileEmpty
    }
}

final class SlotMachineViewController: UIViewController {

    private enum Phase { case ready, drawing, won }

    /// 취향 설정값 — 온보딩(TripPreferenceStore)에서 읽어오고, 없으면 기본값.
    /// budget 은 백엔드 계약상 "원 정수". 미입력 시 10만원 기본.
    var budgetWon: Int { max(TripPreferenceStore.shared.current.budgetWon, 100_000) }
    var transport: TransportType { TripPreferenceStore.shared.current.transport?.transportType ?? .car }

    private let titleLabel = UILabel.make("나만의 여행 퍼즐이\n준비됐어요!", font: AppFont.semibold(24), color: AppColor.ink, align: .center)
    private let gridView = UIView()
    private var chips: [PuzzleChip] = []
    private let drawButton = CircleButton(title: "뽑기")

    // 당첨 오버레이
    private let overlay = UIView()
    private let wonChip = PuzzleChip()
    private let againButton = CircleButton(title: "한 번 더")

    private var drawnResult: SlotDrawResponseDTO?
    private var phase: Phase = .ready

    private let columns = 4
    private let rows = 4

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppColor.ivory
        navigationItem.title = "운명의 슬롯"

        buildGrid()
        drawButton.addTarget(self, action: #selector(drawTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [titleLabel, gridView])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 28
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.leading.trailing.equalToSuperview().inset(28)
        }
        gridView.snp.makeConstraints { $0.height.equalTo(gridView.snp.width).multipliedBy(CGFloat(rows) / CGFloat(columns)) }

        // 뽑기 = 검정 원형 버튼 (하단 중앙)
        view.addSubview(drawButton)
        drawButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(36)
            $0.size.equalTo(112)
        }

        buildOverlay()

        // 스크린샷/미리보기용 디버그 훅: AUTO_SPIN=1 이면 진입 직후 자동 뽑기
        if ProcessInfo.processInfo.environment["AUTO_SPIN"] == "1" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in self?.drawTapped() }
        }
    }

    // MARK: - 퍼즐 그리드

    private func buildGrid() {
        for _ in 0..<(rows * columns) {
            let chip = PuzzleChip()
            gridView.addSubview(chip)
            chips.append(chip)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutChips()
    }

    private func layoutChips() {
        let w = gridView.bounds.width
        guard w > 0 else { return }
        let cellW = w / CGFloat(columns)
        let cellH = gridView.bounds.height / CGFloat(rows)
        for (i, chip) in chips.enumerated() {
            let r = i / columns, c = i % columns
            // 맞물리는 느낌을 위해 짝수행은 살짝 밀어서 배치
            let offset: CGFloat = (r % 2 == 0) ? 0 : cellW * 0.12
            chip.frame = CGRect(x: CGFloat(c) * cellW + offset, y: CGFloat(r) * cellH,
                                width: cellW, height: cellH)
        }
    }

    // MARK: - 당첨 오버레이

    private func buildOverlay() {
        overlay.backgroundColor = AppColor.ivory
        overlay.isHidden = true
        view.addSubview(overlay)
        overlay.snp.makeConstraints { $0.edges.equalToSuperview() }

        let wonTitle = UILabel.make("운명의 목적지 당첨!", font: AppFont.semibold(24), color: AppColor.ink, align: .center)
        wonChip.setWon(true)
        wonChip.transform = CGAffineTransform(rotationAngle: 12 * .pi / 180)   // 치수: 회전 12°
        let hint = UILabel.make("눌러서 확인", font: AppFont.medium(13), color: AppColor.sub, align: .center)

        // 카드 자체를 탭하면 확인 (치수 가이드: 카드 안 "눌러서 확인")
        let card = UIView()
        card.backgroundColor = .white
        card.layer.cornerRadius = 20
        card.layer.shadowColor = UIColor.black.cgColor
        card.layer.shadowOpacity = 0.08
        card.layer.shadowRadius = 12
        card.layer.shadowOffset = CGSize(width: 0, height: 4)
        card.addSubview(wonChip)
        card.addSubview(hint)
        wonChip.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(120)
        }
        hint.snp.makeConstraints {
            $0.top.equalTo(wonChip.snp.bottom).offset(14)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
        }
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(confirmTapped)))

        // 한 번 더 = 검정 원형
        againButton.addTarget(self, action: #selector(againTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [wonTitle, card])
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 24
        overlay.addSubview(stack)
        overlay.addSubview(againButton)
        stack.snp.makeConstraints {
            $0.centerY.equalTo(overlay.safeAreaLayoutGuide).offset(-40)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
        againButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(overlay.safeAreaLayoutGuide).inset(36)
            $0.size.equalTo(112)
        }
    }

    // MARK: - 뽑기 흐름

    @objc private func drawTapped() {
        guard phase == .ready else { return }
        phase = .drawing
        drawButton.setEnabledLook(false)
        startShuffle()

        LocationProvider.shared.current { [weak self] coordinate in
            guard let self else { return }
            APIClient.shared.slot.draw(
                latitude: coordinate.latitude, longitude: coordinate.longitude,
                budget: self.budgetWon, transport: self.transport
            ) { [weak self] outcome in
                guard let self else { return }
                // 응답이 빨라도 최소 1.2초 뽑기 연출 유지 (draw 평균 4.6s 대비 커버)
                self.afterDelay(1.2) {
                    self.stopShuffle()
                    switch outcome {
                    case .success(let result):
                        self.drawnResult = result
                        self.revealWinner()
                    case .failure(let error):
                        self.resetToReady()
                        self.handle(error)
                    }
                }
            }
        }
    }

    private func startShuffle() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.repeat, .autoreverse]) {
            self.gridView.alpha = 0.45
        }
    }
    private func stopShuffle() {
        gridView.layer.removeAllAnimations()
        gridView.alpha = 1
    }

    /// 임의 한 조각을 당첨(코랄) 처리한 뒤 오버레이로 전환
    private func revealWinner() {
        let winner = Int.random(in: 0..<chips.count)
        for (i, chip) in chips.enumerated() { chip.setWon(i == winner) }
        phase = .won
        afterDelay(0.6) {
            self.overlay.alpha = 0
            self.overlay.isHidden = false
            UIView.animate(withDuration: 0.3) { self.overlay.alpha = 1 }
        }
    }

    @objc private func confirmTapped() {
        guard let result = drawnResult else { return }
        navigationController?.pushViewController(ResultViewController(result: result), animated: true)
    }

    @objc private func againTapped() {
        overlay.isHidden = true
        drawnResult = nil
        resetToReady()
        drawTapped()
    }

    private func resetToReady() {
        chips.forEach { $0.setWon(false) }
        phase = .ready
        drawButton.setEnabledLook(true)
    }

    // MARK: - 헬퍼

    private func afterDelay(_ s: TimeInterval, _ block: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + s, execute: block)
    }

    private func handle(_ error: NetworkError) {
        let message: String
        switch error.errorCode {
        case .noPlaceFound: message = "반경 내 후보 장소가 없어요. 이동수단/예산을 바꿔보세요."
        default:            message = error.description
        }
        let alert = UIAlertController(title: "뽑기 실패", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
