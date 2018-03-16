# YHPhotoBrowserDemo
Swift实现的网络图片浏览器<br/>

###使用方法<br/>
//selectedIndex：选中照片索引<br/>
// urls:大图的地址数组<br/>
//parentImageViews：展示缩略图的图片控件<br/>
let vc = YHPhotoBrowserController.photoBrowser(selectedIndex: selectedIndex, urls: bigImageArray, parentImageViews: imageViews)<br/>
self.present(vc, animated: true, completion: nil)<br/>

![](http://img.blog.csdn.net/20180316172820184)
