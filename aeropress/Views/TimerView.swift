//
//  TimerView.swift
//  aeropress
//
//  Created by Dan Weiner on 10/3/21.
//

import SwiftUI
import CoreData
import AVFoundation

enum Stage: CustomStringConvertible {
    case getReady
    case step(RecipeStep)
    case done

    var step: RecipeStep? {
        guard case .step(let step) = self else {
            return nil
        }
        return step
    }

    var description: String {
        switch self {
        case .getReady:
            return "Get ready"
        case .step(let step):
            return step.unwrappedKind.description
        case .done:
            return "Done. Enjoy!"
        }
    }

    var attributedDescription: AttributedString {
        switch self {
        case .getReady:
            return .init("Get ready")
        case .step(let step):
            return .init(step.unwrappedKind.description)
        case .done:
            var s = AttributedString("Done. Enjoy!")
            s[s.range(of: "Enjoy!")!].accessibilitySpeechAdjustedPitch = 2
            return s
        }
    }
}

/// - precondition: `0 <= f <= 1`
func AVSpeechRateFromFraction(_ f: Float) -> Float {
    precondition(f >= 0 && f <= 1, "0 <= f <= 1")
    let (max, min) = (AVSpeechUtteranceMaximumSpeechRate, AVSpeechUtteranceMinimumSpeechRate)
    return min + (max - min) * f
}

class TimerModel: ObservableObject {
    @Published var currentStage: Stage

    var timer: Timer?

    var countdownTimer: Timer?

    let recipe: Recipe

    let steps: [RecipeStep]

    init(recipe: Recipe) {
        self.recipe = recipe
        self.steps = recipe.unwrappedSteps.array as! [RecipeStep]
        self.currentStage = .getReady
    }

    func stage(after stage: Stage) -> Stage? {
        switch stage {
        case .getReady:
            return .step(steps.last!)
        case .step(let step):
            guard let index = steps.firstIndex(of: step) else {
                fatalError("uhhh")
            }
            guard steps.indices.contains(index + 1) else {
                return .done
            }
            return .step(steps[index + 1])
        case .done:
            return nil
        }
    }

    func start() {
        goToNextStage()
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
        countdownTimer?.invalidate()
        countdownTimer = nil
        currentStage = .getReady
    }

    @Published
    var timeToNextFire: TimeInterval?

    let synthesizer = AVSpeechSynthesizer()

    deinit {
        print("denit... invalidating...")
        timer?.invalidate()
        countdownTimer?.invalidate()
    }

    private func goToNextStage() {
        guard let nextStage = stage(after: currentStage) else { fatalError() }

        self.currentStage = nextStage

        playDing()

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.readText(nextStage.attributedDescription)
        }

        guard case .step(let step) = nextStage else { return }

//        let timeInterval = TimeInterval(step.durationSeconds)
        let timeInterval: TimeInterval = 5
        let nextStageTimer = Timer.scheduledTimer(withTimeInterval: timeInterval,
                                                  repeats: false) { [weak self] timer in
            print("nextStageTimer firing...")
            guard let self = self else {
                return
            }
            timer.invalidate()
            self.timer = nil
            self.goToNextStage()
        }
        timer = nextStageTimer
        timeToNextFire = max(0, nextStageTimer.fireDate.timeIntervalSinceNow)

        if countdownTimer == nil {
            countdownTimer = .scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { [weak self] timer in
                guard let self = self else {
                    return
                }
                self.timeToNextFire = max(0, self.timer?.fireDate.timeIntervalSinceNow ?? -1)
            })
        }
    }

    private func playDing() {
        let url = Bundle.main.url(forResource: "ding", withExtension: "wav")!
        var soundID: SystemSoundID = 0
        AudioServicesCreateSystemSoundID(url as CFURL, &soundID)
        guard soundID != 0 else {
            fatalError("Could not play sound")
        }
        AudioServicesPlaySystemSound(soundID)
    }

    private func readText(_ attrString: AttributedString) {
        let utterance = AVSpeechUtterance(attributedString: NSAttributedString(attrString))
        utterance.rate = AVSpeechRateFromFraction(0.4)
        utterance.pitchMultiplier = 1.2
        synthesizer.speak(utterance)
    }
}

struct TimerView: View {
    @StateObject
    var timerModel: TimerModel

    @State
    var timeToNextFire: TimeInterval?

    @Environment(\.dismiss)
    var dismiss

    init(recipe: Recipe) {
        _timerModel = StateObject(wrappedValue: TimerModel(recipe: recipe))
    }

    var timeRemaining: String {
        guard let timeToNextFire = timerModel.timeToNextFire else {
            return ""
        }

        return floor(timeToNextFire).formatted(.number.precision(.fractionLength(0)))
    }

    var body: some View {
        ZStack(alignment: .center) {
            VStack(spacing: 24) {
                switch timerModel.currentStage {
                case .getReady:
                    Text("Get ready!")
                        .font(.largeTitle)
                    Button("Start", action: { timerModel.start() })
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .font(.title.bold())
                case .done:
                    Text("Done")
                case .step(let step):
                    Text("\(step.unwrappedKind.description)")
                        .font(.largeTitle)
                    Text(timeRemaining)
                        .font(.largeTitle.bold())
                }
            }
            VStack {
                Spacer()
                Button("Cancel", action: { self.timerModel.cancel(); self.dismiss() } )
                    .buttonStyle(.bordered)
            }
        }
    }
}

struct TimerView_Previews: PreviewProvider {
    static var previews: some View {
        TimerView(recipe: PersistenceController.previewRecipes().first!)
    }
}
