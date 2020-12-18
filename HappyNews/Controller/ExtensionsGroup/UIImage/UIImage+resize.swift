//
//  UIImage+resize.swift
//  HappyNews
//
//  Created by 佐々木　謙 on 2020/12/18.
//  Copyright © 2020 佐々木　謙. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    //比率を保持してリサイズ
    func resize(_size: CGSize) -> UIImage {
        let widthRatio = _size.width / self.size.width
        let heightRatio = _size.height / self.size.height
        let ratio = (widthRatio < heightRatio) ? widthRatio : heightRatio
        let resizedSize = CGSize(width: (self.size.width * ratio), height: (self.size.height * ratio))
        UIGraphicsBeginImageContextWithOptions(_size, false, 0.0)
        draw(in: CGRect(x: (_size.width - resizedSize.width) / 2, y: (_size.height - resizedSize.height) / 2, width: resizedSize.width, height: resizedSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? self;
    }
    //比率を無視してリサイズ
    func reSizeImage(reSize:CGSize)->UIImage {
        UIGraphicsBeginImageContextWithOptions(reSize,false,UIScreen.main.scale);
        self.draw(in: CGRect(x: 0, y: 0, width: reSize.width, height: reSize.height));
        let reSizeImage:UIImage! = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return reSizeImage;
    }
    //トリミング
    func trim(trimmingArea: CGRect) -> UIImage {
        let imgRef = self.cgImage?.cropping(to: trimmingArea)
        let trimImage = UIImage(cgImage: imgRef!, scale: self.scale, orientation: self.imageOrientation)
        return trimImage
    }
}
