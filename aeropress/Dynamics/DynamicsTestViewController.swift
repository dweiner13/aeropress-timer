//
//  DynamicsTestViewController.swift
//  aeropress
//
//  Created by Dan Weiner on 10/17/21.
//

import UIKit
import SwiftUI

class EllipticalCollisionBoundsView: UIView {
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        .ellipse
    }

    override class var layerClass: AnyClass {
        CAShapeLayer.self
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        (self.layer as! CAShapeLayer).path = UIBezierPath(ovalIn: bounds).reversing().cgPath
        (self.layer as! CAShapeLayer).fillColor = UIColor.brown.cgColor
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Don't call init(coder:)")
    }
}

class WaterView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = UIColor.blue.withAlphaComponent(0.3)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Don't call init(coder:)")
    }
}

class DynamicsTestViewController: UIViewController {

    private let kBoundaryIdentifier: NSString = "kBoundaryIdentifier"

    var animator: UIDynamicAnimator!
    var gravityBehavior: UIGravityBehavior!
    var collisionBehavior: UICollisionBehavior!
    var waterView: WaterView!
    var dragFieldBehavior: UIFieldBehavior!

    override func viewDidLoad() {
        view.backgroundColor = .white

        waterView = WaterView(frame: .zero)
        view.addSubview(waterView)
        waterView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            waterView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            waterView.topAnchor.constraint(equalTo: view.centerYAnchor),
            waterView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            waterView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        setUpBehaviors()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        dragFieldBehavior.region = UIRegion(size: waterView.frame.size)
        dragFieldBehavior.position = waterView.center
    }

    func setUpBehaviors() {
        animator = UIDynamicAnimator(referenceView: view)

        gravityBehavior = UIGravityBehavior(items: [])
        gravityBehavior.setAngle(gravityBehavior.angle, magnitude: 0.1)

        collisionBehavior = UICollisionBehavior(items: [])
        collisionBehavior.setTranslatesReferenceBoundsIntoBoundary(with: .zero)

//        dragFieldBehavior = UIFieldBehavior.dragField()
//        dragFieldBehavior.strength = 0.05

//        dragFieldBehavior = UIFieldBehavior.turbulenceField(smoothness: 0.5, animationSpeed: 5)
//        dragFieldBehavior.strength = 1

        dragFieldBehavior = UIFieldBehavior.vortexField()
        dragFieldBehavior.strength = 0.004

        animator.addBehavior(gravityBehavior)
        animator.addBehavior(collisionBehavior)
        animator.addBehavior(dragFieldBehavior)

        addCoffeeGrounds()
    }

    func addCoffeeGrounds() {
        let TOTAL = 500
        for i in 0 ..< TOTAL {
            let frame = CGRect(x: CGFloat.random(in: 0..<view.bounds.width),
                               y: CGFloat.random(in: 0..<view.bounds.height / 5),
                               width: 10,
                               height: 10)
            let ground = EllipticalCollisionBoundsView(frame: frame)
            view.insertSubview(ground, aboveSubview: waterView)
            gravityBehavior.addItem(ground)
            collisionBehavior.addItem(ground)
            dragFieldBehavior.addItem(ground)
        }
    }
}

struct DynamicsTestViewControllerWrapper: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIViewController

    func makeUIViewController(context: Context) -> UIViewController {
        DynamicsTestViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // do nothing
    }
}

struct DynamicsTestViewController_Previews: PreviewProvider {
    static var previews: some View {
        DynamicsTestViewControllerWrapper()
            .edgesIgnoringSafeArea(.all)
    }
}
