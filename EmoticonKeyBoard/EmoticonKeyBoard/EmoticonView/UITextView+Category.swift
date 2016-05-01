//
//  UITextView+Category.swift
//  表情键盘
//
//  Created by Pack Zhang on 16/4/27.
//  Copyright © 2016年 Pack Zhang. All rights reserved.
//

import UIKit

extension UITextView {
    
    func handleTextWithEmoticonModel(model: ZYEmoticonModel) {
        //富文本
        
        if model.emojiCode != nil {
            
            //emoji表情
            
            self.replaceRange(self.selectedTextRange!, withText: model.emojiCode!)
            
        }
        
        if model.fullPathOfPNG != nil {
            //微博表情
            
            let imageText = ZYEmoticonAttachment.imageTextWithModel(model, font: font!.lineHeight)
            
            let AT = NSMutableAttributedString(attributedString: self.attributedText)
            
            let range = self.selectedRange
            
            AT.replaceCharactersInRange(range, withAttributedString: imageText)
            
            //讲字符串的大小设置为文本大小!!!!!
            AT.addAttribute(NSFontAttributeName, value: font!, range: NSMakeRange(range.location, 1))
            
            self.attributedText = AT

            self.selectedRange = NSMakeRange(range.location + 1, 0)
            
        }
        
        if model.isDeleteBtn {
            //删除按钮
            self.deleteBackward()
        }
    }
    
    //返回要上传到服务器的字符串
    func loadStringFromTextViewAttributeString() -> String{
        //系统内部会对文本按相同类型进行截断
        
        var str = String()
        
        self.attributedText.enumerateAttributesInRange(NSRange(location: 0, length: self.attributedText.length), options: NSAttributedStringEnumerationOptions(rawValue: 0)) { (dic, range, pointer) in
            if let attachment = dic["NSAttachment"]{
                let s = attachment  as! ZYEmoticonAttachment
                str += s.chs!
            }else{
                str += self.attributedText.attributedSubstringFromRange(range).string
            }
            
        }
        return str
    }
    
}
