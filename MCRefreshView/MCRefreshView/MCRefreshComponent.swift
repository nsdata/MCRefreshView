//
//  MCRefreshComponent.swift
//  MCRefreshView
//
//  Created by zhmch0329 on 15/12/14.
//  Copyright © 2015年 zhmch0329. All rights reserved.
//

import UIKit

enum MCRefreshDirection {
    // 垂直 & 水平
    case vertical, horizontal
}

enum MCRefreshState {
    case idle, pulling, refreshing, willRefresh, noMoreData
}

typealias MCRefreshingClosure = () -> Void

class MCRefreshComponent: UIView {
    
    // MARK: - Private Property
    // 记录scrollView刚开始的inset
    var scrollViewOriginalInset: UIEdgeInsets = UIEdgeInsets.zero
    // 父控件
    weak var scrollView: UIScrollView?
    
    // MARK: - Refreshing Callback
    // 正在刷新的回调
    var refreshingClosure: MCRefreshingClosure?
    // 状态
    var state = MCRefreshState.pulling
    // 方向
    var direction = MCRefreshDirection.vertical 
    
    // pan Gesture Recognizer
    var panGestureRecognizer: UIPanGestureRecognizer?
    
    // 拉拽的百分比(交给子类重写)
    var pullingPercent: CGFloat = 1.0
    // 根据拖拽比例自动切换透明度
    var automaticallyChangeAlpha: Bool = false {
        didSet {
            if isRefreshing() {
                return
            }
            if automaticallyChangeAlpha {
                self.alpha = pullingPercent
            }
        }
    }
    
    // MARK: init method
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    init() {
        super.init(frame: CGRect.zero)
        prepare()
    }
    
    init(direction: MCRefreshDirection) {
        super.init(frame: CGRect.zero)
        self.direction = direction
        prepare()
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: override method
    override func layoutSubviews() {
        super.layoutSubviews()
        placeSubviews()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        if let superView = newSuperview {
            guard superView.isKind(of: UIScrollView.classForCoder()) else {
                return
            }
            removeObservers()
            
            if direction == .vertical {
                self.width = superView.width
                self.x = 0
            } else if direction == .horizontal {
                self.height = superView.height
                self.y = 0
            }
            
            scrollView = superView as? UIScrollView
            scrollView?.alwaysBounceVertical = direction == .vertical
            scrollView?.alwaysBounceHorizontal = direction == .horizontal
            
            scrollViewOriginalInset = scrollView!.contentInset
            
            state = .idle
            
            addObservers()
        } else {
            removeObservers()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if state == .willRefresh {
            state = .refreshing
        }
    }
    
    // MARK: KVO
    fileprivate func addObservers() {
        let options: NSKeyValueObservingOptions = [.new, .old]
        scrollView?.addObserver(self, forKeyPath: MCRefreshConst.ContentOffset, options: options, context: nil)
        scrollView?.addObserver(self, forKeyPath: MCRefreshConst.ContentSize, options: options, context: nil)
        panGestureRecognizer = self.scrollView?.panGestureRecognizer
        panGestureRecognizer?.addObserver(self, forKeyPath: MCRefreshConst.PanState, options: options, context: nil)
    }
    
    fileprivate func removeObservers() {
        self.superview?.removeObserver(self, forKeyPath: MCRefreshConst.ContentOffset)
        self.superview?.removeObserver(self, forKeyPath: MCRefreshConst.ContentSize)
        panGestureRecognizer?.removeObserver(self, forKeyPath: MCRefreshConst.PanState)
        panGestureRecognizer = nil
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard self.isUserInteractionEnabled else {
            return
        }
        
        if keyPath == MCRefreshConst.ContentSize {
            scrollViewContentSizeDidChange(change )
        }
        
        guard !self.isHidden else {
            return
        }
        
        if keyPath == MCRefreshConst.ContentOffset {
            scrollViewContentOffsetDidChange(change )
        } else if keyPath == MCRefreshConst.PanState {
            scrollViewPanStateDidChange(change )
        }
    }
    
    func scrollViewContentOffsetDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        
    }
    
    func scrollViewContentSizeDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        
    }
    
    func scrollViewPanStateDidChange(_ change: [NSKeyValueChangeKey : Any]?) {
        
    }
    
}

// MARK: - subview achieve
extension MCRefreshComponent {
    func prepare() {
        // 基本属性
        if direction == .vertical {
            self.autoresizingMask = .flexibleWidth
        } else {
            self.autoresizingMask = .flexibleHeight
        }
        self.backgroundColor = UIColor.clear
        
    }
    
    func placeSubviews() {

    }
    

}

// MARK: - subview override
extension MCRefreshComponent {
    
}

// MARK: - Public method
extension MCRefreshComponent {
    func beginRefreshing() {
        UIView.animate(withDuration: MCRefreshConst.FastDuration, animations: { () -> Void in
            self.alpha = 1.0
        }) 
        pullingPercent = 1.0
        if (self.window != nil) {
            state = .refreshing
        } else {
            state = .willRefresh
            // 刷新(预防从另一个控制器回到这个控制器的情况，回来要重新刷新一下)
            self.setNeedsDisplay()
        }
    }
    
    func endRefreshing() {
        state = .idle
    }
    
    func isRefreshing() -> Bool {
        return (state == .refreshing)||(state == .willRefresh)
    }
    
    func executeRefreshingCallback() {
        DispatchQueue.main.async { () -> Void in
            if let refreshingClosure = self.refreshingClosure {
                refreshingClosure()
            }
        }
    }
}

extension UILabel {
    class func label() -> UILabel {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textColor = UIColor(white: 0.4, alpha: 1.0)
        label.textAlignment = .center
        label.backgroundColor = UIColor.clear
        return label;
    }
}
























