//
//  TextViewToolBar.swift
//  CommentTools
//
//  Created by Zhang on 2020/2/20.
//  Copyright © 2020 com.qiutianxia.qiutianxia. All rights reserved.
//

import UIKit
import ISEmojiView

let sendButtomWidth:CGFloat = 70
let TextViewMarginTop:CGFloat = 12.5
let TextViewMarginLeft:CGFloat = 15
let TextViewHeight:CGFloat = 78.5
let ToolsViewHeight:CGFloat = 40.0
let BackgroundColor = UIColor(red: 0.92, green: 0.92, blue: 0.92, alpha: 1)

typealias ToolsButtonClickClouse = (_ tag:Int?, _ isShareButton:Bool? ,_ ret:Bool?) ->Void

class ToolsView: UIView {
    var shareButton:UIButton!
    var toolsButtonClickClouse:ToolsButtonClickClouse!
    
    init(frame: CGRect, imageBtns:[String]?) {
        super.init(frame: CGRect.init(x: 0, y: TextViewHeight + TextViewMarginTop, width: UIScreen.main.bounds.size.width, height: ToolsViewHeight))
        shareButton = UIButton.init(type: .custom)
        shareButton.frame = CGRect.init(x: TextViewMarginLeft, y: 0, width: 85, height: ToolsViewHeight)
        shareButton.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        shareButton.setTitleColor(UIColor(red: 0.59, green: 0.59, blue: 0.59,alpha:1), for: UIControl.State.normal)
        shareButton.titleEdgeInsets = UIEdgeInsets.init(top: 0, left: 10, bottom: 0, right: 0)
        shareButton.setTitle("同时转发", for: UIControl.State.normal)
        shareButton.setImage(UIImage.init(named: "share_normal"), for: UIControl.State.normal)
        shareButton.tag = 1000
        shareButton.addTarget(self, action: #selector(self.shareButtonClick), for: UIControl.Event.touchUpInside)
        self.addSubview(shareButton)
        if imageBtns != nil {
            for index in 0...imageBtns!.count - 1 {
                let frame = CGRect.init(x: shareButton.frame.maxX + CGFloat(index) * (ToolsViewHeight + 10), y: 0, width: ToolsViewHeight + 10, height: ToolsViewHeight)
                let button = UIButton.init(type: .custom)
                button.frame = frame
                button.setImage(UIImage.init(named: imageBtns![index]), for: UIControl.State.normal)
                button.tag = index
                button.addTarget(self, action: #selector(self.toolsButtonClick(sender:)), for: UIControl.Event.touchUpInside)
                self.addSubview(button)
            }
        }
        
    }
    
    @objc func shareButtonClick(){
        if self.toolsButtonClickClouse != nil {
            self.toolsButtonClickClouse(nil,true,self.shareButton.tag == 1000 ? true : false)
        }
        if self.shareButton.tag == 1000 {
            shareButton.setImage(UIImage.init(named: "share_select"), for: UIControl.State.normal)
            shareButton.tag = 1001
        }else{
            shareButton.setImage(UIImage.init(named: "share_normal"), for: UIControl.State.normal)
            shareButton.tag = 1000
        }
        
    }
    
    @objc func toolsButtonClick(sender:UIButton) {
        if self.toolsButtonClickClouse != nil {
            self.toolsButtonClickClouse(sender.tag, false, false)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

typealias TextViewToolsBarClouse = (_ tag:Int?, _ isShare:Bool?, _ ret:Bool?, _ isSender:Bool?, text:String?) ->Void
enum KeyBoardType {
    case system
    case emoji
}
class TextViewToolBar: UIView {

    var textView:UITextView!
    var sendButton:UIButton!
    var textViewHeight:CGFloat!
    var toolsView:ToolsView?
    var textViewToolsBarClouse:TextViewToolsBarClouse!
    
    var bottomType: BottomType! = .categories
    var emojis: [EmojiCategory]?
    var emojiView:EmojiView!
    var keyBoardType:KeyBoardType = .system
    init(isHaveToolsView:Bool) {
        textViewHeight = !isHaveToolsView ? TextViewHeight + TextViewMarginTop * 2 : TextViewHeight + TextViewMarginTop + ToolsViewHeight
        super.init(frame: CGRect.init(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: textViewHeight))
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(showKeyboard), name: UIResponder.keyboardDidShowNotification, object: nil)
        center.addObserver(self, selector: #selector(hiddenKeyboard), name: UIResponder.keyboardDidHideNotification, object: nil)
        self.backgroundColor = .white
        self.setUpView()
        self.setBackGroundColor(color: BackgroundColor)
        self.setUpEmojiView()
        if isHaveToolsView {
            self.normalToolsView()
        }
    }
    
    func normalToolsView(){
        toolsView = ToolsView.init(frame: CGRect.zero, imageBtns: ["image_select","#_select","@_select","moji_select"])
        self.addSubview(toolsView!)
        toolsView?.toolsButtonClickClouse = { tag, isShare, ret in
            if tag == 3 {
                self.keyBoardType = self.keyBoardType == .system ? .emoji : .system
                self.changeKeyBoardType(type: self.keyBoardType)
            }else{
                if self.textViewToolsBarClouse != nil {
                    self.textViewToolsBarClouse(tag, isShare, ret, false, self.textView.text)
                }
            }
        }
    }
    
    func changeToolsView(imageBtns:[String]?){
        toolsView = ToolsView.init(frame: CGRect.zero, imageBtns: imageBtns)
        toolsView?.toolsButtonClickClouse = { tag, isShare, ret in
            if tag == 3 {
                self.keyBoardType = self.keyBoardType == .system ? .emoji : .system
                self.changeKeyBoardType(type: self.keyBoardType)
            }else{
                if self.textViewToolsBarClouse != nil {
                    self.textViewToolsBarClouse(tag, isShare, ret, false, self.textView.text)
                }
            }
        }
    }
    
    func changeKeyBoardType(type:KeyBoardType) {
        switch type {
        case .system:
            self.textView.inputView = nil
            self.textView.reloadInputViews()
        default:
            self.textView.inputView = emojiView
            self.textView.reloadInputViews()
        }
    }
    
    @objc func showKeyboard(noti:NSNotification){
        let value:NSValue = ((noti.userInfo! as NSDictionary).object(forKey: "UIKeyboardBoundsUserInfoKey") as! NSValue)
        let keyboardSize = value.cgRectValue.size
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect.init(x: 0, y: UIScreen.main.bounds.size.height - keyboardSize.height - self.textViewHeight, width: UIScreen.main.bounds.size.width, height: self.textViewHeight)
        }) { (ret) in
            print("done")
        }
    }
    
    @objc func hiddenKeyboard(noti:NotificationCenter){
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect.init(x: 0, y: UIScreen.main.bounds.size.height, width: UIScreen.main.bounds.size.width, height: self.textViewHeight)
        }) { (ret) in
            print("done")
        }
    }
    
    func setUpEmojiView(){
        let keyboardSettings = KeyboardSettings(bottomType: bottomType)
        keyboardSettings.customEmojis = emojis
        keyboardSettings.countOfRecentsEmojis = 20
        keyboardSettings.updateRecentEmojiImmediately = true
        emojiView = EmojiView(keyboardSettings: keyboardSettings)
        emojiView.translatesAutoresizingMaskIntoConstraints = false
        emojiView.delegate = self
    }
    
    func setBackGroundColor(color:UIColor){
        self.backgroundColor = color
    }
    
    func setUpView(){
        textView = UITextView.init(frame: CGRect.init(x: TextViewMarginLeft, y: 10, width: UIScreen.main.bounds.size.width - sendButtomWidth - TextViewMarginLeft, height: TextViewHeight))
        textView.becomeFirstResponder()
        
        self.addSubview(textView)
        
        sendButton = UIButton.init(type: .custom)
        sendButton.setTitle("发布", for: UIControl.State.normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        sendButton.setTitleColor(UIColor(red: 0.11, green: 0.11, blue: 0.11,alpha:1), for: UIControl.State.normal)
        sendButton.frame = CGRect.init(x: textView.frame.maxX, y: 10, width: sendButtomWidth, height: TextViewHeight)
        sendButton.addTarget(self, action: #selector(self.senderButtonClick(sender:)), for: UIControl.Event.touchUpInside)
        self.addSubview(sendButton)
        
        
    }
    
    @objc func senderButtonClick(sender:UIButton) {
        if self.textViewToolsBarClouse != nil {
            self.textViewToolsBarClouse(nil, nil, nil, true, self.textView.text)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension TextViewToolBar : EmojiViewDelegate {
    func emojiViewDidSelectEmoji(_ emoji: String, emojiView: EmojiView) {
        textView.insertText(emoji)
    }
    
    func emojiViewDidPressChangeKeyboardButton(_ emojiView: EmojiView) {
        textView.inputView = nil
        textView.keyboardType = .default
        textView.reloadInputViews()
    }
    
    func emojiViewDidPressDeleteBackwardButton(_ emojiView: EmojiView) {
        textView.deleteBackward()
    }
    
    func emojiViewDidPressDismissKeyboardButton(_ emojiView: EmojiView) {
        textView.resignFirstResponder()
    }
}
