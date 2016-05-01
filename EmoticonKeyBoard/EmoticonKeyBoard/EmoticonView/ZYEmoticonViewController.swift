//
//  ZYEmoticonViewController.swift
//  表情键盘
//
//  Created by Pack Zhang on 16/4/14.
//  Copyright © 2016年 Pack Zhang. All rights reserved.
//

import UIKit

private let ZYEmoticonCellReuseIdentifier = " ZYEmoticonCellReuseIdentifier"

class ZYEmoticonViewController: UIViewController {

    /*
     MARK:使用步骤
     - 1.懒加载控制器并设置 "textView"
     - 2.将textView的 "inputView" 设置为 "ZYEmoticonViewController" 的View
     */
    
    var textView: UITextView? {
        didSet{
            
            emoticonButtonClickBlock = { (model) in
                self.textView!.handleTextWithEmoticonModel(model)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
    }
    
    
    private func setUpUI() {

        
        //1 添加子控件
        view.addSubview(collectionView)
        view.addSubview(toolbar)
        view.addSubview(pageIndicator)
        
        //2 布局子控件
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        pageIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: collectionView, attribute: .Bottom, relatedBy: .Equal, toItem: toolbar, attribute: .Top, multiplier: 1.0, constant: 0))
        
        
        view.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: toolbar, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 35))
        
        view.addConstraint(NSLayoutConstraint(item: pageIndicator, attribute: .CenterX, relatedBy: .Equal, toItem: toolbar, attribute: .CenterX, multiplier: 1.0, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: pageIndicator, attribute: .Bottom, relatedBy: .Equal, toItem: toolbar, attribute: .Top, multiplier: 1.0, constant: 0))
        
    }


    @objc func toolBarButtonClick(btn: UIBarButtonItem) {
        currentSection = btn.tag
        collectionView.selectItemAtIndexPath(NSIndexPath(forItem: 0, inSection: btn.tag), animated: false, scrollPosition: UICollectionViewScrollPosition.Left)
    }

    // MARK: - 懒加载
    
    //定义一个闭包属性，保存回调代码
    private var emoticonButtonClickBlock: ((model: ZYEmoticonModel) -> ())?
    
    private var emoticonGroups: [ZYEmoticonGroup] = ZYEmoticonGroup.emoticonGroups
    
    private lazy var pageIndicator: UIPageControl = {
        let p = UIPageControl()
        p.hidesForSinglePage = true
        p.currentPage = 0
        p.currentPageIndicatorTintColor = UIColor.orangeColor()
        p.pageIndicatorTintColor = UIColor.whiteColor()
        return p
    }()
    
    private lazy var collectionView: UICollectionView = {
        
        let cv = UICollectionView(frame: CGRectZero, collectionViewLayout: ZYEmoticonViewFlowLayout())
        
        cv.backgroundColor = UIColor(white: 0.0, alpha: 0.01)
        
        cv.dataSource = self
        cv.delegate = self
        
        cv.registerClass(ZYEmoticonViewCell.self, forCellWithReuseIdentifier: ZYEmoticonCellReuseIdentifier)

        return cv
    }()
    
    private lazy var toolbar: UIToolbar = {
        let tb = UIToolbar()
        
        tb.tintColor = UIColor.grayColor()
        
        let itemName = ["最近", "默认", "emoji", "浪小花"]
        
        var items = [UIBarButtonItem]()
        var index = 0
        for name in itemName {
            let btn = UIBarButtonItem(title: name, style: UIBarButtonItemStyle.Plain, target: self, action: #selector(self.toolBarButtonClick(_:)))
            
            btn.tag = index
            index += 1
            items.append(btn)
            
            let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
            
            items.append(space)
        }
        
        items.removeLast()
        
        tb.items = items
        
        return tb
    }()
    
    //表情键盘总页数
    private lazy var totalPage: Int = {
        var c  = 0
        for e in self.emoticonGroups {
            c += e.pages
        }
        
        return c
    }()
    
    private var lastIndex: Int = 0
    
    private var currentSection: Int = 0

}


extension ZYEmoticonViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return emoticonGroups.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let group = emoticonGroups[section]
        return group.emoticonModels!.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ZYEmoticonCellReuseIdentifier, forIndexPath: indexPath) as! ZYEmoticonViewCell
        currentSection = indexPath.section
        print("indexPath.section = \(indexPath.section)")
        print("indexPath.item = \(indexPath.item)")
        let emoticonGroup = emoticonGroups[indexPath.section]
        
        cell.emoticon = emoticonGroup.emoticonModels![indexPath.item]
        
        return cell
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {

        let group = emoticonGroups[indexPath.section]
        
        let model = group.emoticonModels![indexPath.item]
        
        //执行闭包
        emoticonButtonClickBlock?(model: model)
        
        //刷新偏好表情界面
        if model.isDeleteBtn || model.type == nil{
            return
        }
        
        model.times+=1
        
        //在偏好表情页面
        if indexPath.section == 0 {
            return
        }
        
        //取得偏好表情数组
        var preferEmoticon = emoticonGroups.first?.emoticonModels
        
        //判断偏好表情数组是否已经存在该表情
        if !preferEmoticon!.contains(model) {
            //移除最后一个表情
            preferEmoticon?.removeLast()
            
            //添加表情
            preferEmoticon?.append(model)
        }
        
        emoticonGroups.first?.emoticonModels = preferEmoticon
        emoticonGroups.first!.refreshPreferEmoticonModels()
    }
    
    func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.isEqual(NSIndexPath(forItem: 20, inSection: 0)) {
            emoticonGroups.first!.refreshPreferEmoticonModels()
            collectionView.reloadSections(NSIndexSet(index: 0))
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        let w = collectionView.bounds.width
        
        let index = Int((scrollView.contentOffset.x + w * 0.5) / w)
        

        if index != lastIndex {

            pageIndicator.numberOfPages = emoticonGroups[currentSection].pages
            print("翻页")
            //[1 6 4 2]
            
            //[-]
            //[0]
            
            //[0 1 2 3 4 5 ]
            //[1 2 3 4 5 6 ]
            
            //[0 1 2 3]
            //[7 8 9 10]
            
            //[0  1]
            //[11 12]
            
            //计算的当前第几页
            
            //找到当前第几组（4）
            var b = 0
            //得到之前组的页数的总和
            for i in 0 ..< currentSection {
                b += emoticonGroups[i].pages
            }
            
            let page = index - b
            
            pageIndicator.currentPage = page

            lastIndex = index
        }

    }

}


class ZYEmoticonViewCell: UICollectionViewCell {
    
    var emoticon: ZYEmoticonModel? {
        
        didSet{
            
            //emoji表情
            if emoticon?.code != nil {

                //4 转化为String
                
                btn.setTitle(emoticon?.emojiCode, forState: .Normal)
            }else{
                btn.setTitle("", forState: .Normal)
            }
            
            //微博表情
            if emoticon?.chs != nil {
                
                let image = UIImage(contentsOfFile: emoticon!.fullPathOfPNG!)
                
                btn.setImage(image, forState: .Normal)
                
            }else if emoticon!.isDeleteBtn {
                
                btn.setImage(UIImage(named: "compose_emotion_delete"), forState: .Normal)
                btn.setImage(UIImage(named: "compose_emotion_delete_highlighted"), forState: .Highlighted)
            }else{
                btn.setImage(nil, forState: .Normal)
                btn.setImage(nil, forState: .Highlighted)
            }
            
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setUpUI()
    }
    
    private func setUpUI() {
        
        contentView.addSubview(btn)
        
        btn.frame = CGRectInset(bounds, 5, 5)
    }

    private lazy var btn: UIButton = {
       
        let btn = UIButton(type: UIButtonType.Custom)
        
        btn.userInteractionEnabled = false
        
        btn.titleLabel?.font = UIFont.systemFontOfSize(35)
        
        return btn
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class ZYEmoticonViewFlowLayout: UICollectionViewFlowLayout {
    
    override func prepareLayout() {
        minimumLineSpacing = 0
        minimumInteritemSpacing = 0
        scrollDirection = .Horizontal
        itemSize = cellSize()
        
        collectionView?.pagingEnabled = true
        collectionView?.showsVerticalScrollIndicator = false
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.bounces = false
        
        let margin = (collectionView?.bounds.size.height)! - itemSize.height * 3
        collectionView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: margin, right: 0)

    }
    
    private func cellSize() -> CGSize {
        
        let w = (collectionView?.bounds.size.width)! / 7.0
        
        let h = w
        return CGSize(width: w - 0.1, height: h)
    }
}
