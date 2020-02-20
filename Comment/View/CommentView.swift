//
//  CommentView.swift
//  CommentTools
//
//  Created by Zhang on 2020/2/20.
//  Copyright © 2020 com.qiutianxia.qiutianxia. All rights reserved.
//

import UIKit

let CommentViewHeight:CGFloat = 48
let ButtonWidth:CGFloat = CommentViewHeight

typealias CommentSelectClouse = (_ textField:UITextField?, _ button:UIButton?) ->Void

class CommentView: UIView {

    var commentSelectClouse:CommentSelectClouse!
    var textField:UITextField!
     var textViewToolsBarClouse:TextViewToolsBarClouse!
    init(buttons:[String]?, placeholder:String) {
        super.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.size.height - CommentViewHeight, width: UIScreen.main.bounds.size.width, height: CommentViewHeight))
        self.setUpView(placeholder: placeholder, buttons: buttons)
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.init(white: 0.5, alpha: 0.5).cgColor
        self.backgroundColor = UIColor.white
    }
    
    func setUpView(placeholder:String, buttons:[String]?){
        let buttonCount:Int = buttons == nil ? 0 : buttons!.count
        let frame = CGRect.init(x: 10, y: 10, width: UIScreen.main.bounds.size.width - CGFloat(buttonCount) * ButtonWidth - 10, height: CommentViewHeight - 20)
        textField = UITextField.init(frame: frame)
        textField.placeholder = placeholder
        textField.layer.cornerRadius = (CommentViewHeight - 20) / 2
        textField.layer.masksToBounds = true
        textField.layer.borderWidth = 1
        textField.leftViewMode = .always
        textField.isUserInteractionEnabled = true
        textField.layer.borderColor = UIColor.init(white: 0.5, alpha: 0.5).cgColor
//        textField.isEditing = false
        textField.delegate = self
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.textFieldTap))
        tap.numberOfTouchesRequired = 1
        tap.numberOfTapsRequired = 1
        textField.addGestureRecognizer(tap)
        self.addSubview(textField)
        if buttons != nil {
            for index in 0...buttonCount - 1 {
                let frame = CGRect.init(x: textField.frame.maxX + ButtonWidth * CGFloat(index), y: 0, width: ButtonWidth, height: CommentViewHeight)
                let button = UIButton.init(type: .custom)
                button.setImage(UIImage.init(named: buttons![index]), for: UIControl.State.normal)
                button.tag = index
                button.frame = frame
                button.addTarget(self, action: #selector(self.buttonClick(button:)), for: UIControl.Event.touchUpInside)
                self.addSubview(button)
            }
        }
    }
    
    func setPlaceholderText(font:UIFont, color:UIColor){
        let attrStr = NSMutableAttributedString.init(string: self.textField.placeholder!)
        attrStr.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSRange.init(location: 0, length: self.textField.placeholder!.count))
        attrStr.addAttribute(NSAttributedString.Key.font, value: font, range: NSRange.init(location: 0, length: self.textField.placeholder!.count))
        self.textField.attributedPlaceholder = attrStr
    }
    
    @objc func buttonClick(button:UIButton) {
        if self.commentSelectClouse != nil {
            self.commentSelectClouse(nil,button)
        }
    }
    
    @objc func textFieldTap(){
        let textView = TextViewToolBar.init(isHaveToolsView: true)
        textView.textViewToolsBarClouse = { tag ,isShare, ret, isSend in
            if self.textViewToolsBarClouse != nil {
                self.textViewToolsBarClouse(tag ,isShare, ret, isSend)
            }
        }
        UIApplication.shared.windows[0].addSubview(textView)
        if self.commentSelectClouse != nil {
            self.commentSelectClouse(self.textField, nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CommentView : UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
