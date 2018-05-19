//
//  ViewController.swift
//  PageCollectionView
//
//  Created by vcredit on 2018/5/19.
//  Copyright © 2018年 vcredit. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var data = [String]()
    var pageCollectionView: PageCollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        for i in 0..<18{
            data.append(String(i))
        }
        
        let rect = CGRect(x: 0, y: view.bounds.height - 166, width: view.bounds.width, height: 166)
        pageCollectionView = PageCollectionView(frame: rect, itemCountPerRow: 4, rowCountPerPage: 2, cellNibName: ["HomeCollectionViewCell"])
        
        pageCollectionView.configCellForItem { [weak self] (collectionView, indexPath) -> UICollectionViewCell in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HomeCollectionViewCell", for: indexPath) as! HomeCollectionViewCell
            cell.config(text: (self?.data[indexPath.row])!)
            return cell
        }
        pageCollectionView.configNumberOfItemInsection { [weak self](collectionView, section) -> Int in
            return self?.data.count ?? 0
        }
        
        pageCollectionView.configDidSelectItem { (collectionView, indexPath) in
            print(indexPath)
        }
        
        view.addSubview(pageCollectionView)
        
        pageCollectionView.reloadData(dataSourceCount: data.count)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

