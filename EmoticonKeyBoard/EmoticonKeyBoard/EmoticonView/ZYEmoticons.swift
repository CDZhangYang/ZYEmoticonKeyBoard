//
//  ZYEmoticonGroup.swift
//  表情键盘
//
//  Created by Pack Zhang on 16/4/20.
//  Copyright © 2016年 Pack Zhang. All rights reserved.
//

import UIKit

private let mainPath = NSBundle.mainBundle().pathForResource("Emoticons.bundle", ofType: nil)! as NSString

class ZYEmoticonGroup: NSObject {
    /*
     emoticons.plist
     |---version（number）
     |---packages[dic]
     |---dic:id(对应文件夹的名字)
     
     
     **[modles] [模型字典] 一个id对应一个组模型
     
     
     找到对应文件夹中的info.plist文件
     
     **3个组模型
     
     新浪表情&浪小花  dic
     id文件夹的名字
     version版本号（number）
     group_name_cn
     group_name_tw
     group_name_en
     emoticons [dic]
     **表情模型
     |---dic
     |---chs
     |---cht
     |---gif
     |---png
     |---type
     
     emoji  dic
     id文件夹的名字
     version版本号
     group_name_cn
     group_name_tw
     group_name_en
     emoticons [dic]
     **表情模型
     |---dic
     |---code
     |---type
     */
    
    //单例： 防止内存问题
    static let emoticonGroups: [ZYEmoticonGroup] = ZYEmoticonGroup.loadEmoticon()
    
    var id: String?
    
    var group_name_cn: String?
    
    var group_name_tw: String?
    
    var group_name_en: String?

    var emoticonModels: [ZYEmoticonModel]? = [ZYEmoticonModel]() {
        didSet{
            
            pages = emoticonModels!.count / 20
        }
    }
    
    var pages: Int = 0
    
    class func loadEmoticon() -> [ZYEmoticonGroup]{

        let plistPath = mainPath.stringByAppendingPathComponent("emoticons.plist")
        
        let plistDic = NSDictionary(contentsOfFile: plistPath)
        
        let emoticonsArr = plistDic!["packages"] as! NSArray
        
        var tmpArr = [ZYEmoticonGroup]()
        
        //添加偏好模型
        tmpArr.append(addPreferEmoticon())
        
        for element in emoticonsArr {

            let dicPath = emoticonPlistFileFullPath(element["id"] as! String)
            
            let dic = NSDictionary(contentsOfFile: dicPath) as! [String : AnyObject]
            
            let  emoticongroup = ZYEmoticonGroup(id: element["id"] as! String)
            
            //加载表情组
            emoticongroup.group_name_cn = dic["group_name_cn"] as? String
            emoticongroup.group_name_en = dic["group_name_en"] as? String
            emoticongroup.group_name_tw = dic["group_name_tw"] as? String
            
            emoticongroup.configureEmoticonsValue(dic["emoticons"]!)
            emoticongroup.appendEmptyModelToSeizePosition()
            
            tmpArr.append(emoticongroup)
        }
        
        return tmpArr
    }
    
    init(id: String) {
        super.init()
        
        self.id = id
    }
    
    override init() {
        super.init()
    }
    
    //添加偏好模型
    private class func addPreferEmoticon() -> ZYEmoticonGroup{
        
        let emoticongroup = ZYEmoticonGroup()
        
        for _ in 0...20 {
            
            emoticongroup.emoticonModels?.append(ZYEmoticonModel())
        }
        
        //删除按钮
        emoticongroup.emoticonModels?.removeLast()
        emoticongroup.emoticonModels?.append(ZYEmoticonModel(isDelete: true))

        return emoticongroup
    }
    
    func refreshPreferEmoticonModels() {
        //数组排序
        emoticonModels = emoticonModels?.sort({ (e1, e2) -> Bool in
            e1.times > e2.times
        })
        //删除按钮
        emoticonModels?.removeLast()
        emoticonModels?.append(ZYEmoticonModel(isDelete: true))
        
    }
    
    //加载表情模型
    private func configureEmoticonsValue(dic: AnyObject) {
        
        let dicArr = dic as! [[String : AnyObject]]

        var index = 0
        for dic in dicArr {
            
            if index == 20{
                let model = ZYEmoticonModel(isDelete: true)
                emoticonModels?.append(model)
                index = 0
            }
            
            let model = ZYEmoticonModel(dictionary: dic, id: self.id!)
            
            index += 1
            
            emoticonModels?.append(model)
        }
        
        
    }
    //添加空白表情模型
    private func appendEmptyModelToSeizePosition() {
        
        //离填满一页还差多少个模型
        let count = self.emoticonModels!.count % 21
        
        //添加空白模型
        for _  in 0..<20-count {
            
            let model = ZYEmoticonModel()
            
            self.emoticonModels?.append(model)
        }
        
        self.emoticonModels?.append(ZYEmoticonModel(isDelete: true))
    }
    
    class private func emoticonPlistFileFullPath(fileFolder: String) -> String{
        
        let path = mainPath.stringByAppendingPathComponent(fileFolder) as NSString
        
        return path.stringByAppendingPathComponent("info.plist")
        
    }

}

class ZYEmoticonModel: NSObject {
    
    //表情使用的次数
    var times: Int = 0
    
    var id: String?
    
    var chs: String?
    
    var cht: String?
    
    var gif: String?
    
    var png: String? {
        didSet{
            let path = mainPath.stringByAppendingPathComponent(id!) as NSString
            
            fullPathOfPNG = path.stringByAppendingPathComponent(png!)
        }
    }
    
    var fullPathOfPNG: String?
    
    var isDeleteBtn: Bool = false
    
    var type: String?
    
    //emoji
    var code: String? {
        didSet{
            //1 创建扫描器
            let scaner = NSScanner(string: code!)
            //2 扫描十六进制
            // UnsafeMutablePointer<UInt32> -> 传入可变指针
            var result: UInt32 = 0
            scaner.scanHexInt(&result)
            
            //3 获取Character字符
            let emoji = Character(UnicodeScalar(result))
            
            emojiCode = "\(emoji)"
        }
    }
    
    var emojiCode: String?
    
    
    override init() {
        super.init()
    }
    
    init(isDelete: Bool) {
        super.init()
        
        isDeleteBtn = isDelete
    }
    
    init(dictionary : [String : AnyObject], id: String) {
        
        super.init()
        
        self.id = id
        
        setValuesForKeysWithDictionary(dictionary)
    }
    
    override func setValue(value: AnyObject?, forUndefinedKey key: String) {}
}

