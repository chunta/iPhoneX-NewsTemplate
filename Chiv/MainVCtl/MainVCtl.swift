//
//  MainVCtl.swift
//  Chiv
//
//  Created by user on 2018/7/7.
//  Copyright © 2018年 user. All rights reserved.
//

import UIKit

fileprivate let kChildViewPadding:CGFloat = 16.0
fileprivate let kDamping:CGFloat = 0.81
fileprivate let kInitialSpringVelocity:CGFloat = 0.3

class MainTransitionContext : NSObject, UIViewControllerContextTransitioning
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

class MainAnimatedTransition : NSObject, UIViewControllerAnimatedTransitioning {
    
    // return how many seconds the transition animation will take
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    // animate a change from one viewcontroller to another
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let container = transitionContext.containerView
        let fromViewCtl:UIViewController! = transitionContext.viewController(forKey: .from)
        let toViewCtl:UIViewController! = transitionContext.viewController(forKey: .to)
        
        container.addSubview(fromViewCtl.view)
        container.addSubview(toViewCtl.view)
        
        let mainctl:MainVCtl = fromViewCtl as! MainVCtl
        let selcell:UIView = mainctl.colView.cellForItem(at: mainctl.selectedIndexPath!)!
        print(selcell.frame)
        let scalew:CGFloat = UIScreen.main.bounds.size.width/selcell.frame.size.width
        let scaleh:CGFloat = UIScreen.main.bounds.size.height/selcell.frame.size.height
        let leftUpper:CGPoint = selcell.convert(CGPoint.init(x: 0, y: 0), to: nil)
        
        let snapShot:UIView = selcell.snapshotView(afterScreenUpdates: false)!
        container.addSubview(snapShot)
        snapShot.frame.origin = leftUpper
        
        UIView .animate(withDuration: 2.5, animations: {
            snapShot.transform = CGAffineTransform(scaleX: scalew, y: scaleh)
              snapShot.frame.origin = CGPoint.init(x: 0, y: 10)
            fromViewCtl.view.alpha = 0
            
        }) { (complete:Bool) in
            if (complete){
                snapShot.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }
}

fileprivate let edgeLRspace:CGFloat = 40
fileprivate let margin:CGFloat = CGFloat(5.0)
fileprivate let sectionInsets = UIEdgeInsets(top: margin*3, left: margin, bottom: margin, right: margin)

class MainVCtl: UIViewController {
    
    var selectedIndexPath:IndexPath?
    var thelist:Array<MainModel> = []
    var thelistratio:Dictionary<String,CGFloat> = Dictionary<String,CGFloat>()
    @IBOutlet var topInfoView:UIView!
    @IBOutlet var topInfoViewTopCs:NSLayoutConstraint!
    @IBOutlet var colView:UICollectionView!
    @IBOutlet var challengeView:UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
            
        //Layout
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = sectionInsets
        layout.minimumLineSpacing = margin
        
        //Delegate & DataSource
        colView.delegate = self
        colView.dataSource = self
        
        //Cell
        colView.register(UINib(nibName: "NewsListCell", bundle: nil), forCellWithReuseIdentifier: "NewsListCell")

        //Request
        MainModelView.requestList { (result:Array<MainModel>?) in
            guard let theresult = result else {
                return
            }
            self.thelist = theresult
            self.colView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
    }
}

extension MainVCtl: UINavigationControllerDelegate
{
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if(operation == UINavigationControllerOperation.push)
        {
            print(operation)
            return MainAnimatedTransition()
        }
        return nil;
    }
}

extension MainVCtl: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        let pager:NewsPagerVCtl = NewsPagerVCtl()
        pager.category = self.thelist[indexPath.row].title
        self.navigationController?.pushViewController(pager, animated: true)
    }
}

extension MainVCtl: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w:CGFloat = UIScreen.main.bounds.size.width - edgeLRspace
        var h:CGFloat = 300
        if (thelistratio[String.init(format: "%d", indexPath.row)] != nil)
        {
            let ratio:CGFloat = thelistratio[String.init(format: "%d", indexPath.row)]!
            h = w / ratio
        }
        return CGSize(width: w, height: h)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return margin*5
    }
}

extension MainVCtl: MainModelViewDelegate
{
    func requestImgComplete(indexPath: NSIndexPath) {
        if (MainModelView.getImg(url: thelist[indexPath.row].imgurl) != nil) {
            let img:UIImage = MainModelView.getImg(url: thelist[indexPath.row].imgurl)!
            thelistratio[String.init(format: "%d", indexPath.row)] = img.size.width/img.size.height
        }
        self.colView.reloadItems(at: [indexPath as IndexPath])
    }
}

extension MainVCtl: UICollectionViewDataSource
{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thelist.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsListCell", for: indexPath) as! NewsListCell
        gridCell.layer.borderWidth = 1
        gridCell.title.text = thelist[indexPath.row].title
        if (MainModelView.getImg(url: thelist[indexPath.row].imgurl) != nil) {
            gridCell.imgview.image = MainModelView.getImg(url: thelist[indexPath.row].imgurl)
        }
        else {
            MainModelView.requestImg(url: thelist[indexPath.row].imgurl, indexPath: indexPath as NSIndexPath, del: self)
        }
        return gridCell
    }
}
