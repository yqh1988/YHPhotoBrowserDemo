//
//  ViewController.swift
//  YHPhotoBrowserDemo
//
//  Created by yangqianhua on 2018/3/15.
//  Copyright © 2018年 yangqianhua. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    //缩略图
    let imageArray = ["http://f.hiphotos.baidu.com/image/h%3D300/sign=12e703ffa5ec8a130b1a51e0c7029157/c75c10385343fbf2f7da8133bc7eca8065388f2f.jpg","http://b.hiphotos.baidu.com/image/h%3D300/sign=e79fdbb1067b020813c939e152d8f25f/14ce36d3d539b600b36afca3e550352ac65cb77a.jpg","http://f.hiphotos.baidu.com/image/h%3D300/sign=e031a2d7ab86c91717035439f93c70c6/a50f4bfbfbedab6476b40beffb36afc378311ede.jpg","http://g.hiphotos.baidu.com/image/h%3D300/sign=f05b869492510fb367197197e932c893/b999a9014c086e060b03f7660e087bf40ad1cb70.jpg","http://c.hiphotos.baidu.com/image/h%3D300/sign=5d662b6f291f95cab9f594b6f9177fc5/72f082025aafa40f8197e0cca764034f78f01949.jpg","http://h.hiphotos.baidu.com/image/h%3D300/sign=c212fdd277899e51678e3c1472a6d990/e824b899a9014c0899ee068a067b02087af4f4cc.jpg"]
    
    //大图
    let bigImageArray = ["http://f.hiphotos.baidu.com/image/pic/item/c75c10385343fbf2f7da8133bc7eca8065388f2f.jpg","http://b.hiphotos.baidu.com/image/pic/item/14ce36d3d539b600b36afca3e550352ac65cb77a.jpg","http://f.hiphotos.baidu.com/image/pic/item/a50f4bfbfbedab6476b40beffb36afc378311ede.jpg","http://g.hiphotos.baidu.com/image/pic/item/b999a9014c086e060b03f7660e087bf40ad1cb70.jpg","http://c.hiphotos.baidu.com/image/pic/item/72f082025aafa40f8197e0cca764034f78f01949.jpg","http://img.zcool.cn/community/018e785944bc7fa8012193a3e5cc6c.jpg@1280w_1l_2o_100sh.jpg"]
   

    var imageViews = [UIImageView]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        //设置图片
        for i in  0..<imageArray.count{
            guard let data = try? Data.init(contentsOf: URL.init(string: imageArray[i])!),let image = UIImage.init(data: data) else{
                continue
            }
            
            let imageView = ( self.view.viewWithTag(100 + i + 1) as! UIImageView)
            imageView.image = image
            imageView.isUserInteractionEnabled = true
            let tapGes = UITapGestureRecognizer.init(target: self, action: #selector(tap(ges:)))
            imageView.addGestureRecognizer(tapGes)
            imageViews.append(imageView)
        }
        
    }
    
    @objc private func tap(ges:UIGestureRecognizer){
        let imageView = ges.view!
        //print(imageView.tag)
        
       let vc = YHPhotoBrowserController.photoBrowser(selectedIndex: imageView.tag - 100 - 1, urls: bigImageArray, parentImageViews: imageViews)
        
        self.present(vc, animated: true, completion: nil)
    }
}

