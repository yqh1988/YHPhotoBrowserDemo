//
//  YHPhotoBrowserAnimator.swift
//  YHPhotoBrowserDemo 照片浏览动画器
//
//  Created by yangqianhua on 2018/3/16.
//  Copyright © 2018年 yangqianhua. All rights reserved.
//

import UIKit
import Kingfisher

class YHPhotoBrowserAnimator: NSObject {
    
    /// 解除转场当前显示的图像视图
    var fromImageView: UIImageView?

    var isPresenting = false
    
    var photos : YHPhotoBrowserPhotos
    
    /// 实例化动画器
    ///
    /// - Parameter photos: 浏览照片模型
    /// - Returns: 照片浏览动画器
    class func animatorWithPhotos(photos:YHPhotoBrowserPhotos) -> YHPhotoBrowserAnimator{
        return YHPhotoBrowserAnimator.init(photos: photos)
    }
    
    init(photos:YHPhotoBrowserPhotos) {
        self.photos = photos
        super.init()
    }
}

// MARK: - UIViewControllerAnimatedTransitioning
extension YHPhotoBrowserAnimator : UIViewControllerAnimatedTransitioning{
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.isPresenting ? self.presentTransition(transitionContext: transitionContext) : self.dismissTransition(transitionContext: transitionContext)
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension YHPhotoBrowserAnimator : UIViewControllerTransitioningDelegate{
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        isPresenting = true
        return self
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning?{
        isPresenting = false
        return self
    }
}

// MARK: - 展现转场动画方法
extension YHPhotoBrowserAnimator{
    
    /// 开发转场动画方法
    ///
    /// - Parameter transitionContext: UIViewControllerContextTransitioning
    private func presentTransition(transitionContext:UIViewControllerContextTransitioning){
        let containerView = transitionContext.containerView
        let dummyIV = self.dummyImageView()
        let parentIV = self.parentImageView()!
        
        dummyIV.frame = containerView.convert(parentIV.frame, from: parentIV.superview)
        containerView.addSubview(dummyIV)
        
        let toView = transitionContext.view(forKey: .to)
        containerView.addSubview(toView!)
        toView?.alpha = 0.0
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            dummyIV.frame =  self.presentRec(imageView: dummyIV)
        }) { (finished) in
            UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
                toView?.alpha = 1.0
            }) { (finished) in
                dummyIV.removeFromSuperview()
                transitionContext.completeTransition(true)
            }
        }
    }

    /// 解除转场动画方法
    ///
    /// - Parameter transitionContext: UIViewControllerContextTransitioning
    private func dismissTransition(transitionContext:UIViewControllerContextTransitioning){
        let containerView = transitionContext.containerView
        let fromView = transitionContext.view(forKey: .from)
        let dummyIV = self.dummyImageView()
        if let fromV = self.fromImageView {
            dummyIV.frame = containerView.convert(fromV.frame, from: fromV.superview)
        }
        dummyIV.alpha = fromView?.alpha ?? 0
        containerView.addSubview(dummyIV)
        fromView?.removeFromSuperview()
        
        let parentIV = self.parentImageView()!
        let targetRect = containerView.convert(parentIV.frame, from: parentIV.superview)
        
        UIView.animate(withDuration: self.transitionDuration(using: transitionContext), animations: {
            dummyIV.frame =  targetRect
            dummyIV.alpha = 1.0
        }) { (finished) in
            dummyIV.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
    
    /// 根据图像计算展现目标尺寸
    ///
    /// - Parameter imageView: 图片空间
    /// - Returns: 位置、大小
    private func presentRec(imageView:UIImageView) -> CGRect{
        guard let image = imageView.image else {
            return imageView.frame
        }
        
        let screenSize = UIScreen.main.bounds.size
        var imageSize = screenSize
        imageSize.height = image.size.height * imageSize.width / image.size.width
        
        var rect = CGRect.init(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        
        if (imageSize.height < screenSize.height) {
            rect.origin.y = (screenSize.height - imageSize.height) * 0.5;
        }
        
        return rect
    }
}

extension YHPhotoBrowserAnimator{
    /// 生成 dummy(初始载入) 图像
    ///
    /// - Returns: UIImage
    private func dummyImage() -> UIImage?{
        guard let key = self.photos.urls?[self.photos.selectedIndex] else{
            return nil
        }
        var image = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: key)
        
        if(image == nil){
            image = self.photos.parentImageViews?[self.photos.selectedIndex].image
        }
        return image
    }
    
    ///生成 dummy(初始载入) 图像视图
    ///
    /// - Returns: 图片展示控件
    private func dummyImageView() -> UIImageView{
        let iv = UIImageView.init(image: self.dummyImage())
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        
        return iv
    }
    
    /// 父视图参考图像视图
    ///
    /// - Returns: 图片展示控件
    private func parentImageView() -> UIImageView?{
        return self.photos.parentImageViews?[self.photos.selectedIndex]
    }
}
