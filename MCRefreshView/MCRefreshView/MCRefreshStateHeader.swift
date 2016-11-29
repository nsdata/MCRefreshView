//
//  MCRefreshStateHeader.swift
//  MCRefreshView
//
//  Created by zhmch0329 on 15/12/14.
//  Copyright © 2015年 zhmch0329. All rights reserved.
//

import UIKit

typealias MCLastUpdatedTimeText = (Date?) -> String

class MCRefreshStateHeader: MCRefreshHeader {
    
    var lastUpdatedTimeText: MCLastUpdatedTimeText?
    
    lazy var lastUpdatedTimeLabel = UILabel.label()
    lazy var stateLabel = UILabel.label()
    
    fileprivate var stateTitles = [MCRefreshState: String]()
    
    override func prepare() {
        super.prepare()
        
        self.addSubview(stateLabel)
        self.addSubview(lastUpdatedTimeLabel)
        
        self.setTitle(MCRefreshConst.HeaderIdleText, forState: .idle)
        self.setTitle(MCRefreshConst.HeaderPullingText, forState: .pulling)
        self.setTitle(MCRefreshConst.HeaderRefreshingText, forState:  .refreshing)
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        
        if stateLabel.isHidden {
            return
        }
        
        if direction == .vertical {
            if lastUpdatedTimeLabel.isHidden {
                stateLabel.frame = self.bounds;
            } else {
                // 状态
                stateLabel.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height * 0.5)
                // 更新时间
                lastUpdatedTimeLabel.frame = CGRect(x: 0, y: stateLabel.height, width: self.width, height: self.height - stateLabel.height)
            }
        } else if direction == .horizontal {
            if lastUpdatedTimeLabel.isHidden {
                stateLabel.frame = self.bounds;
            } else {
                // 状态
                stateLabel.frame = CGRect(x: 0, y: -54, width: self.width * 0.5, height: self.height)
                stateLabel.transform = CGAffineTransform(rotationAngle: CGFloat(3 * M_PI_2))
                // 更新时间
                lastUpdatedTimeLabel.frame = CGRect(x: stateLabel.width, y: -54, width: self.width - stateLabel.width, height: self.height)
                lastUpdatedTimeLabel.transform = CGAffineTransform(rotationAngle: CGFloat(3 * M_PI_2))
            }
        }
        

    }
    
    override var state: MCRefreshState {
        set {
            if state == newValue {
                return
            }
            super.state = newValue
            
            stateLabel.text = stateTitles[newValue]
            setLastUpdatedTimeLabelWithTimeKey(lastUpdatedTimeKey)
        }
        get {
            return super.state
        }
    }
    
    func setLastUpdatedTimeLabelWithTimeKey(_ timeKey: String) {
        lastUpdatedTimeKey = timeKey
        
        let lastUpdatedTime = UserDefaults.standard.object(forKey: lastUpdatedTimeKey) as? Date
        
        if let lastUpdatedTimeText = lastUpdatedTimeText {
            lastUpdatedTimeLabel.text = lastUpdatedTimeText(lastUpdatedTime)
            return
        }
        
        if let time = lastUpdatedTime {
            let calendar = Calendar.current
            let unitFlags: NSCalendar.Unit = [NSCalendar.Unit.year, NSCalendar.Unit.month, NSCalendar.Unit.day, NSCalendar.Unit.hour, NSCalendar.Unit.minute]
            let cmp1 = (calendar as NSCalendar).components(unitFlags, from: time)
            let cmp2 = (calendar as NSCalendar).components(unitFlags, from: Date())
            
            let formatter = DateFormatter()
            if cmp1.day == cmp2.day {
                formatter.dateFormat = "今天 HH:mm"
            } else if cmp1.year == cmp2.year {
                formatter.dateFormat = "MM-dd HH:mm"
            } else {
                formatter.dateFormat = "yyyy-MM-dd HH:mm"
            }
            let timeString = formatter.string(from: time)
            lastUpdatedTimeLabel.text = "最后更新：" + timeString
        } else {
            lastUpdatedTimeLabel.text = "最后更新：无记录"
        }
    }
    
}

extension MCRefreshStateHeader {
    func setTitle(_ title: String?, forState state: MCRefreshState) {
        if let title = title {
            stateTitles[state] = title
            stateLabel.text = stateTitles[self.state]
        }
    }
}
