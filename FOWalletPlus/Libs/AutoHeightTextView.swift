//
//  AutoHeightTextView.swift
//  FOWalletPlus
//
//  Created by Sleep on 2018/11/14.
//  Copyright © 2018 Sleep. All rights reserved.
//

import UIKit

@objc protocol AutoHeightTextViewDelegate: NSObjectProtocol {
    
    /// delegate
    ///
    /// - Parameters:
    ///   - sender: target
    ///   - textValue: 输入框里的文字
    ///   - textHeight: 输入框的高度
    @objc optional func autoHeightTextView(_ sender: AutoHeightTextView, textValue: String, textHeight: CGFloat)
}

class AutoHeightTextView: UITextView {
    open weak var myDelegate: AutoHeightTextViewDelegate?
    open var autoHeight: Bool = true
    open var maxNumberOfLines: CGFloat = 1 {
        didSet {
            maxTextH = ceil((self.font?.lineHeight)! * maxNumberOfLines + textContainerInset.top + textContainerInset.bottom)
        }
    }
    open var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    open var placeholder: String = ""
    open var placeholderColor: UIColor = UIColor.RGBA(r: 117, g: 117, b: 117, a: 1)
    
    private var textH: CGFloat = 36
    private var maxTextH: CGFloat = 36
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        makeUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }
    
    private func makeUI() {
        isScrollEnabled = false
        scrollsToTop = false
        showsHorizontalScrollIndicator = false
        enablesReturnKeyAutomatically = true
        font = UIFont.systemFont(ofSize: 16)
        NotificationCenter.default.addObserver(self, selector: #selector(textDidChange), name: .UITextViewTextDidChange, object: nil)
    }
    
    @objc private func textDidChange() {
        if autoHeight {
            let height = CGFloat(ceilf(Float(sizeThatFits(CGSize(width: self.width, height: CGFloat(MAXFLOAT))).height)))
            if textH != height {
                isScrollEnabled = height > maxTextH && maxTextH > 0
                textH = height
                if myDelegate != nil && !isScrollEnabled {
                    myDelegate?.autoHeightTextView!(self, textValue: self.text, textHeight: height)
                    super.layoutIfNeeded()
                }
            }
        }
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        if text.count > 0 || placeholder.count == 0 {
            return
        }
        let attributes: [NSAttributedStringKey: Any] = [
            NSAttributedStringKey.font: font!,
            NSAttributedStringKey.foregroundColor: placeholderColor
        ]
        var nextRect: CGRect
        if autoHeight {
            nextRect = CGRect(x: 5, y: 8, width: width - 10, height: height - 8)
        } else {
            nextRect = CGRect(x: 0, y: 0, width: width , height: height)
        }
        (placeholder as NSString).draw(in: nextRect, withAttributes: attributes)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
