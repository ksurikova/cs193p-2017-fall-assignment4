//
//  CardBehaviour.swift
//  cs193p-2017-fall-assignment4
//
//  Created by Ksenia Surikova on 18.04.2022.
//

import UIKit

class CardBehavior: UIDynamicBehavior {
    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()

    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = true
        behavior.elasticity = 1.0
        behavior.resistance = 0
        return behavior
    }()

    private func push(_ item: UIDynamicItem) {
        let push = UIPushBehavior(items: [item], mode: .instantaneous)
        if let referenceBounds = dynamicAnimator?.referenceView?.bounds {
            let center = CGPoint(x: referenceBounds.midX, y: referenceBounds.midY)
            switch (item.center.x, item.center.y) {
            case let (x, y) where x < center.x && y < center.y:
                push.angle = atan((center.y - y) / (center.x - x))
            case let (x, y) where x > center.x && y < center.y:
                push.angle = CGFloat.pi/2 + atan((x-center.x) / (center.y - y) )
            case let (x, y) where x < center.x && y > center.y:
                push.angle = -atan((y - center.y) / (center.x - x) )
            case let (x, y) where x > center.x && y > center.y:
                push.angle = CGFloat.pi + atan((center.y - y) / (center.x - x))
            case let (x, y) where x == center.x:
                push.angle = center.y > y ? CGFloat.pi/2 : -CGFloat.pi/2
            default:
                push.angle = center.x > item.center.x ? 0 : CGFloat.pi
            }
            push.magnitude = CGFloat(5.0)
            push.action = { [unowned push, weak self] in
                self?.removeChildBehavior(push)
            }
            addChildBehavior(push)
        }
    }

    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
        push(item)
    }

    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }

    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }

    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
}
