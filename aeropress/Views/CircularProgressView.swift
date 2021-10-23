//
//  CircularProgressView.swift
//  aeropress
//
//  Created by Dan Weiner on 10/19/21.
//

import SwiftUI

@propertyWrapper
struct Clamped<T: BinaryFloatingPoint> {
    static func clamp(_ value: T, range: ClosedRange<T>) -> T {
        if value > range.upperBound {
            return range.upperBound
        } else if value < range.lowerBound {
            return range.lowerBound
        } else {
            return value
        }
    }

    var wrappedValue: T {
        didSet {
            wrappedValue = Self.clamp(wrappedValue, range: range)
        }
    }
    let range: ClosedRange<T>

    init(wrappedValue: T, range: ClosedRange<T>) {
        self.range = range
        self.wrappedValue = Self.clamp(wrappedValue, range: range)
    }
}

struct FractionalCircle: Shape {
    @Clamped(range: 0...1)
    var fraction: Float = 0

    func path(in rect: CGRect) -> Path {
        Path { path in
            path.addArc(center: CGPoint(x: 0.5 * rect.width, y: 0.5 * rect.height),
                        radius: 0.5 * min(rect.width, rect.height),
                        startAngle: .degrees(270),
                        endAngle: .degrees(270 + 360 * Double(fraction)),
                        clockwise: false)
        }
    }
}

struct CircularProgressView: View {
    @Clamped(range: 0...1)
    var progress: Float = 0

    var body: some View {
        GeometryReader { proxy in
            FractionalCircle(fraction: progress)
                .stroke(Color.accentColor,
                        style: StrokeStyle(
                            lineWidth: min(proxy.size.height, proxy.size.width) / 5,
                            lineCap: CGLineCap.round))
        }
    }
}

struct CircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            CircularProgressView(progress: 0.1).frame(width: 100, height: 100)
            CircularProgressView(progress: 0.333).frame(width: 100, height: 100)
            CircularProgressView(progress: 0.6).frame(width: 100, height: 100)
            CircularProgressView(progress: 0.9).frame(width: 100, height: 100)
        }
    }
}
