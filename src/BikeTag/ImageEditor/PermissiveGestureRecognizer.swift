//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

import UIKit

// The most permissive GR possible.
//
// * Accepts any number of touches in any locations.
// * Isn't blocked by any other GR.
// * Blocks all other GRs.
public class PermissiveGestureRecognizer: UIGestureRecognizer {
    @objc
    override public func canPrevent(_: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc
    override public func canBePrevented(by _: UIGestureRecognizer) -> Bool {
        return false
    }

    @objc
    override public func shouldRequireFailure(of _: UIGestureRecognizer) -> Bool {
        return false
    }

    @objc
    override public func shouldBeRequiredToFail(by _: UIGestureRecognizer) -> Bool {
        return true
    }

    @objc
    override public func touchesBegan(_: Set<UITouch>, with event: UIEvent) {
        handle(event: event)
    }

    @objc
    override public func touchesMoved(_: Set<UITouch>, with event: UIEvent) {
        handle(event: event)
    }

    @objc
    override public func touchesEnded(_: Set<UITouch>, with event: UIEvent) {
        handle(event: event)
    }

    @objc
    override public func touchesCancelled(_: Set<UITouch>, with event: UIEvent) {
        handle(event: event)
    }

    private func handle(event: UIEvent) {
        var hasValidTouch = false
        if let allTouches = event.allTouches {
            for touch in allTouches {
                switch touch.phase {
                case .began, .moved, .stationary:
                    hasValidTouch = true
                default:
                    break
                }
            }
        }

        if hasValidTouch {
            switch state {
            case .possible:
                state = .began
            case .began, .changed:
                state = .changed
            default:
                state = .failed
            }
        } else {
            switch state {
            case .began, .changed:
                state = .ended
            default:
                state = .failed
            }
        }
    }
}
