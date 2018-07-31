import UIKit

fileprivate let kChildViewPadding:CGFloat = 16.0
fileprivate let kDamping:CGFloat = 0.81
fileprivate let kInitialSpringVelocity:CGFloat = 0.3

class PrivateTransitionContext : NSObject, UIViewControllerContextTransitioning
{
    private var privateViewCtls:Dictionary<String, UIViewController>!
    private var privateAppearingFromRect:CGRect = CGRect.zero
    private var privateAppearingToRect:CGRect = CGRect.zero
    private var privateDisappearingFromRect:CGRect = CGRect.zero
    private var privateDisappearingToRect:CGRect = CGRect.zero
    
    var containerView: UIView
    
    var isAnimated: Bool = false
    
    var isInteractive: Bool = false
    
    var transitionWasCancelled: Bool = true
    
    var presentationStyle: UIModalPresentationStyle = .custom
    
    var targetTransform: CGAffineTransform = CGAffineTransform.identity
    
    var completeBlock: ((Bool)->Void)?
    
    init(fromViewController:UIViewController, toViewController:UIViewController, goingRight:Bool) {
        
        self.presentationStyle = .custom
        self.containerView = fromViewController.view.superview!
        self.containerView.accessibilityIdentifier = "my containerView"
        self.privateViewCtls = [UITransitionContextViewControllerKey.from.rawValue:fromViewController, UITransitionContextViewControllerKey.to.rawValue:toViewController]
        
        let travelDistance:CGFloat = (goingRight ? -self.containerView.bounds.size.width : self.containerView.bounds.size.width);
        self.privateDisappearingFromRect = self.containerView.bounds
        self.privateAppearingToRect = self.containerView.bounds
        self.privateDisappearingToRect = self.containerView.bounds.offsetBy(dx: travelDistance, dy: 0)
        self.privateAppearingFromRect = self.containerView.bounds.offsetBy(dx: -travelDistance, dy: 0)
    }
    
    func updateInteractiveTransition(_ percentComplete: CGFloat) {
        
    }
    
    func finishInteractiveTransition() {
        
    }
    
    func cancelInteractiveTransition() {
        
    }
    
    func pauseInteractiveTransition() {
        
    }
    
    func completeTransition(_ didComplete: Bool) {
        if (self.completeBlock != nil)
        {
            self.completeBlock!(didComplete)
        }
    }
    
    func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
        return self.privateViewCtls[key.rawValue]
    }
    
    func view(forKey key: UITransitionContextViewKey) -> UIView? {
        return self.privateViewCtls[key.rawValue]?.view
    }
    
    func initialFrame(for vc: UIViewController) -> CGRect {
        if (vc == self.viewController(forKey: UITransitionContextViewControllerKey.from))
        {
            return self.privateDisappearingFromRect;
        } else {
            return self.privateAppearingFromRect;
        }
    }
    
    func finalFrame(for vc: UIViewController) -> CGRect {
        if (vc == self.viewController(forKey: UITransitionContextViewControllerKey.to))
        {
            return self.privateDisappearingToRect;
        } else {
            return self.privateAppearingToRect;
        }
    }
}

class PrivateAnimatedTransition : NSObject, UIViewControllerAnimatedTransitioning {
    
    // return how many seconds the transition animation will take
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    // animate a change from one viewcontroller to another
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView
        let fromViewCtl:UIViewController! = transitionContext.viewController(forKey: .from)
        let toViewCtl:UIViewController! = transitionContext.viewController(forKey: .to)
        let goRight:Bool = transitionContext.initialFrame(for: toViewCtl).origin.x < transitionContext.finalFrame(for: toViewCtl).origin.x
        var travelDistance:CGFloat = transitionContext.containerView.bounds.size.width + kChildViewPadding
        if (goRight==false)
        {
            travelDistance = travelDistance * -1
        }
        let travel:CGAffineTransform = CGAffineTransform(translationX:travelDistance, y: 0)
        container.addSubview(toViewCtl.view)
        toViewCtl.view.transform = travel.inverted()
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: kDamping, initialSpringVelocity: kInitialSpringVelocity, options: .curveEaseOut, animations: {
            fromViewCtl.view.transform = travel
            toViewCtl.view.transform = CGAffineTransform.identity
        }) { (complete:Bool) in
            fromViewCtl.view.transform = CGAffineTransform.identity
            transitionContext .completeTransition(true)
        }
    }
}
