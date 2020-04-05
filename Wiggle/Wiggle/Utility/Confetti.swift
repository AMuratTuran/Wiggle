//
//  Confetti.swift
//  Wiggle
//
//  Created by Murat Turan on 5.04.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit

enum ConfettiColors {
    static let white = UIColor.white
    static let gold = UIColor.goldenColor
}

enum ConfettiImages {
    static let confetti1 = UIImage(named: "confetti1") ?? UIImage()
    static let confetti2 = UIImage(named: "confetti2") ?? UIImage()
    static let confetti3 = UIImage(named: "confetti3") ?? UIImage()
    static let confetti4 = UIImage(named: "confetti4") ?? UIImage()
}

class Confetti {
    
    static private var colors:[UIColor] = [ConfettiColors.white, ConfettiColors.gold]
    static private var images: [UIImage] = [ConfettiImages.confetti1, ConfettiImages.confetti2, ConfettiImages.confetti3, ConfettiImages.confetti4]
    static private var velocities: [Int] = [60, 55, 85, 110]
    
    static func prepare(width: CGFloat) -> CAEmitterLayer {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: width / 2, y: -10)
        emitter.emitterShape = CAEmitterLayerEmitterShape.line
        emitter.emitterSize = CGSize(width: width, height: 2.0)
        emitter.emitterCells = generateEmitterCells()
        
        return emitter
    }
    
    static private func generateEmitterCells() -> [CAEmitterCell] {
        var cells:[CAEmitterCell] = [CAEmitterCell]()
        for index in 0..<16 {
            
            let cell = CAEmitterCell()
            
            cell.birthRate = 3.0
            cell.lifetime = 14.0
            cell.lifetimeRange = 0
            cell.velocity = CGFloat(getRandomVelocity())
            cell.velocityRange = 0
            cell.emissionLongitude = CGFloat(Double.pi)
            cell.emissionRange = 0.5
            cell.spin = 3.5
            cell.spinRange = 0
            cell.color = getNextColor(i: index)
            cell.contents = getNextImage(i: index)
            cell.scaleRange = 0.25
            cell.scale = 0.2
            
            cells.append(cell)
            
        }
        
        return cells
    }
    
    static private func getRandomVelocity() -> Int {
        return velocities[getRandomNumber()]
    }
    
    static private func getRandomNumber() -> Int {
        return Int(arc4random_uniform(4))
    }
    
    static private func getNextColor(i: Int) -> CGColor {
        if i <= 4 {
            return colors[0].cgColor
        } else {
            return colors[1].cgColor
        }
    }
    
    static private func getNextImage(i:Int) -> CGImage {
        return images[i % 4].cgImage!
    }
    
}


