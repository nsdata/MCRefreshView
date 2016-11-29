//
//  MCRefreshBackStateFooter.swift
//  MCRefreshView
//
//  Created by zhmch0329 on 15/12/15.
//  Copyright © 2015年 zhmch0329. All rights reserved.
//

import UIKit

class MCRefreshBackStateFooter: MCRefreshBackFooter {
    
    var stateLabel = UILabel.label()
    
    var stateTitles = [MCRefreshState: String]()
    
    override func prepare() {
        super.prepare()
        
        setTitle(MCRefreshConst.FooterIdleText, forState: .idle)
        setTitle(MCRefreshConst.FooterPullingText, forState: .pulling)
        setTitle(MCRefreshConst.FooterRefreshingText, forState: .refreshing)
        setTitle(MCRefreshConst.FooterNoMoreDataText, forState: .noMoreData)
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        
        if direction == .vertical {
            stateLabel.frame = self.bounds
        } else if direction == .horizontal {
            stateLabel.frame = CGRect(x: 0, y: -54, width: self.bounds.width, height: self.bounds.height)
            stateLabel.transform = CGAffineTransform(rotationAngle: CGFloat(3 * M_PI_2))
        }
        
        self.addSubview(stateLabel)
    }
    
    override var state: MCRefreshState {
        get {
            return super.state
        }
        set {
            if state == newValue {
                return
            }
            super.state = newValue
            stateLabel.text = stateTitles[newValue]
        }
    }
}


extension MCRefreshBackStateFooter {
    func setTitle(_ title: String?, forState state: MCRefreshState) {
        if let title = title {
            stateTitles[state] = title
            stateLabel.text = stateTitles[self.state]
        }
    }
}
