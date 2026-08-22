//
//  SlotMachineViewController.swift
//  LottoTrip
//
//  운명의 슬롯 — 취향 기반 랜덤 목적지 뽑기.
//

import UIKit
import SnapKit

// 콘 그라디언트로 만든 룰렛 휠
final class WheelView: UIView {
    private let conic = CAGradientLayer()
    private let hub = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        conic.type = .conic
        conic.startPoint = CGPoint(x: 0.5, y: 0.5)
        conic.endPoint = CGPoint(x: 0.5, y: 0.0)
        let cs = AppColor.pieceColors
        conic.colors = (cs + [cs[0]]).map { $0.cgColor }
        layer.addSublayer(conic)
        hub.backgroundColor = .white
        addSubview(hub)
        layer.borderWidth = 3
        layer.borderColor = UIColor.white.cgColor
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    override func layoutSubviews() {
        super.layoutSubviews()
        conic.frame = bounds
        layer.cornerRadius = bounds.width / 2
        clipsToBounds = true
        let hs: CGFloat = 64
        hub.frame = CGRect(x: (bounds.width - hs) / 2, y: (bounds.height - hs) / 2, width: hs, height: hs)
        hub.layer.cornerRadius = hs / 2
    }
}

final class SlotMachineViewController: UIViewController {

    private let wheel = WheelView()
    private let spin = UIButton(type: .system)

    /// 취향 설정값 — 온보딩(TripPreferenceStore)에서 읽어오고, 없으면 기본값.
    var budget: BudgetLevel { TripPreferenceStore.shared.current.budgetLevel }
    var transport: TransportType { TripPreferenceStore.shared.current.transport?.transportType ?? .car }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0x5A4A88)
        navigationItem.title = "운명의 슬롯"

        let tag = ChipView(text: "강원도 · 감자 운명 공동체")
        let title = UILabel.make("운명의 목적지 뽑기", font: AppFont.bold(26), color: .white, align: .center)
        let desc = UILabel.make("여러분의 운에 여행을 맡겨보세요", font: AppFont.regular(14), color: .white, align: .center)

        spin.backgroundColor = AppColor.lime
        spin.setAttributedTitle(NSAttributedString(string: "SPIN",
            attributes: [.font: AppFont.bold(22), .foregroundColor: UIColor.white]), for: .normal)
        spin.layer.cornerRadius = 58
        spin.layer.borderWidth = 4
        spin.layer.borderColor = UIColor.white.cgColor
        spin.addTarget(self, action: #selector(spinTapped), for: .touchUpInside)

        let hint = UILabel.make("여러 번 돌릴 수 있어요 ↻", font: AppFont.medium(13), color: .white, align: .center)

        let stack = UIStackView(arrangedSubviews: [tag, title, desc, wheel, spin, hint])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20
        stack.setCustomSpacing(28, after: desc)
        view.addSubview(stack)
        stack.snp.makeConstraints {
            $0.center.equalTo(view.safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        wheel.snp.makeConstraints { $0.size.equalTo(248) }
        spin.snp.makeConstraints { $0.size.equalTo(116) }

        // 스크린샷/미리보기용 디버그 훅: AUTO_SPIN=1 이면 진입 직후 자동 SPIN
        if ProcessInfo.processInfo.environment["AUTO_SPIN"] == "1" {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in self?.spinTapped() }
        }
    }

    @objc private func spinTapped() {
        startSpinning()

        // 현재 좌표 → 슬롯 draw 요청 (예산·이동수단 가중치는 서버 내부 처리)
        LocationProvider.shared.current { [weak self] coordinate in
            guard let self else { return }
            APIClient.shared.slot.draw(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                budget: self.budget,
                transport: self.transport
            ) { [weak self] outcome in
                guard let self else { return }
                switch outcome {
                case .success(let result):
                    // 룰렛 애니메이션이 끝나는 타이밍에 맞춰 결과 화면으로 전환
                    self.afterSpin {
                        self.stopSpinning()
                        self.navigationController?.pushViewController(
                            ResultViewController(result: result), animated: true)
                    }
                case .failure(let error):
                    self.afterSpin {
                        self.stopSpinning()
                        self.handle(error)
                    }
                }
            }
        }
    }

    // MARK: - 애니메이션 / 로딩 상태

    private func startSpinning() {
        spin.isEnabled = false
        spin.alpha = 0.6
        let anim = CABasicAnimation(keyPath: "transform.rotation")
        anim.fromValue = 0
        anim.toValue = CGFloat.pi * 6
        anim.duration = 1.2
        anim.timingFunction = CAMediaTimingFunction(name: .easeOut)
        anim.repeatCount = .infinity   // 응답이 늦어도 계속 회전
        wheel.layer.add(anim, forKey: "spin")
    }

    private func stopSpinning() {
        wheel.layer.removeAnimation(forKey: "spin")
        spin.isEnabled = true
        spin.alpha = 1
    }

    /// 최소 1.1초 회전을 보장한 뒤 completion 실행 (너무 빠른 응답에도 슬롯 연출 유지)
    private func afterSpin(_ completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.1, execute: completion)
    }

    private func handle(_ error: NetworkError) {
        let message: String
        switch error.errorCode {
        case .noPlaceFound: message = "반경 내 후보 장소가 없어요. 이동수단/예산을 바꿔보세요."
        default:            message = error.description
        }
        let alert = UIAlertController(title: "슬롯 실패", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
