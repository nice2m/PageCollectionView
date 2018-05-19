//
//  PageCollectionViewLayout.swift
//  PageCollectionView
//
//  Created by vcredit on 2018/5/19.
//  Copyright © 2018年 vcredit. All rights reserved.
//

import UIKit


class PageCollectionViewLayout: UICollectionViewFlowLayout {
    var itemCountPerRow: Int = 0
    var rowCountPerPage: Int = 0
    var allAttributes = [UICollectionViewLayoutAttributes]()
    
    init(itemCountPerRow: Int,rowCountPerPage: Int,itemSize: CGSize) {
        super.init()
        self.itemCountPerRow = itemCountPerRow
        self.rowCountPerPage = rowCountPerPage
        self.itemSize = itemSize
        print("\n\nPageCollectionViewLayout.init:\(itemSize),:\(itemCountPerRow);\(rowCountPerPage)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MAKR:  - override
    
    // 兼容最后一页错误
    override func prepare() {
        super.prepare()
        let count = collectionView?.numberOfItems(inSection: 0) ?? 0
        for i in 0..<count{
            
            let indexPath = IndexPath(item: i, section: 0)
            let attributes = layoutAttributesForItem(at: indexPath)
            if let attr = attributes{
                allAttributes.append(attr)
            }
        }
        print("\n\n PageCollectionViewLayout.prepare:\(allAttributes)")
    }
    
    
    override var collectionViewContentSize: CGSize{
       return super.collectionViewContentSize
    }
    
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let item = indexPath.item
        
        let targetOffset = getTargetPositionWithItem(item: item)
        
        let item2 = originItemAt(index: targetOffset.targetX, y: targetOffset.targetY)
        let newIndexPath = IndexPath(item: item2, section: indexPath.section)
        
        let newAttr = super.layoutAttributesForItem(at: newIndexPath)
        if let newAttr = newAttr{
            newAttr.indexPath = indexPath
        }
        return newAttr
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var rsAttributes = [UICollectionViewLayoutAttributes]()
        if let attributes = attributes {
            for oldAttr in attributes{
                for newAttr in allAttributes{
                    if oldAttr.indexPath.item == newAttr.indexPath.item {
                        rsAttributes.append(newAttr)
                        break
                    }
                }
            }
        }
        print("\n\nPageCollectionViewLayout.layoutAttributesForElements:\(rsAttributes)")

        
        return rsAttributes
    }
    
    
    //MARK: - private
    
    
    
    /// 根据 item 计算目标item的位置
    ///
    /// - Parameter item: 未转换时的 item 序号
    /// - Returns: x 横向偏移  y 竖向偏移
    func getTargetPositionWithItem(item: Int) -> (targetX: Int, targetY: Int) {
        
        let itemInPage = Int(ceil( Double(item / (itemCountPerRow * rowCountPerPage))))
        
        let targetX = item % itemCountPerRow + itemInPage * itemCountPerRow
        let targetY = item / itemCountPerRow - itemInPage * rowCountPerPage
        
        print("\n\nnPageCollectionViewLayout.getTargetPositionWithItem:\(targetX) ;\(targetY)")

        return(targetX,targetY)
    }
    
    // 根据偏移量计算item
    func originItemAt(index x: Int,y: Int) -> Int {
        
        let rs = x * rowCountPerPage + y
        print("\n\n originItemAt:\(rs)")

        return rs
    }
    
}
