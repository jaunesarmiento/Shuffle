//
//  Shuffle.swift
//  Shuffle
//
//  Created by Jaune Sarmiento on 5/25/15.
//  Copyright (c) 2015 Jaune Sarmiento. All rights reserved.
//

import Foundation


// MARK: - CardViewSwipeDirection

@objc public enum CardViewSwipeDirection: NSInteger {
    case Up = 0
    case Right = 1
    case Down = 2
    case Left = 3
}


// MARK: - CardManagerDelegate

@objc public protocol CardManagerDelegate {
    optional func cardManagerDidTapCardView(cardView: CardView)
    optional func cardManagerDidPushCardView(cardView: CardView)
    optional func cardManagerDidPopCardView(cardView: CardView, withDirection: CardViewSwipeDirection)
    optional func cardManagerShouldCommitSwipe(completed: (commit: Bool) -> Void)
    optional func cardView(cardView: CardView, didChangePositionToPoint poing: CGPoint)
    func generateCardView() -> CardView
}


// MARK: - CardManager

public class CardManager {
    
    // The distance needed before the card manager detects a swipe.
    public var actionMargin = UIScreen.mainScreen().bounds.width / 3
    
    // The maximum number of cards loaded in the card stack.
    public var maximumNumberOfCardLoadedSimultaneously = 3

    // The root view controller where this card manager is attached to.
    public var rootViewController: UIViewController?
    
    // The card manager delegate handling push, pop, and swipe-related delegate callbacks.
    public var delegate: CardManagerDelegate?
    
    private var cardStack = NSMutableArray()
    
    // Singleton instance
    public class func sharedManager() -> CardManager {
        struct Singleton {
            static let instance = CardManager()
        }
        
        return Singleton.instance
    }
    
    // CardManager constructor
    required public init() {
        
    }
    
    public func reloadData() {
        
        var i = cardStack.count
        
        while i < maximumNumberOfCardLoadedSimultaneously {
            
            let cardView = delegate?.generateCardView() as CardView!
            cardView.delegate = self
            
            UIView.animateWithDuration(0.2,
                animations: { () -> Void in
                    self.push(cardView)
                }
            )
            
            i++
            
        }
    }
    
    func push(cardView: CardView) {
        
        cardView.alpha = 1
        
        if cardStack.count == 0 {
            rootViewController?.view.addSubview(cardView)
        } else {
            rootViewController?.view.insertSubview(cardView, belowSubview: self.cardStack[self.cardStack.count - 1] as! UIView)
        }
        
        cardStack.addObject(cardView)
        
        // Tell the delegate that we just pushed a cardView
        delegate?.cardManagerDidPushCardView?(cardView)
        
    }
    
    func pop() {
        if cardStack.count > 0 {
            // No need to remove it from the superview since the CardView handles that, just remove it from the stack.
            cardStack.removeObjectAtIndex(0)
        }
    }

}


extension CardManager: CardViewDelegate {
    @objc public func cardViewShouldCommitSwipe(cardView: CardView, withDirection direction: CardViewSwipeDirection, completed: (completed: Bool) -> Void) {
        delegate?.cardManagerShouldCommitSwipe?({ (commit) -> Void in
            completed(completed: commit)
        })
    }
    
    @objc public func didSwipeCardView(cardView: CardView, withDirection direction: CardViewSwipeDirection) {
        delegate?.cardManagerDidPopCardView?(cardView, withDirection: direction)
        pop()
    }
    
    @objc public func didTapCardView(cardView: CardView) {
        delegate?.cardManagerDidTapCardView?(cardView)
    }
    
    @objc public func cardView(cardView: CardView, didChangePositionToPoint point: CGPoint) {
        delegate?.cardView?(cardView, didChangePositionToPoint: point)
    }

}



// MARK: - CardViewDelegate

@objc public protocol CardViewDelegate {
    optional func cardView(cardView: CardView, didChangePositionToPoint point: CGPoint)
    optional func didTapCardView(cardView: CardView)
    optional func didSwipeCardView(cardView: CardView, withDirection direction: CardViewSwipeDirection)
    optional func didResetCardViewPosition()
    func cardViewShouldCommitSwipe(cardView: CardView, withDirection direction: CardViewSwipeDirection, completed: (completed: Bool) -> Void)
}


// MARK: - CardView

public class CardView: UIView {
    
    public var scaleStrength = 4.0
    
    public var scaleMax = 0.98
    
    public var rotationStrength = 240
    
    public var rotationMax = 1
    
    public var rotationAngle = M_PI / 16
    
    private var panGestureRecognizer: UIPanGestureRecognizer!
    private var tapGestureRecognizer: UITapGestureRecognizer!
    
    private var originalPoint: CGPoint!
    
    private var deltaX: CGFloat!
    private var deltaY: CGFloat!
    
    public var delegate: CardViewDelegate?
    
    @IBOutlet public weak var view: UIView!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        
        // Initialize the gesture recognizer so we can swipe the view
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: "beingDragged:")
        addGestureRecognizer(panGestureRecognizer)
        
        // Initialize the tap gesture recognizer
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tapped:")
        addGestureRecognizer(tapGestureRecognizer)
        
        originalPoint = center
        
        backgroundColor = UIColor.clearColor()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    private func didStartDraggingCardView() {
        self.originalPoint = center
    }
    
    private func didChangePositionToPoint(point: CGPoint) {
        
        deltaX = point.x
        deltaY = point.y
        
        // Compute the rotation and scale of the cardView at its current position
        let rotationFromDistance = min(deltaX / CGFloat(rotationStrength), CGFloat(rotationMax))
        let rotationAngleFromDistance = CGFloat(rotationAngle) * CGFloat(rotationFromDistance)
        let scale = max(1 - fabs(rotationFromDistance) / CGFloat(scaleStrength), CGFloat(scaleMax))
        
        let xCurrent = originalPoint!.x + deltaX
        let yCurrent = originalPoint!.y + deltaY
        
        center = CGPointMake(xCurrent, yCurrent)
        
        let transform: CGAffineTransform = CGAffineTransformMakeRotation(CGFloat(rotationAngleFromDistance))
        let scaleTransform: CGAffineTransform = CGAffineTransformScale(transform, scale, scale)
        
        // Transform the cardView
        self.view.transform = scaleTransform
        
        // Notify the delegate that the cardView has changed position
        delegate?.cardView?(self, didChangePositionToPoint: point)
        
    }
    
    private func didEndDraggingCardViewToPoint(point: CGPoint) {
        
        let distance = sqrt(pow(point.x, 2) + pow(point.y, 2))
        
        if distance > CardManager.sharedManager().actionMargin {
            let direction = swipeDirectionForAngle(angleForPoint(point))
            delegate?.cardViewShouldCommitSwipe(self, withDirection: direction, completed: { (completed) -> Void in
                if completed {
                    self.didSwipeCardViewWithDirection(direction)
                } else {
                    self.reset()
                }
            })
        } else {
            self.reset()
        }
    }
    
    private func didSwipeCardViewWithDirection(direction: CardViewSwipeDirection) {
        var finishPoint: CGPoint!
        
        switch direction {
        case .Right:
            finishPoint = CGPointMake(UIScreen.mainScreen().bounds.width + self.frame.width, originalPoint!.y + 56)
            
        case .Left:
            finishPoint = CGPointMake(-(UIScreen.mainScreen().bounds.width + self.frame.width), originalPoint!.y + 56)
            
        case .Down:
            finishPoint = CGPointMake(originalPoint!.x, UIScreen.mainScreen().bounds.height + self.frame.height)
            
        default:
            finishPoint = originalPoint!
        }
        
        UIView.animateWithDuration(0.2,
            animations: { () -> Void in
                self.center = finishPoint
            },
            completion: { (complete) -> Void in
                self.delegate?.didSwipeCardView?(self, withDirection: direction)
                self.removeFromSuperview()
            }
        )
        
    }
    
    private func forceSwipeToPoint(point: CGPoint) {
        originalPoint = center
        
        deltaX = point.x
        deltaY = point.y
        
        let rotation: CGFloat = originalPoint!.x > deltaX ? -0.4 : 0.4
        
        UIView.animateWithDuration(0.2,
            animations: { () -> Void in
                self.center = point
                self.view.transform = CGAffineTransformMakeRotation(rotation)
            }, completion: { (complete) -> Void in
                self.didEndDraggingCardViewToPoint(point)
            }
        )
    }
    
    private func angleForPoint(point: CGPoint) -> Float {
        // Determine the angle of point
        let radians = Float(atan2(point.y, point.x))
        let degrees = Float(radians * 180.0 / Float(M_PI))
        
        if degrees < 0 {
            return fabsf(degrees)
        } else {
            return 360.0 - degrees
        }
    }
    
    private func swipeDirectionForAngle(angle: Float) -> CardViewSwipeDirection {
        if angle >= 60 && angle < 120 {
            return .Up
        } else if angle >= 120 && angle < 240 {
            return .Left
        } else if angle >= 240 && angle < 300 {
            return .Down
        } else {
            return .Right
        }
    }
    
    private func beingDragged(gestureRecognizer: UIPanGestureRecognizer) {
        
        switch (gestureRecognizer.state) {
        case UIGestureRecognizerState.Began:
            didStartDraggingCardView()
            
        case .Changed:
            didChangePositionToPoint(gestureRecognizer.translationInView(self))
            
        case .Ended:
            didEndDraggingCardViewToPoint(gestureRecognizer.translationInView(self))
            
        default:
            break
        }
    }
    
    public func swipeRight() {
        let point = CGPointMake(UIScreen.mainScreen().bounds.width + self.frame.width, self.center.y)
        forceSwipeToPoint(point)
    }
    
    public func swipeLeft() {
        let point = CGPointMake(-(UIScreen.mainScreen().bounds.width + self.frame.width), self.center.y)
        forceSwipeToPoint(point)
    }
    
    public func swipeDown() {
        let point = CGPointMake(self.center.x, UIScreen.mainScreen().bounds.height + self.frame.height)
        forceSwipeToPoint(point)
    }
    
    public func tapped(gestureRecognizer: UITapGestureRecognizer) {
        delegate?.didTapCardView?(self)
    }
    
    public func reset() {
        
        // Reset the card to original position
        UIView.animateWithDuration(0.3,
            animations: { () -> Void in
                self.center = self.originalPoint!
                
                let rotation: CGAffineTransform = CGAffineTransformMakeRotation(0)
                self.view.transform = rotation
            },
            completion: { (completed) -> Void in
                
            }
        )
        
    }
 
}



