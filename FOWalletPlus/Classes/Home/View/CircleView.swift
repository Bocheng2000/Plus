//
//  CircleView.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/12/8.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

@objc protocol CircleViewDelegate: NSObjectProtocol {
    @objc optional func circleViewDidClick()
}

class CircleView: UIView {
    private var timer: Timer?
    private var progress: CGFloat = 0
    private var holderColor: UIColor = UIColor.colorWithHexString(hex: "#EEEEEE")
    weak open var delegate: CircleViewDelegate?
    
    open var circleWidth: CGFloat = 1
    open var circleColor: UIColor = UIColor.RGBA(r: 56, g: 216, b: 73, a: 1)
    open var value: CGFloat = 0 {
        didSet {
            if value == 0 || value > 1 {
                progress = value
                return
            }
            timer = Timer(timeInterval: 0.1, target: self, selector: #selector(setProgress), userInfo: nil, repeats: true)
            RunLoop.main.add(timer!, forMode: .commonModes)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addGest()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGest()
    }
    
    private func addGest() {
        backgroundColor = UIColor.clear
        
        let tapGest = UITapGestureRecognizer(target: self, action: #selector(tapGestInvoke(gest:)))
        addGestureRecognizer(tapGest)
    }
    
    @objc private func tapGestInvoke(gest: UITapGestureRecognizer) {
        if gest.state == .ended {
            if delegate != nil && delegate?.responds(to: #selector(CircleViewDelegate.circleViewDidClick)) ?? false {
                delegate?.circleViewDidClick!()
            }
        }
    }
    
    @objc private func setProgress() {
        if progress > value {
            removeTimer()
            return
        }
        if progress + 0.05 <= value {
            progress += 0.05
            setNeedsDisplay()
        } else {
            progress = value
            setNeedsDisplay()
            removeTimer()
        }
    }
    
    private func removeTimer() {
        if timer != nil {
            timer?.invalidate()
            timer = nil
        }
    }
    
    override func draw(_ rect: CGRect) {
        let bj = UIBezierPath()
        bj.lineWidth = circleWidth
        holderColor.set()
        bj.lineCapStyle = .round
        bj.lineJoinStyle = .round
        let radius = (min(width, height) - circleWidth) * 0.5
        bj.addArc(withCenter: CGPoint(x: width * 0.5, y: height * 0.5), radius: radius, startAngle: 0, endAngle: .pi * 2 , clockwise: true)
        bj.stroke()
        
        let path = UIBezierPath()
        path.lineWidth = circleWidth
        circleColor.set()
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        path.addArc(withCenter: CGPoint(x: rect.size.width * 0.5, y: rect.size.height * 0.5), radius: radius, startAngle: .pi * -0.5, endAngle: .pi * -0.5 + .pi * 2 * progress, clockwise: true)
        path.stroke()
    }
    
    deinit {
        removeTimer()
    }
}
