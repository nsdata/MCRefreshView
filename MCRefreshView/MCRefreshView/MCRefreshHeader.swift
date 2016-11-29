//
//  MCRefreshHeader.swift
//  MCRefreshView
//
//  Created by zhmch0329 on 15/12/14.
//  Copyright © 2015年 zhmch0329. All rights reserved.
//

import UIKit

class MCRefreshHeader: MCRefreshComponent {
    
    var ignoredScrollViewContentInsetTop: CGFloat = 0.0
    var lastUpdatedTimeKey = MCRefreshConst.UpdatedTimeKey
    var lastUpdatedTime: Date? {
        get {
            return UserDefaults.standard.object(forKey: lastUpdatedTimeKey) as? Date
        }
    }
    
    override func prepare() {
        super.prepare()
        
        if direction == .vertical {
            self.height = MCRefreshConst.HeaderHeight
        } else if direction == .horizontal {
            self.width = MCRefreshConst.HeaderWidth
        }
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        
        if direction == .vertical {
            self.y = -self.height - ignoredScrollViewContentInsetTop
        } else if direction == .horizontal {
            self.x = -self.width - ignoredScrollViewContentInsetTop
        }
        
    }
    
    override func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        
        // 在刷新的refreshing状态
        if state == .refreshing {
            // sectionheader停留解决
            return
        }
        
        scrollViewOriginalInset = scrollView!.contentInset
        
        if direction == .vertical {
            let offsetY = scrollView!.offsetY
            let happenOffsetY = -scrollViewOriginalInset.top
            
            if offsetY > happenOffsetY {
                return
            }
            
            let normalPullingOffsetY = happenOffsetY - self.height
            let pullingPercent = (happenOffsetY - offsetY)/self.height
            if scrollView!.isDragging {
                self.pullingPercent = pullingPercent
                if state == .idle && offsetY < normalPullingOffsetY {
                    state = .pulling
                } else if state == .pulling && offsetY >= normalPullingOffsetY {
                    state = .idle
                }
            } else if state == .pulling {
                beginRefreshing()
            } else if pullingPercent < 1 {
                self.pullingPercent = pullingPercent
            }
        } else if direction == .horizontal {
            let offsetX = scrollView!.offsetX
            let happenOffsetX = -scrollViewOriginalInset.left
            
            if offsetX > happenOffsetX {
                return
            }
            
            let normalPullingOffsetX = happenOffsetX - self.width
            let pullingPercent = (happenOffsetX - offsetX)/self.width
            if scrollView!.isDragging {
                self.pullingPercent = pullingPercent
                if state == .idle && offsetX < normalPullingOffsetX {
                    state = .pulling
                } else if state == .pulling && offsetX >= normalPullingOffsetX {
                    state = .idle
                }
            } else if state == .pulling {
                beginRefreshing()
            } else if pullingPercent < 1 {
                self.pullingPercent = pullingPercent
            }
        }
        
    }
    
    override var state: MCRefreshState {
        set {
            if state == newValue {
                return
            }
            let oldValue = super.state
            super.state = newValue
            if newValue == .idle {
                if oldValue != .refreshing {
                    return
                }
            
                UserDefaults.standard.set(Date(), forKey: lastUpdatedTimeKey)
                UserDefaults.standard.synchronize()
            
                UIView.animate(withDuration: MCRefreshConst.SlowDuration, animations: { () -> Void in
                    if self.direction == .vertical {
                        self.scrollView?.insetTop -= self.height
                        
                    } else if self.direction == .horizontal {
                        self.scrollView?.insetLeft -= self.width
                    }
                    
                    if self.automaticallyChangeAlpha {
                        self.alpha = 0.0
                    }
                }, completion: { (finished) -> Void in
                    self.pullingPercent = 0.0
                })
            } else if state == .refreshing {
                UIView.animate(withDuration: MCRefreshConst.FastDuration, animations: { () -> Void in
                    if self.direction == .vertical {
                        let top = self.scrollViewOriginalInset.top + self.height
                        self.scrollView?.insetTop = top
                        
                        self.scrollView?.offsetY = -top
                        
                    } else if self.direction == .horizontal {
                        let left = self.scrollViewOriginalInset.left + self.width
                        self.scrollView?.insetLeft = left
                        
                        self.scrollView?.offsetX = -left
                    }

                }, completion: { (finished) -> Void in
                    self.executeRefreshingCallback()
                })
            }
        }
        get {
            return super.state
        }
    }
    
    override func endRefreshing() {
        if scrollView!.isKind(of: UICollectionView.classForCoder()) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
                super.endRefreshing()
            }
        } else {
            super.endRefreshing()
        }
    }
    
}

extension MCRefreshHeader {
    convenience init(direction: MCRefreshDirection = .vertical, refreshingClosure closure: @escaping MCRefreshingClosure) {
        self.init(direction: direction)
        self.refreshingClosure = closure
    }
}

