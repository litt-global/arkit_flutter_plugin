import Foundation
import ARKit

func getImageByName(_ name: String) -> UIImage? {
    if let img = UIImage(named: name) {
        return img
    }
    if let path = Bundle.main.path(forResource: SwiftArkitPlugin.registrar!.lookupKey(forAsset: name), ofType: nil) {
        return UIImage(named: path)
    }
    if let url = URL.init(string: name) {
      do {
        let data = try Data.init(contentsOf: url)
        return UIImage(data: data)
      } catch {
          
      }
    }
    if let base64 = Data(base64Encoded: name, options: .ignoreUnknownCharacters) {
        return UIImage(data: base64)
    }
    return nil
}

func getGifByName(_ name: String) -> CALayer {
    let gifImage = UIImage.gifImageWithURL(name)
    let gifImageView = UIImageView(image: gifImage)
    return gifImageView.layer
}

func getVideoByName(_ name: String, _ chromaColor: Int?) -> SKScene {
    let asset = AVURLAsset(url: URL(string: name)!)
    let naturalSize = asset.tracks(withMediaType: AVMediaType.video)[0].naturalSize
    let transform = asset.tracks(withMediaType: AVMediaType.video)[0].preferredTransform
    let videoAngleInDegree = atan2(transform.b, transform.a) * 180 / .pi
    
    var size = naturalSize
    if (videoAngleInDegree == 90 || videoAngleInDegree == 270) {
        size = CGSize(width: naturalSize.height, height: naturalSize.width)
    }
    
    let player = AVPlayer(playerItem: AVPlayerItem(asset: asset))

    // loop the video
    _ = VideoLooper(player)
    
    // setup the video SKVideoNode
    let videoNode = SKVideoNode(avPlayer: player)
    videoNode.size = size
    videoNode.position = CGPoint(x: naturalSize.width * 0.5, y: naturalSize.height * 0.5)
    videoNode.zRotation = CGFloat(-videoAngleInDegree) * .pi / 180
    
    // chroma
    var effectNode: SKEffectNode? = nil
    if (chromaColor != nil) {
        effectNode = SKEffectNode()
        effectNode?.filter = colorCubeFilterForChromaKey(hueAngle: 114)
        effectNode?.addChild(videoNode)
    }
    
    // setup the SKScene that will house the node
    let videoScene = SKScene(size: naturalSize)
    videoScene.backgroundColor = UIColor.clear
    videoScene.scaleMode = .aspectFit
    videoScene.addChild(effectNode ?? videoNode)
    
    // play video
    player.play()
    videoNode.play()
    
    return videoScene
}

class VideoLooper {
    var playerObserver: Any?
    
    init(_ player: AVPlayer) {
        player.actionAtItemEnd = .none

        playerObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
            object: player.currentItem,
            queue: nil) { notification in
                if let playerItem: AVPlayerItem = notification.object as? AVPlayerItem {
                    playerItem.seek(to: CMTime.zero, completionHandler: nil)
                }
            }
    }
}

func colorCubeFilterForChromaKey(hueAngle: Float) -> CIFilter {
    let size = 64
    var cubeData = [Float](repeating: 0, count: size * size * size * 4)
    var rgb: [Float] = [0, 0, 0]
    var offset = 0

    for z in 0 ..< size {
        rgb[2] = Float(z) / Float(size) // blue value
        for y in 0 ..< size {
            rgb[1] = Float(y) / Float(size) // green value
            for x in 0 ..< size {
                rgb[0] = Float(x) / Float(size) // red value
                
                let r: [Float] = removeChromaKeyColor(r: rgb[0], g: rgb[1], b: rgb[2])
                
                cubeData[offset] = r[0]
                cubeData[offset + 1] = r[1]
                cubeData[offset + 2] = r[2]
                cubeData[offset + 3] = r[3]
                offset += 4
            }
        }
    }
    let b = cubeData.withUnsafeBufferPointer { Data(buffer: $0) }
    let data = b as NSData

    let colorCube = CIFilter(name: "CIColorCube", parameters: [
        "inputCubeDimension": size,
        "inputCubeData": data
        ])
    return colorCube!
}

func removeChromaKeyColor(r: Float, g: Float, b: Float) -> [Float] {
    let threshold: Float = 0.1
    let refColor: [Float] = [0, 1.0, 0, 1.0]    // chroma key color

    //http://www.shaderslab.com/demo-40---video-in-video-with-green-chromakey.html
    let val = ceil(saturate(g - r - threshold)) * ceil(saturate(g - b - threshold))
    var result = lerp(a: [r, g, b, 0.0], b: refColor, w: val)
    result[3] = abs(1.0 - result[3])

    return result
}

func saturate(_ x: Float) -> Float {
    return max(0, min(1, x));
}

func ceil(_ v: Float) -> Float {
    return -floor(-v);
}

func lerp(a: [Float], b: [Float], w: Float) -> [Float] {
    return [a[0]+w*(b[0]-a[0]), a[1]+w*(b[1]-a[1]), a[2]+w*(b[2]-a[2]), a[3]+w*(b[3]-a[3])];
}

//
//  iOSDevCenters+GIF.swift
//  GIF-Swift
//
//  Created by iOSDevCenters on 11/12/15.
//  Copyright © 2016 iOSDevCenters. All rights reserved.
//
import UIKit
import ImageIO

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

extension UIImage {
    
    public class func gifImageWithData(_ data: Data) -> UIImage? {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            print("image doesn't exist")
            return nil
        }
        
        return UIImage.animatedImageWithSource(source)
    }
    
public class func gifImageWithURL(_ gifUrl:String) -> UIImage? {
        guard let bundleURL:URL? = URL(string: gifUrl)
            else {
                print("image named \"\(gifUrl)\" doesn't exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL!) else {
            print("image named \"\(gifUrl)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    public class func gifImageWithName(_ name: String) -> UIImage? {
        guard let bundleURL = Bundle.main
            .url(forResource: name, withExtension: "gif") else {
                print("SwiftGif: This image named \"\(name)\" does not exist")
                return nil
        }
        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("SwiftGif: Cannot turn image named \"\(name)\" into NSData")
            return nil
        }
        
        return gifImageWithData(imageData)
    }
    
    class func delayForImageAtIndex(_ index: Int, source: CGImageSource!) -> Double {
        var delay = 0.1
        
        let cfProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil)
        let gifProperties: CFDictionary = unsafeBitCast(
            CFDictionaryGetValue(cfProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDictionary).toOpaque()),
            to: CFDictionary.self)
        
        var delayObject: AnyObject = unsafeBitCast(
            CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFUnclampedDelayTime).toOpaque()),
            to: AnyObject.self)
        if delayObject.doubleValue == 0 {
            delayObject = unsafeBitCast(CFDictionaryGetValue(gifProperties,
                Unmanaged.passUnretained(kCGImagePropertyGIFDelayTime).toOpaque()), to: AnyObject.self)
        }
        
        delay = delayObject as! Double
        
        if delay < 0.1 {
            delay = 0.1
        }
        
        return delay
    }
    
    class func gcdForPair(_ a: Int?, _ b: Int?) -> Int {
        var a = a
        var b = b
        if b == nil || a == nil {
            if b != nil {
                return b!
            } else if a != nil {
                return a!
            } else {
                return 0
            }
        }
        
        if a < b {
            let c = a
            a = b
            b = c
        }
        
        var rest: Int
        while true {
            rest = a! % b!
            
            if rest == 0 {
                return b!
            } else {
                a = b
                b = rest
            }
        }
    }
    
    class func gcdForArray(_ array: Array<Int>) -> Int {
        if array.isEmpty {
            return 1
        }
        
        var gcd = array[0]
        
        for val in array {
            gcd = UIImage.gcdForPair(val, gcd)
        }
        
        return gcd
    }
    
    class func animatedImageWithSource(_ source: CGImageSource) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        var images = [CGImage]()
        var delays = [Int]()
        
        for i in 0..<count {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(image)
            }
            
            let delaySeconds = UIImage.delayForImageAtIndex(Int(i),
                source: source)
            delays.append(Int(delaySeconds * 1000.0)) // Seconds to ms
        }
        
        let duration: Int = {
            var sum = 0
            
            for val: Int in delays {
                sum += val
            }
            
            return sum
        }()
        
        let gcd = gcdForArray(delays)
        var frames = [UIImage]()
        
        var frame: UIImage
        var frameCount: Int
        for i in 0..<count {
            frame = UIImage(cgImage: images[Int(i)])
            frameCount = Int(delays[Int(i)] / gcd)
            
            for _ in 0..<frameCount {
                frames.append(frame)
            }
        }
        
        let animation = UIImage.animatedImage(with: frames,
            duration: Double(duration) / 1000.0)
        
        return animation
    }
}
