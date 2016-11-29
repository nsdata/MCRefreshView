//
//  ViewController1.swift
//  MCRefreshView
//
//  Created by zhmch0329 on 15/12/14.
//  Copyright © 2015年 zhmch0329. All rights reserved.
//

import UIKit

class ViewController1: UIViewController, UICollectionViewDataSource {

    var dataSource = [String]()
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.register(CollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "Identifier")
        
        let footer = MCRefreshBackNormalFooter()
        footer.refreshingClosure = {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                self.reloadData()
                if self.dataSource.count > 33 {
                    footer.endRefreshingWithNoMoreData()
                } else {
                    footer.endRefreshing()
                }
            }
        }
        collectionView.footer = footer
        
        let header = MCRefreshNormalHeader()
        header.refreshingClosure = {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
                self.dataSource.removeAll()
                self.reloadData()
                footer.resetNoMoreData()
                header.endRefreshing()
            }
        }
        collectionView.header = header
        
        
        collectionView.header?.beginRefreshing()
    }
    
    fileprivate func reloadData() {
        var array = [String]()
        for i in self.dataSource.count ..< self.dataSource.count + 11 {
            array.append("第\(i)行")
        }
        
        self.dataSource.append(contentsOf: array)
        self.collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Identifier", for: indexPath) as! CollectionViewCell
        cell.label.text = dataSource[indexPath.row]
        return cell
    }
}
