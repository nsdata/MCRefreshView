//
//  UIScrollView+MCRefresh.swift
//  MCRefreshView
//
//  Created by zhmch0329 on 15/12/14.
//  Copyright © 2015年 zhmch0329. All rights reserved.
//

import UIKit

private var HeaderAssociationKey: UInt8 = 29
private var FooterAssociationKey: UInt8 = 13
private var ReloadDataClosureAssociationKey: UInt8 = 27

extension UIScrollView {
    
    var mcheader: MCRefreshHeader? {
        get {
            return objc_getAssociatedObject(self, &HeaderAssociationKey) as? MCRefreshHeader
        }
        set(newValue) {
            if mcheader != newValue {
                if mcheader != nil {
                    mcheader!.removeFromSuperview()
                }
                
                if newValue != nil {
                    self.addSubview(newValue!)
                }
                objc_setAssociatedObject(self, &HeaderAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    var mcfooter: MCRefreshFooter! {
        get {
            return objc_getAssociatedObject(self, &FooterAssociationKey) as? MCRefreshFooter
        }
        set(newValue) {
            if mcfooter != newValue {
                if mcfooter != nil {
                    mcfooter.removeFromSuperview()
                }
                
                self.addSubview(newValue)
                objc_setAssociatedObject(self, &FooterAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
    var totalDataCount: Int {
        var totalCount = 0
        if self.isKind(of: UITableView.classForCoder()) {
            let tableView = self as! UITableView
            for section in 0 ..< tableView.numberOfSections {
                totalCount += tableView.numberOfRows(inSection: section)
            }
        } else if self.isKind(of: UICollectionView.classForCoder()) {
            let collectionView = self as! UICollectionView
            for section in 0 ..< collectionView.numberOfSections{
                totalCount += collectionView.numberOfItems(inSection: section)
            }
        }
        return totalCount
    }
    
    var isHeaderRefreshing: Bool? {
        return mcheader?.isRefreshing()
    }
}
