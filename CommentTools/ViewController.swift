//
//  ViewController.swift
//  CommentTools
//
//  Created by Zhang on 2020/2/20.
//  Copyright © 2020 com.qiutianxia.qiutianxia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let commentView = CommentView.init(buttons: ["Comment_Comment","Comment_Collect_normal","Comment_share"], placeholder: "大神快来评论吧")
        // Do any additional setup after loading the view.
        commentView.commentSelectClouse = { textField, button in
            if button != nil && button?.tag == 1 {
                button?.setImage(UIImage.init(named: "Comment_Collect_Select"), for: UIControl.State.normal)
            }
        }
        commentView.textViewToolsBarClouse = { tag, isShare,ret,isSend in
            print("点击事件")
        }
        commentView.setPlaceholderText(font: UIFont.systemFont(ofSize: 9), color: UIColor.red)
        self.view.addSubview(commentView)
    }


}

