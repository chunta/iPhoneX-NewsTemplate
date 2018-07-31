//
//  MapViewController.swift
//  ParentChildren
//
//  Created by nmi on 2018/7/17.
//  Copyright © 2018 nmi. All rights reserved.
//

import UIKit

class MapViewController: UIViewController {

    var boardView:UIView!
    var collectionView:UICollectionView!
    var flowLayout:UICollectionViewFlowLayout!
    
    static fileprivate let margin:CGFloat = CGFloat(5.0)
    fileprivate let sectionInsets = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    var bgColor:UIColor = UIColor.white
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Layout
        flowLayout = UICollectionViewFlowLayout()
        flowLayout.sectionInset = sectionInsets
        flowLayout.minimumLineSpacing = MapViewController.margin
        
        //Delegate & DataSource
        collectionView = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = bgColor
        self.view.addSubview(collectionView)
        
        //Cell
        collectionView.register(UINib(nibName: "NewsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "NewsCollectionViewCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension MapViewController: UICollectionViewDelegate
{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     //   delegate?.newListItemSelect(index: indexPath.row)
    }
}

extension MapViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.size.width-sectionInsets.left-sectionInsets.right-1, height: 300)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return MapViewController.margin
    }
}

extension MapViewController: UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10//viewmodel.count()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let gridCell = collectionView.dequeueReusableCell(withReuseIdentifier: "NewsCollectionViewCell", for: indexPath) as! NewsCollectionViewCell
        gridCell.layer.borderWidth = 1
        return gridCell
    }
    
}

