//
//  ZYEmoticonAttachment.swift
//  表情键盘
//
//  Created by Pack Zhang on 16/4/27.
//  Copyright © 2016年 Pack Zhang. All rights reserved.
//

import UIKit

class ZYEmoticonAttachment: NSTextAttachment {
    
    var chs: String?
    
    //返回附件属性字符串
    class func imageTextWithModel(model: ZYEmoticonModel, font: CGFloat) -> NSAttributedString {
        
        //表情图片附件
        let attachment = ZYEmoticonAttachment()
        
        attachment.chs = model.chs
        
        attachment.image = UIImage(contentsOfFile: model.fullPathOfPNG!)
        
        attachment.bounds = CGRect(x: 0, y: -4, width: font, height: font)
        
        return NSAttributedString(attachment: attachment)
    }
}
