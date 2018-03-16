//
//  YHPhotoBrowserPhotos.swift
//  YHPhotoBrowserDemo  浏览照片模型
//
//  Created by yangqianhua on 2018/3/16.
//  Copyright © 2018年 yangqianhua. All rights reserved.
//

import UIKit

class YHPhotoBrowserPhotos: NSObject {

    /// 选中照片索引
    var selectedIndex:Int = 0
    
    /// 照片 url 字符串数组
    var urls:[String]?
    
    /// 父视图图像视图数组，便于交互转
    var parentImageViews:[UIImageView]?
}
