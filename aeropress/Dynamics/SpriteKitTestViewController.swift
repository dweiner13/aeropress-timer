//
//  SpriteKitTestViewController.swift
//  aeropress
//
//  Created by Dan Weiner on 10/17/21.
//

import UIKit
import SwiftUI
import SpriteKit

struct FieldConfig {
    internal init(strength: Float, enabled: Bool) {
        self.strength = strength
        self.enabled = enabled
    }

    var strength: Float
    var enabled: Bool

    static let empty = FieldConfig(strength: 1, enabled: true)

    init(field: SKFieldNode) {
        self.strength = field.strength
        self.enabled = field.isEnabled
    }
}

struct SpriteKitConfig {
    var vortex: FieldConfig
    var radialGravity: FieldConfig
    var electric: FieldConfig
    var drag: FieldConfig

    static let empty = SpriteKitConfig(vortex: .empty, radialGravity: .empty, electric: .empty, drag: .empty)
}

struct SpriteKitHarness: View {
    @State
    var config = SpriteKitConfig.empty

    var body: some View {
        VStack {
            SpriteKitTestViewControllerWrapper(config: $config)
                .ignoresSafeArea()
            Form {
                Section("Vortex") {
                    FieldConfigView(fieldConfig: $config.vortex)
                }
                Section("Radial gravity") {
                    FieldConfigView(fieldConfig: $config.radialGravity)
                }
                Section("Electric") {
                    FieldConfigView(fieldConfig: $config.electric)
                }
                Section("Drag") {
                    FieldConfigView(fieldConfig: $config.drag)
                }
            }
        }
    }
}

struct FieldConfigView: View {
    @Binding
    var fieldConfig: FieldConfig

    var body: some View {
        Group {
            Toggle("Enabled", isOn: $fieldConfig.enabled)
//            VStack(alignment: .leading) {
//                HStack {
//                    Text("Strength").foregroundColor(.secondary)
//                    Spacer()
//                    Text("\(fieldConfig.strength, format: .number.precision(.fractionLength(2)))")
//                }
//                Slider(value: $fieldConfig.strength, in: 0...5)
//            }
            TextField(value: $fieldConfig.strength, format: .number.precision(.fractionLength(2)),
                      prompt: Text("Strength")) {
                Text("00")
            }
            Slider(value: $fieldConfig.strength, in: 0...5)
        }
    }
}

struct Category: OptionSet {
    let rawValue: UInt32

    static let mug     = Category(rawValue: 1 << 0)
    static let grounds = Category(rawValue: 2 << 0)
}

class SpriteKitTestViewController: UIViewController {
    var scene: SKScene!

    var vortexField: SKFieldNode!
    var radialGravtityField: SKFieldNode!
    var electricField: SKFieldNode!
    var dragField: SKFieldNode!

    override func viewDidLoad() {
        view.backgroundColor = .white

        let skViewWidth: CGFloat = 300
        let skView = SKView(frame: CGRect(origin: view.center.applying(CGAffineTransform(translationX: -skViewWidth / 2, y: -skViewWidth)),
                                          size: CGSize(width: skViewWidth, height: skViewWidth)))
        view.addSubview(skView)

        scene = SKScene(size: skView.bounds.size)
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.physicsWorld.gravity = CGVector(dx: 0, dy: 0)

        let mug = SKSpriteNode(texture: SKTexture(image: circleImage(diameter: skView.bounds.width, color: .white)))
        scene.addChild(mug)

        let node = SKSpriteNode(color: .blue, size: CGSize(width: 20, height: 20))
        scene.addChild(node)

        let bounds = skView.bounds.offsetBy(dx: -skView.bounds.width / 2,
                                            dy: -skView.bounds.height / 2)

        let mugPhysicsBody = SKPhysicsBody(edgeLoopFrom: CGPath(ellipseIn: bounds, transform: nil))
        mugPhysicsBody.categoryBitMask = Category.mug.rawValue
        scene.physicsBody = mugPhysicsBody

        vortexField = SKFieldNode.vortexField()
        vortexField.strength = 0.1
        scene.addChild(vortexField)

        radialGravtityField = SKFieldNode.radialGravityField()
        radialGravtityField.strength = 0
        scene.addChild(radialGravtityField)

        electricField = SKFieldNode.electricField()
        electricField.strength = 0
        scene.addChild(electricField)

        dragField = SKFieldNode.dragField()
        scene.addChild(dragField)

        addCoffeeGrounds()

        skView.presentScene(scene)
    }

    func addCoffeeGrounds() {
        let TOTAL = 100
        let image = circleImage(diameter: 10, color: .red)
        let texture = SKTexture(image: image)
        for i in 0 ..< TOTAL {
            let SIZE = CGSize(width: 10, height: 10)
            let sprite = SKSpriteNode(texture: texture)
            let sceneRadius = scene.size.width / 2
            sprite.position = CGPoint(x: .random(in: -sceneRadius...sceneRadius),
                                      y: .random(in: -sceneRadius...sceneRadius))
            let physicsBody = SKPhysicsBody(circleOfRadius: SIZE.width / 2)
            physicsBody.categoryBitMask = Category.grounds.rawValue
            physicsBody.collisionBitMask = Category.mug.rawValue
            physicsBody.density = .random(in: 100...300)
            physicsBody.charge = -1
            sprite.physicsBody = physicsBody
            scene.addChild(sprite)
        }
    }

    func circleImage(diameter: CGFloat, color: SKColor) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: diameter,
                                                            height: diameter))
        return renderer.image { context in
            let cgContext = context.cgContext
            context.cgContext.setFillColor(color.cgColor)
            cgContext.fillEllipse(in: CGRect(origin: .zero,
                                             size: CGSize(width: diameter, height: diameter)))
            // CGContextFillEllipseInRect(context.CGContext, CGRectMake(60, 60, 140, 140));
//            context.cgContext.beginPath()
//            context.cgContext.addArc(center: CGPoint(x: radius / 2, y: radius / 2),
//                                     radius: radius,
//                                     startAngle: 0,
//                                     endAngle: .pi,
//                                     clockwise: true)
//            context.cgContext.closePath()
        }
    }

    func setConfig(_ config: SpriteKitConfig) {
        vortexField.isEnabled = config.vortex.enabled
        vortexField.strength = config.vortex.strength

        radialGravtityField.isEnabled = config.radialGravity.enabled
        radialGravtityField.strength = config.radialGravity.strength

        electricField.isEnabled = config.electric.enabled
        electricField.strength = config.electric.strength

        dragField.isEnabled = config.drag.enabled
        dragField.strength = config.drag.strength
    }
}

struct SpriteKitTestViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = SpriteKitTestViewController

    @Binding
    var config: SpriteKitConfig

    func makeUIViewController(context: Context) -> SpriteKitTestViewController {
        SpriteKitTestViewController()
    }

    func updateUIViewController(_ uiViewController: SpriteKitTestViewController, context: Context) {
        uiViewController.setConfig(config)
    }
}

struct SpriteKitTestViewController_Previews: PreviewProvider {
    static var previews: some View {
        SpriteKitHarness()
    }
}
