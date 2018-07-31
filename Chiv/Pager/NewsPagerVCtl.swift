//
//  NewsPagerVCtl.swift
//  Chiv
//
//  Created by nmi on 2018/7/25.
//  Copyright © 2018 user. All rights reserved.
//

import UIKit
import ZSegmentedControl

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
        container.addSubview(fromViewCtl.view)
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

class NewsPagerVCtl: UIViewController, ZSegmentedControlSelectedProtocol {
    
    //Segment placeholder
    @IBOutlet var placeHolder:UIView!
    var segmentedControl5:ZSegmentedControl!
    
    //Container view
    @IBOutlet var pageContainerView:UIView!
    @IBOutlet var categoryTitle:UILabel!
    
    //Pager
    var curVctl:UIViewController!
    var animtransition:PrivateAnimatedTransition!
    var pages:Array<MapViewController> = []

    //Category
    var category:String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.tintColor = UIColor.white
        navigationBarAppearace.barTintColor = UIColor.white
        navigationBarAppearace.shadowImage = UIImage.init()
        
        let menuBtn = UIButton(type: .custom)
        menuBtn.frame = CGRect(x: 0.0, y: 0.0, width: 23, height: 23)
        menuBtn.setImage(UIImage(named:"Back"), for: .normal)
        menuBtn.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        let menuBarItem = UIBarButtonItem(customView: menuBtn)
        self.navigationItem.leftBarButtonItem = menuBarItem
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        categoryTitle.text = category
        NewsPagerModel.requestList { (result:Array<NewsPage>?) in
            print(result)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    @objc func dismiss(obj:AnyObject) {
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (segmentedControl5==nil) {
            
            let titless =  MockData.titles(key: category)
            segmentedControl5 = ZSegmentedControl(frame: placeHolder.frame)
            segmentedControl5.backgroundColor = UIColor.white
            segmentedControl5.bounces = true
            segmentedControl5.textColor = UIColor.lightGray
            segmentedControl5.textSelectedColor = UIColor.black
            segmentedControl5.setTitles(titless, style: .adaptiveSpace(13))
            segmentedControl5.setSilder(backgroundColor: .lightGray, position: .bottomWithHight(3), widthStyle: .adaptiveSpace(0))
            segmentedControl5.delegate = self
            view.addSubview(segmentedControl5)
            
            let color:Array<UIColor> = [UIColor.white, UIColor.white]
            for index in 1...titless.count {
                let vc:MapViewController = MapViewController(nibName: "MapViewController", bundle: nil)
                vc.view.tag = index
                vc.bgColor = color[index%color.count]
                self.pages.append(vc)
            }
            
            let mapViewController:MapViewController = self.pages[0]
            let mapView:UIView = mapViewController.view
            addChildViewController(mapViewController)
            pageContainerView.addSubview(mapView)
            mapViewController.didMove(toParentViewController: self)
            curVctl = mapViewController
            mapView.frame = pageContainerView.bounds
        }
        
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        leftSwipe.direction = .left
        rightSwipe.direction = .right
        view.addGestureRecognizer(leftSwipe)
        view.addGestureRecognizer(rightSwipe)
    }
    
    @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
        
        if (sender.direction == .left) {
            let sel:Int = segmentedControl5.selectedIndex + 1
            segmentedControl5.selectedIndex = (sel >= 10) ? 9:sel
            self.transitionVctl(pages[segmentedControl5.selectedIndex])
        }
        
        if (sender.direction == .right) {
            let sel:Int = segmentedControl5.selectedIndex - 1
            segmentedControl5.selectedIndex = (sel < 0) ? 0:sel
            self.transitionVctl(pages[segmentedControl5.selectedIndex])
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func transitionVctl(_ vctl:UIViewController)
    {
        if (curVctl != vctl)
        {
            self.transitionToVctl(vctl)
        }
    }
    
    func transitionToVctl(_ toVctl:UIViewController)
    {
        let toView:UIView = toVctl.view
        toView.translatesAutoresizingMaskIntoConstraints = false
        toView.frame = pageContainerView.bounds
        self.addChildViewController(toVctl)
        let toindex:Int = toVctl.view.tag
        let frindex:Int = curVctl.view.tag
        let transitionContext:PrivateTransitionContext = PrivateTransitionContext.init(fromViewController:curVctl, toViewController:toVctl, goingRight:toindex>frindex)
        transitionContext.isAnimated = true
        transitionContext.isInteractive = false
        transitionContext.completeBlock = { (complete:Bool)-> Void in
            /*
             Called just before the view controller is added or removed from a container view controller.
             If you are implementing your own container view controller,
             it must call the willMove(toParentViewController:) method of the child view controller before calling the removeFromParentViewController() method,
             passing in a parent value of nil.
            */
            self.curVctl.willMove(toParentViewController: nil)
            self.curVctl.view.removeFromSuperview()
            self.curVctl.removeFromParentViewController()
            
            toVctl.didMove(toParentViewController: self)
            self.curVctl = toVctl
        }
        
        let animator:PrivateAnimatedTransition = PrivateAnimatedTransition.init()
        animator.animateTransition(using: transitionContext)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?
    {
        return PrivateAnimatedTransition()
    }
    
    func segmentedControlSelectedIndex(_ index: Int, animated: Bool, byclick: Bool, segmentedControl: ZSegmentedControl)
    {
        if (byclick) {
            self.transitionVctl(pages[index])
        }
    }
}
