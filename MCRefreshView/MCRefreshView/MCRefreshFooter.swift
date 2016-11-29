//
//  MCRefreshFooter.swift
//  MCRefreshView
//
//  Created by zhmch0329 on 15/12/15.
//  Copyright © 2015年 zhmch0329. All rights reserved.
//

import UIKit

class MCRefreshFooter: MCRefreshComponent {
    
    var automaticallyHidden: Bool = true
    
    override func prepare() {
        super.prepare()
        
        if direction == .vertical {
            self.height = MCRefreshConst.FooterHeight
        } else if direction == .horizontal {
            self.width = MCRefreshConst.FooterWidth
        }
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if let _ = newSuperview {
            // 监听scrollView数据的变化
            
        }
    }
    
    override func scrollViewContentSizeDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDidChange(change)
        
        if scrollView?.totalDataCount == 0 {
            self.isHidden = automaticallyHidden
        } else {
            self.isHidden = false
        }
    }
    
    func endRefreshingWithNoMoreData() {
        state = .noMoreData
    }
    
    func resetNoMoreData() {
        state = .idle
    }
    
}

extension MCRefreshFooter {
    convenience init(direction: MCRefreshDirection = .vertical, refreshingClosure closure: @escaping MCRefreshingClosure) {
        self.init(direction: direction)
        self.refreshingClosure = closure
    }
}
