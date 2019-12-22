//
//  HeartbeatViewComponent.swift
//  Wiggle
//
//  Created by MUSTAFA TOLGA TAS on 22.12.2019.
//  Copyright © 2019 Murat Turan. All rights reserved.
//

import UIKit

class HeartbeatViewComponent: UIView {
            weak var componentView: UIView!
            
            public override init(frame: CGRect) {
                super.init(frame: frame)
                setup()
            }
            
            required public init(coder aDecoder: NSCoder) {
                super.init(coder: aDecoder)!
                setup()
            }
            
            public func setup() {
                componentView = loadViewFromNib()
                componentView.frame = bounds
                componentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                addSubview(componentView)
                componentDidLoad()
            }
            
            public func loadViewFromNib() -> UIView {
                let bundle = Bundle(for: type(of: self))
                let xib = String("HeartbeatView")
                let nib = UINib(nibName: xib, bundle: bundle)
                guard let view = nib.instantiate(withOwner: self, options: nil)[0] as? UIView else { fatalError() }

                return view
            }
            
            public func componentDidLoad() { }
}
