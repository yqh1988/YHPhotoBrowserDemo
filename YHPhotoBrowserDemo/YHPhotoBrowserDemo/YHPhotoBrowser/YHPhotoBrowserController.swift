//
//  YHPhotoBrowserController.swift
//  YHPhotoBrowserDemo 照片浏览控制器
//
//  Created by yangqianhua on 2018/3/16.
//  Copyright © 2018年 yangqianhua. All rights reserved.
//

import UIKit

class YHPhotoBrowserController: UIViewController {

    private lazy var photos : YHPhotoBrowserPhotos = YHPhotoBrowserPhotos()
    private var statusBarHidden : Bool = false
    private lazy var animator : YHPhotoBrowserAnimator = YHPhotoBrowserAnimator.init(photos: self.photos)
    private lazy var currentViewer : YHPhotoViewerController = {
        let viewer = self.viewerWithIndex(index: self.photos.selectedIndex)
        return viewer
    }()
    
    private lazy var pageCountButton : UIButton = {
        let btn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 40))
        var center = self.view.center
        center.y = btn.bounds.size.height
        btn.layer.cornerRadius = 6
        btn.layer.masksToBounds = true
        btn.backgroundColor = UIColor.init(white: 0.6, alpha: 0.6)
        
        btn.center = center
        
        return btn
    }()
    
     // 提示标签
    private lazy var messageLabel : UILabel = {
        let lbl = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: 120, height: 60))
        lbl.backgroundColor = UIColor.init(white: 0, alpha: 0.6)
        lbl.textColor = UIColor.white
        
        lbl.textAlignment = .center
        lbl.layer.cornerRadius = 6
        lbl.layer.masksToBounds = true
        
        lbl.transform = CGAffineTransform(scaleX: 0, y: 0);
        lbl.center = self.view.center
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUi()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        statusBarHidden = true
        
        UIView.animate(withDuration: 0.25) {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        statusBarHidden = false
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    private func prefersStatusBarHidden() -> Bool{
        return statusBarHidden
    }
    
    private func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation{
        return .slide
    }
    
    public class func photoBrowser(selectedIndex:Int,urls:[String],parentImageViews:[UIImageView]) -> YHPhotoBrowserController{
        return YHPhotoBrowserController.init(selectedIndex: selectedIndex, urls: urls, parentImageViews: parentImageViews)
    }
    
    private init(selectedIndex:Int,urls:[String],parentImageViews:[UIImageView]) {
        super.init(nibName: nil, bundle: nil)
        self.photos.selectedIndex = selectedIndex
        self.photos.urls = urls
        self.photos.parentImageViews = parentImageViews
        self.modalPresentationStyle = .custom
        
        self.transitioningDelegate = self.animator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 设置UI
extension YHPhotoBrowserController{
    private func setUpUi(){
        self.view.backgroundColor = UIColor.black
        
        let pageController = UIPageViewController.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey:20])
        
        pageController.dataSource = self
        pageController.delegate = self
        
        pageController.setViewControllers([currentViewer], direction: .forward, animated: true, completion: nil)
        
        self.view.addSubview(pageController.view)
        self.addChildViewController(pageController)
        pageController.didMove(toParentViewController: self)
        
        // 手势识别
        self.view.gestureRecognizers = pageController.gestureRecognizers
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapGesture))
        self.view.addGestureRecognizer(tap)
        
        let pinch = UIPinchGestureRecognizer.init(target: self, action: #selector(interactiveGesture(recognizer:)))
        self.view.addGestureRecognizer(pinch)
        
        let rotate = UIRotationGestureRecognizer.init(target: self, action: #selector(interactiveGesture(recognizer:)))
        self.view.addGestureRecognizer(rotate)
        
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressGesture(recognizer:)))
        self.view.addGestureRecognizer(longPress)
        
        pinch.delegate = self
        rotate.delegate = self
        
        self.setPageButtonIndex(index: photos.selectedIndex)
        
        self.view.addSubview(self.pageCountButton)
        self.view.addSubview(self.messageLabel)
        
    }
    
    private func viewerWithIndex(index:Int) -> YHPhotoViewerController{
        return YHPhotoViewerController.init(urlString: photos.urls![index], photoIndex: index, placeholder: photos.parentImageViews![index].image!)
    }
}

// MARK: - 手势事件
extension YHPhotoBrowserController{
    @objc private func tapGesture(){
        animator.fromImageView = currentViewer.imageView
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func interactiveGesture(recognizer:UIGestureRecognizer){
        statusBarHidden = (currentViewer.scrollView.zoomScale > 1.0);
        
        self.setNeedsStatusBarAppearanceUpdate()
        
        if(statusBarHidden){
            self.view.backgroundColor = UIColor.black
            self.view.transform = .identity
            
            self.view.alpha = 1.0
            pageCountButton.isHidden = ((photos.urls?.count ?? 0) == 1)
            
            return
        }
        
        var transfrom = self.view.transform
        
        if(recognizer.isKind(of: UIPinchGestureRecognizer.self)){
            let pinch = recognizer as! UIPinchGestureRecognizer
            let scale = pinch.scale
            transfrom = transfrom.scaledBy(x: scale, y: scale)
            pinch.scale = 1.0
        }else if(recognizer.isKind(of: UIRotationGestureRecognizer.self)){
            let rotate = recognizer as! UIRotationGestureRecognizer
            let rotation = rotate.rotation
            transfrom = transfrom.rotated(by: rotation)
            rotate.rotation = 0;
        }
        
        switch (recognizer.state) {
            
            case .began,.changed:
                pageCountButton.isHidden = true
                self.view.backgroundColor = UIColor.clear
                self.view.transform = transfrom;
                self.view.alpha = transfrom.a;
            case .cancelled,.failed,.ended:
                self.tapGesture()
            default:
              print("haha")
        }
    }
    
    @objc private func longPressGesture(recognizer:UILongPressGestureRecognizer){
        if (recognizer.state != .began) {
            return
        }
        if (currentViewer.imageView.image == nil) {
            return
        }
        
        let alertVc = UIAlertController.init(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertVc.addAction(UIAlertAction.init(title: "保存至相册", style: .destructive, handler: { (action) in
            UIImageWriteToSavedPhotosAlbum(self.currentViewer.imageView.image!, self, #selector(self.image(_:didFinishSavingWith:contextInfo:)), nil)
        }))
        
        alertVc.addAction(UIAlertAction.init(title: "取消", style: .cancel, handler: nil ))
        
        self.present(alertVc, animated: true, completion: nil)
    }
    
    @objc private func image(_ image:UIImage?,didFinishSavingWith error:Error?,contextInfo:Any?){
        let message = (error == nil) ? "保存成功" : "保存失败";
        messageLabel.text = message
        
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: [], animations: {
            self.messageLabel.transform = .identity
        }) { (finished) in
            UIView.animate(withDuration: 0.5, animations: {
                self.messageLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
            })
        }
    }
}

// MARK: - UIPageViewControllerDataSource
extension YHPhotoBrowserController:UIPageViewControllerDataSource{
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        var  index = (viewController as! YHPhotoViewerController).photoIndex
        
        if (index <= 0) {
            return nil;
        }
        index = index - 1
        return self.viewerWithIndex(index: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = (viewController as! YHPhotoViewerController).photoIndex + 1
        
        if (index >= (photos.urls?.count ?? 0)) {
            return nil;
        }
        
        return self.viewerWithIndex(index: index)
    }
}

// MARK: - UIPageViewControllerDelegate
extension YHPhotoBrowserController:UIPageViewControllerDelegate{
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool){
        let viewer: YHPhotoViewerController = pageViewController.viewControllers![0] as! YHPhotoViewerController
        
        photos.selectedIndex = viewer.photoIndex;
        currentViewer = viewer;
        
        self.setPageButtonIndex(index: viewer.photoIndex)
    }
    
    private func setPageButtonIndex(index:Int){
        pageCountButton.isHidden = ((photos.urls?.count ?? 0) == 1)
        
        let attributeText = NSMutableAttributedString.init(string: "\(index + 1)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18),NSAttributedStringKey.foregroundColor:UIColor.white])
        
        attributeText.append(NSAttributedString.init(string: " / \(photos.urls?.count ?? 0)", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14),NSAttributedStringKey.foregroundColor:UIColor.white]))
        
        self.pageCountButton.setAttributedTitle(attributeText, for: .normal)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension YHPhotoBrowserController:UIGestureRecognizerDelegate{
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool
    {
        return true
    }
}
