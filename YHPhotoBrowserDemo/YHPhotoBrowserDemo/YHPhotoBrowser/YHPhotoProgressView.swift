//
//  YHPhotoProgressView.swift
//  YHPhotoBrowserDemo  图像下载进度视图
//
//  Created by yangqianhua on 2018/3/16.
//  Copyright © 2018年 yangqianhua. All rights reserved.
//

import UIKit

class YHPhotoProgressView: UIView {

    /// 进度
    var progress:CGFloat = 0{
        didSet{
            self.setNeedsDisplay()
        }
    }
    
    /// 进度颜色
    var progressTintColor = UIColor.lightGray
    
    /// 底色
    var trackTintColor = UIColor.white
    
    /// 边框颜色
     var borderTintColor = UIColor.darkGray
    
    /// 构造函数
    ///
    /// - Parameter frame: Frame
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func draw(_ rect: CGRect) {
        // 1. 基本数据准备
        if(rect.width == 0 && rect.height == 0){
            return
        }
        
        // 2. 如果已经完成，隐藏
        if(self.progress == 1.0){
            return
        }
        
        //半径和中心点
        var radius : CGFloat = min(rect.width, rect.height) * 0.5
        let center  = CGPoint.init(x: rect.width * 0.5, y: rect.height * 0.5)
        
        // 3. 绘制外圈
        self.borderTintColor.setStroke()
        let lineWidth : CGFloat = 2.0
        let borderPath = UIBezierPath.init(arcCenter: center, radius: radius - lineWidth * 0.5, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
        
        borderPath.lineWidth = lineWidth
        borderPath.stroke()
        
        // 4. 绘制内圆
        self.trackTintColor.setFill()
        radius -= lineWidth * 2
        let trackPath = UIBezierPath.init(arcCenter: center, radius: radius, startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
        
        trackPath.fill()
        
    
        // 5. 绘制进度
        self.progressTintColor.set()
        let start : CGFloat = CGFloat(-(Double.pi / 2.0))
        let end = start + self.progress * CGFloat(Double.pi * 2)
        let progressPath = UIBezierPath.init(arcCenter: center, radius: radius, startAngle: start, endAngle: end, clockwise: true)
        progressPath.addLine(to: center)
        progressPath.close()
        progressPath.fill()
    }
}
