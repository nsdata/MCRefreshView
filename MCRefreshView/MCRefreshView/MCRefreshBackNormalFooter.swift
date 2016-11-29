//
//  MCRefreshBackNormalFooter.swift
//  MCRefreshView
//
//  Created by zhmch0329 on 15/12/15.
//  Copyright © 2015年 zhmch0329. All rights reserved.
//

import UIKit

class MCRefreshBackNormalFooter: MCRefreshBackStateFooter {
    
    let arrowView = UIImageView(image: UIImage(named: "arrow"))
    var activityIndicatorViewStyle: UIActivityIndicatorViewStyle = .gray {
        didSet {
            loadingView.activityIndicatorViewStyle = activityIndicatorViewStyle
            self.setNeedsDisplay()
        }
    }
    
    fileprivate var loadingView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func prepare() {
        super.prepare()
        
        self.addSubview(arrowView)
        loadingView.hidesWhenStopped = true
        self.addSubview(loadingView)
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        
        if let size = arrowView.image?.size {
            if direction == .vertical {
                arrowView.size = size
            } else {
                arrowView.size = CGSize(width: size.height, height: size.width)
            }
        }
        
        var arrowCenterX = self.width * 0.5
        if !stateLabel.isHidden && direction == .vertical {
            arrowCenterX -= 100
        }
        var arrowCenterY = self.height * 0.5
        if !stateLabel.isHidden && direction == .horizontal {
            arrowCenterY += 40
        }
        arrowView.center = CGPoint(x: arrowCenterX, y: arrowCenterY)
        
        loadingView.frame = arrowView.frame
    }
    
    override var state: MCRefreshState {
        get {
            return super.state
        }
        set {
            if state == newValue {
                return
            }
            let oldState = state
            super.state = newValue
            if state == .idle {
                if oldState == .refreshing {
                    if direction == .vertical {
                        arrowView.transform = CGAffineTransform(rotationAngle: -CGFloat(M_PI))
                    } else if direction == .horizontal {
                        arrowView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2) + 0.000001)
                    }
                    
                    UIView.animate(withDuration: MCRefreshConst.SlowDuration, animations: { () -> Void in
                        self.loadingView.alpha = 0.0
                        }, completion: { (finished) -> Void in
                            self.loadingView.alpha = 1.0
                            self.loadingView.stopAnimating()
                            self.arrowView.isHidden = false
                    })
                } else {
                    arrowView.isHidden = false
                    loadingView.stopAnimating()
                    UIView.animate(withDuration: MCRefreshConst.FastDuration, animations: { () -> Void in
                        if self.direction == .vertical {
                            self.arrowView.transform = CGAffineTransform(rotationAngle: 0.000001 - CGFloat(M_PI))
                        } else if self.direction == .horizontal {
                            self.arrowView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_2) + 0.000001)
                        }
                    })
                    
                }
            } else if state == .pulling {
                arrowView.isHidden = false
                loadingView.stopAnimating()
                UIView.animate(withDuration: MCRefreshConst.FastDuration, animations: { () -> Void in
                    if self.direction == .vertical {
                        self.arrowView.transform = CGAffineTransform(rotationAngle: -0.000001)
                    } else if self.direction == .horizontal {
                        self.arrowView.transform = CGAffineTransform(rotationAngle: CGFloat(3 * M_PI_2))
                    }
                })                
            } else if state == .refreshing {
                arrowView.isHidden = true
                loadingView.startAnimating()
            } else if state == .noMoreData {
                arrowView.isHidden = true
                loadingView.stopAnimating()
            }
        }
    }
}
