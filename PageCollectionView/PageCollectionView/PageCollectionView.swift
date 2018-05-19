//
//  PageCollectionView.swift
//  PageCollectionView
//
//  Created by vcredit on 2018/5/19.
//  Copyright © 2018年 vcredit. All rights reserved.
//

import UIKit

class PageCollectionView: UIView {
    
    private var layout: PageCollectionViewLayout!
    weak private var collectionView: UICollectionView!
    private var pageControl: PillPageControl!
    private var pageControlContainer: UIView!
    
    private let kPlaceHolderCellName = "PageCollectionViewPlaceHolderCell"
    
    // 一行多少个
    private var itemCountPerRow: Int!
    // 一页多少行
    private var rowCountPerPage: Int!
    // collection cell nib 文件名
    private var cellNibName: [String]!
    // collection cell 复用标识
    private var cellReUseId:[String]!
    
    
    /// 除去可能存在的占位符，包含多少个真实的数据
    private var realDataCount: Int!
    
    private var cellForItemClosure: ((_ collectionView: UICollectionView, _ cellForItemAt:IndexPath) -> UICollectionViewCell)!
    private var numberOfItemInsectionClosure: ((_ collectionView: UICollectionView, _ section: Int) -> Int)!
    private var didSelectItemClosure: ((_ collectionView: UICollectionView, _ indexPath: IndexPath) -> Void)!
    
    
    
    
    
    //MARK: - interface
    
    func configCellForItem(with closure: @escaping ((_ collectionView: UICollectionView, _ cellForItemAt:IndexPath) -> UICollectionViewCell)) {
        cellForItemClosure = closure
    }
    
    func configNumberOfItemInsection(with closure:@escaping ((_ collectionView: UICollectionView, _ section: Int) -> Int)){
        numberOfItemInsectionClosure = closure
    }
    
    func configDidSelectItem(with closure:@escaping ((_ collectionView: UICollectionView, _ indexPath: IndexPath) -> Void)){
        didSelectItemClosure = closure
    }
    
    init(frame: CGRect,itemCountPerRow: Int,rowCountPerPage: Int,cellNibName: [String],cellReuseId: [String] = [String]()) {
        super.init(frame: frame)
        self.itemCountPerRow = itemCountPerRow
        self.rowCountPerPage = rowCountPerPage
        
        let collectionFrame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height - 20)
        let itemSizeWidth: CGFloat = collectionFrame.width / CGFloat(itemCountPerRow)
        let itemSizeHeight: CGFloat = collectionFrame.height / CGFloat(rowCountPerPage)
        
        layout = PageCollectionViewLayout(itemCountPerRow: itemCountPerRow, rowCountPerPage: rowCountPerPage, itemSize: CGSize(width: itemSizeWidth, height: itemSizeHeight))
        layout.minimumLineSpacing = 0.0
        layout.minimumInteritemSpacing = 0.0
        layout.scrollDirection = .horizontal
        layout.headerReferenceSize = .zero
        
        let collectionview = UICollectionView(frame: collectionFrame, collectionViewLayout: layout)
        
        collectionview.backgroundColor = UIColor.white
        self.collectionView = collectionview
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionview.isPagingEnabled = true
        collectionview.showsHorizontalScrollIndicator = false
        addSubview(collectionView)
        
        for i in 0..<cellNibName.count{
            let nib = UINib.init(nibName: cellNibName[i], bundle: nil)
            let cellReuseID = cellReuseId.count > 0 ? cellReuseId[i] : cellNibName[i]
            collectionview.register(nib, forCellWithReuseIdentifier: cellReuseID)
        }
        
        // 占位符
        let nib = UINib(nibName: kPlaceHolderCellName, bundle: nil)
        collectionview.register(nib, forCellWithReuseIdentifier: kPlaceHolderCellName)
        
        //配置下方 pageControl
        pageControlContainer = UIView(frame: CGRect(x: 0, y: frame.height - 20, width: frame.width, height: 20))
        pageControlContainer.backgroundColor = UIColor.lightGray
        pageControl = PillPageControl(frame: pageControlContainer.bounds)
        pageControlContainer.addSubview(pageControl)
        addSubview(pageControlContainer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PageCollectionView: UICollectionViewDataSource,UICollectionViewDelegate{
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let page = scrollView.contentOffset.x / scrollView.bounds.width
        let progressInPage = scrollView.contentOffset.x - (page * scrollView.bounds.width)
        let progress = CGFloat(page) + progressInPage
        pageControl.progress = progress
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var rs = numberOfItemInsectionClosure(collectionView,section)
        rs = getCollectionItemCount(with: rs)
        return rs
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.item >= realDataCount{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kPlaceHolderCellName, for: indexPath)
            return cell
        }
        else{
            return cellForItemClosure(collectionView,indexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item >= realDataCount{
            return
        }
        else{
            return didSelectItemClosure(collectionView,indexPath)
        }
    }
    
}

extension PageCollectionView{
    
    
    /// 刷新数据，更新实际数据条数
    ///
    /// - Parameter dataSourceCount:
    func reloadData(dataSourceCount: Int) {
        realDataCount = dataSourceCount
        
        // 刷新pageControl 的frame:以及count
        let maxPage = Int(ceil(Double(dataSourceCount) / Double(rowCountPerPage * itemCountPerRow)))
        
        // 默认宽度 20 ,高度 2 ,padding 7
        let pageControlWidth:CGFloat = CGFloat(20 * maxPage + (maxPage - 1) * 7)
        
        pageControl.frame = CGRect(x: (pageControlContainer.bounds.width - pageControlWidth) / 2, y: pageControlContainer.bounds.height / 2 - 1, width:pageControlWidth, height: 2)
        pageControl.pageCount = maxPage
        
        collectionView.reloadData()

    }
    
    private func getCollectionItemCount(with dataSourceCount: Int) -> Int {
        
        
        var rs = dataSourceCount
        
        let countPerPage = Int(rowCountPerPage * itemCountPerRow)
        
        // 最后一页，差多少个 满一页，那么就在数据总数上加多少，凑满一页的数量；以达到 collection 按照页翻页；如果dataCount 不是 itemCountPerRow * rowCountPerPage 的 整数倍，cell 显示会出问题，pageEnabled 在最后一页会出问题；
        // 此处特殊处理，达到 itemCountPerRow * rowCountPerPage 整数倍
        
        let leftCount = dataSourceCount % countPerPage
        if leftCount != 0 {
            rs += countPerPage - leftCount
        }
        print("\n\nPageCollectionView.getCollectionItemCount ,\(rs)")
        return rs
    }
}
