//
//  MCRefreshBackFooter.swift
//  MCRefreshView
//
//  Created by zhmch0329 on 15/12/15.
//  Copyright © 2015年 zhmch0329. All rights reserved.
//

import UIKit

class MCRefreshBackFooter: MCRefreshFooter {
    
    fileprivate var lastRefreshCount = 0
    fileprivate var lastDelta: CGFloat = 0.0
    
    // igored scrollview contentInset: Vertical--Bottom, Horizontal--Right
    var ignoredScrollViewContentInset: CGFloat = 0.0
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        
        if let _ = newSuperview {
            scrollViewContentSizeDidChange(nil)
        }
    }
    
    fileprivate func refreshingOffset() -> CGFloat {
        let deltaSide = heightForContentBreakView()
        var inset: CGFloat = 0.0
        if direction == .vertical {
            inset = scrollViewOriginalInset.top
        } else if direction == .horizontal {
            inset = scrollViewOriginalInset.right
        }
        if deltaSide > 0 {
            return deltaSide - inset
        } else {
            return -inset
        }
    }
    
    fileprivate func heightForContentBreakView() -> CGFloat {
        if direction == .vertical {
            let h = scrollView!.height - scrollViewOriginalInset.bottom - scrollViewOriginalInset.top
            return scrollView!.contentHeight - h
        } else if direction == .horizontal {
            let w = scrollView!.width - scrollViewOriginalInset.left - scrollViewOriginalInset.right
            return scrollView!.contentWidth - w
        }
        return 0
    }
    
    // MARK: - override super class method
    override func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentOffsetDidChange(change)
        
        if state == .refreshing || self.isHidden {
            return
        }
        
        scrollViewOriginalInset = scrollView!.contentInset
        
        if direction == .vertical {
            // current contentOffset.y
            let offsetY = scrollView!.offsetY
            // trigger refreshing offset y value
            let happenOffsetY = refreshingOffset()
            // if drop down, return
            if offsetY <= happenOffsetY {
                return
            }
            
            let pullingPercent = (offsetY - happenOffsetY)/self.height
            
            if state == .noMoreData {
                self.pullingPercent = pullingPercent
                return
            }
            
            if scrollView!.isDragging {
                self.pullingPercent = pullingPercent
                
                let normalPullingOffsetY = happenOffsetY + self.height
                if state == .idle && offsetY > normalPullingOffsetY {
                    state = .pulling
                } else if state == .pulling && offsetY <= normalPullingOffsetY {
                    state = .idle
                }
            } else if state == .pulling {
                beginRefreshing()
            } else if pullingPercent < 1 {
                self.pullingPercent = pullingPercent
            }
        } else if direction == .horizontal {
            let offsetX = scrollView!.offsetX
            let happenOffsetX = refreshingOffset()
            
            if offsetX <= happenOffsetX {
                return
            }
            
            let pullingPercent = (offsetX - happenOffsetX)/self.width
            
            if state == .noMoreData {
                self.pullingPercent = pullingPercent
                return
            }
            
            if scrollView!.isDragging {
                self.pullingPercent = pullingPercent
                
                let normalPullingOffsetX = happenOffsetX + self.width
                if state == .idle && offsetX > normalPullingOffsetX {
                    state = .pulling
                } else if state == .pulling && offsetX <= normalPullingOffsetX {
                    state = .idle
                }
            } else if state == .pulling {
                beginRefreshing()
            } else if pullingPercent < 1 {
                self.pullingPercent = pullingPercent
            }
        }
    }
    
    override func scrollViewContentSizeDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        super.scrollViewContentSizeDidChange(change )
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(MCRefreshConst.SlowDuration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { () -> Void in
            if self.direction == .vertical {
                let contentHeight = self.scrollView!.contentHeight + self.ignoredScrollViewContentInset
                let scrollHeight = self.scrollView!.height - self.scrollViewOriginalInset.top - self.scrollViewOriginalInset.bottom + self.ignoredScrollViewContentInset
                self.y = max(contentHeight, scrollHeight)
            } else if self.direction == .horizontal {
                let contentWidth = self.scrollView!.contentWidth + self.ignoredScrollViewContentInset
                let scrollWidth = self.scrollView!.width - self.scrollViewOriginalInset.left - self.scrollViewOriginalInset.right + self.ignoredScrollViewContentInset
                self.x = max(contentWidth, scrollWidth)
            }
        })
    }
    
    override var state: MCRefreshState {
        get {
            return super.state
        }
        set {
            if state == newValue {
                return
            }
            let oldValue = super.state
            super.state = newValue
            if newValue == .idle || state == .noMoreData {
                if oldValue == .refreshing {
                    UIView.animate(withDuration: MCRefreshConst.SlowDuration, animations: { () -> Void in
                        if self.direction == .vertical {
                            self.scrollView?.insetBottom -= self.lastDelta
                        } else if self.direction == .horizontal {
                            self.scrollView?.insetRight -= self.lastDelta
                        }
                        
                        if self.automaticallyChangeAlpha {
                            self.alpha = 0.0
                        }
                        }, completion: { (finished) -> Void in
                            self.pullingPercent = 0
                    })
                }
                let delta = heightForContentBreakView()
                if oldValue == .refreshing && delta > 0 && scrollView?.totalDataCount != lastRefreshCount {
                    if direction == .vertical {
                        scrollView?.offsetY = scrollView!.offsetY
                    } else if direction == .horizontal {
                        scrollView?.offsetX = scrollView!.offsetX
                    }
                }
            } else if state == .refreshing {
                lastRefreshCount = scrollView!.totalDataCount
                UIView.animate(withDuration: MCRefreshConst.FastDuration, animations: { () -> Void in
                    if self.direction == .vertical {
                        var bottom = self.height + self.scrollViewOriginalInset.bottom
                        let deltaH = self.heightForContentBreakView()
                        if deltaH < 0 {
                            bottom -= deltaH
                        }
                        self.lastDelta = bottom - self.scrollView!.insetBottom
                        self.scrollView?.insetBottom = bottom
                        self.scrollView?.offsetY = self.refreshingOffset() + self.height
                    } else if self.direction == .horizontal {
                        var right = self.width + self.scrollViewOriginalInset.right
                        let deltaW = self.heightForContentBreakView()
                        if deltaW < 0 {
                            right -= deltaW
                        }
                        self.lastDelta = right - self.scrollView!.insetRight
                        self.scrollView?.insetRight = right
                        self.scrollView?.offsetX = self.refreshingOffset() + self.width
                    }
                    
                    }, completion: { (finished) -> Void in
                        self.executeRefreshingCallback()
                })
            }

        }
    }
}

extension MCRefreshBackFooter {
    override func endRefreshing() {
        if scrollView!.isKind(of: UICollectionView.classForCoder()) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { () -> Void in
                super.endRefreshing()
            })
        } else {
            super.endRefreshing()
        }
    }
    
    override func endRefreshingWithNoMoreData() {
        if scrollView!.isKind(of: UICollectionView.classForCoder()) {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: { () -> Void in
                super.endRefreshingWithNoMoreData()
            })
        } else {
            super.endRefreshingWithNoMoreData()
        }
    }
    
}

