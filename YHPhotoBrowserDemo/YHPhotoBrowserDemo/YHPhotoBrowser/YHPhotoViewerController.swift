//
//  YHPhotoViewerController.swift
//  YHPhotoBrowserDemo 单张照片查看控制器 - 显示单张照片使用
//
//  Created by yangqianhua on 2018/3/16.
//  Copyright © 2018年 yangqianhua. All rights reserved.
//

import UIKit
import Kingfisher

class YHPhotoViewerController: UIViewController {
    
    private var url:URL?
    
    public var photoIndex:Int = 0
    
    private var placeholder:UIImage?
    
    /// 可缩放的UIScrollView
    public lazy var scrollView : UIScrollView = {
        let scView = UIScrollView.init(frame: self.view.bounds)
        scView.maximumZoomScale = 2.0
        scView.minimumZoomScale = 1.0
        scView.delegate = self
        return scView
    }()
    
    public lazy var imageView : UIImageView = {
        let imgV = UIImageView.init(image: self.placeholder)
        imgV.center = self.view.center
        
        return imgV
    }()
    
    private lazy var progressView : YHPhotoProgressView = {
        let iproV = YHPhotoProgressView.init(frame: CGRect.init(x: 0, y: 0, width: 80, height: 80))
        iproV.center = self.view.center
        iproV.progress = 1.0
        return iproV
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUi()
        self.loadImage()
    }
    
    /// 实例化单图查看器
    ///
    /// @param urlString   urlString 字符串
    /// @param photoIndex  照片索引
    /// @param placeholder 占位图像
    ///
    /// @return 单图查看器
    init(urlString:String,photoIndex:Int,placeholder:UIImage){
        super.init(nibName: nil, bundle: nil)
        self.url = URL.init(string: urlString)
        self.photoIndex = photoIndex
        self.placeholder = placeholder
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - 设置UI
extension YHPhotoViewerController{
    private func setUpUi(){
        self.view.addSubview(self.scrollView)
        self.scrollView.addSubview(self.imageView)
        self.view.addSubview(self.progressView)
    }
    
    private func loadImage(){
        guard let url1 = self.url else {
            return
        }
        let resource = ImageResource.init(downloadURL: url1)
        self.imageView.kf.setImage(with: resource, placeholder: self.placeholder, options: nil ,progressBlock: { (receivedSize, totalSize) in
            DispatchQueue.main.async {
                self.progressView.progress = CGFloat(receivedSize) / CGFloat(totalSize)
            }
            
        }) { (image, error, cacheType, url) in
            if(image != nil){
                self.setImagePosition(image: image!)
            }
        }
    }
    
    private func setImagePosition(image:UIImage){
        let size = self.imageSizeWithScreen(image: image)
        imageView.frame = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        scrollView.contentSize = size
        if (size.height < scrollView.bounds.size.height) {
            let offsetY = (scrollView.bounds.size.height - size.height) * 0.5
            scrollView.contentInset = UIEdgeInsetsMake(offsetY, 0, offsetY, 0)
        }
    }
    
    private func imageSizeWithScreen(image:UIImage) -> CGSize {
        var size = UIScreen.main.bounds.size
        size.height = image.size.height * size.width / image.size.width;
        return size
    }
}

// MARK: -UIScrollViewDelegate
extension YHPhotoViewerController : UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
