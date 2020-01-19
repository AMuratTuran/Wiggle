//
//  UIKit + Validation.swift
//  Wiggle
//
//  Created by Murat Turan on 19.01.2020.
//  Copyright © 2020 Murat Turan. All rights reserved.
//

import UIKit
import SwiftValidator


extension Validatable where Self: ValidatableField {

    @discardableResult
    func addValidationRules(_ rules: [Rule], errorLabel: UILabel? = nil, validator: Validator = Validator()) -> Validator {
        if let errorLabel = errorLabel {
            validator.registerField(self, errorLabel: errorLabel, rules: rules)
        } else {
            validator.registerField(self, rules: rules)
        }

        return validator
    }

    func removeValidationRules(validator: Validator = Validator()) {
        validator.unregisterField(self)
    }
}

extension CGRect {
    func isBefore(_ frame: CGRect) -> Bool {
        if self.origin.y < frame.origin.y {
            return true
        } else if self.origin.y == frame.origin.y {
            return self.origin.x < frame.origin.x
        }
        return false
    }

    func isAfter(_ frame: CGRect) -> Bool {
        if self.origin.y > frame.origin.y {
            return true
        } else if self.origin.y == frame.origin.y {
            return self.origin.x > frame.origin.x
        }
        return false
    }
}


protocol NextViewIterable {
    func isActive() -> Bool
}


extension UIView {

    func nextIterableView(_ recursive: Bool = true, inView: UIView?) -> NextViewIterable? {
        guard let inView = (inView ?? self.superview), self.isDescendant(of: inView) else {
            return nil
        }

        let views = inView.iterableSubviews(recursive)
        let frameRelativeToInView = self.relativeFrame(inView)!
        let sortedViews = views.filter {
            if let view = $0 as? UIView {
                if let textField = view as? UITextField {
                    if textField.isEnabled && textField.isUserInteractionEnabled {
                        return view.relativeFrame(inView)!.isAfter(frameRelativeToInView)
                    }
                } else {
                    if view.isUserInteractionEnabled {
                        return view.relativeFrame(inView)!.isAfter(frameRelativeToInView)
                    }
                }
            }
            return false
        }.sorted {
            if let view1 = $0 as? UIView, let view2 = $1 as? UIView {
                return view1.relativeFrame(inView)!.isBefore(view2.relativeFrame(inView)!)
            }
            return false
        }
        return sortedViews.first
    }

    func prevIterableView(_ recursive: Bool = true, inView: UIView?) -> NextViewIterable? {
        guard let inView = (inView ?? self.superview), self.isDescendant(of: inView) else {
            return nil
        }

        let views = inView.iterableSubviews(recursive)
        let frameRelativeToInView = self.relativeFrame(inView)!
        let sortedViews = views.filter {
            if let view = $0 as? UIView {
                if let textField = view as? UITextField {
                    if textField.isEnabled && textField.isUserInteractionEnabled {
                        return view.relativeFrame(inView)!.isBefore(frameRelativeToInView)
                    }
                } else {
                    if view.isUserInteractionEnabled {
                        return view.relativeFrame(inView)!.isBefore(frameRelativeToInView)
                    }
                }
            }
            return false
        }.sorted {
            if let view1 = $0 as? UIView, let view2 = $1 as? UIView {
                return view1.relativeFrame(inView)!.isAfter(view2.relativeFrame(inView)!)
            }
            return false
        }
        return sortedViews.first
    }

    // Returns all subviews of a certain type. Optinally recursive.
    // INFORMATION: UISearchBar ın içinde UISearchBarTextField elementi bulunduğundan dolayı böyle bir kontrol yapıldı.
    func iterableSubviews(_ recursive: Bool = true) -> [NextViewIterable] {
        var array: [NextViewIterable] = []
        for subview in self.subviews {
            if let subview = subview as? NextViewIterable, subview.isActive() {
                array.append(subview)
            }
            if recursive && !(subview is UISearchBar) {
                array.append(contentsOf: subview.iterableSubviews())
            }
        }
        return array
    }

    // Returns all subviews of a certain type. Optinally recursive.
    func subviews<T: UIView>(_ ofType: T.Type, recursive: Bool = true) -> [T] {
        var array: [T] = []
        for subview in self.subviews {
            if let subview = subview as? T {
                array.append(subview)
            }
            if recursive {
                array.append(contentsOf: subview.subviews(ofType))
            }
        }
        return array
    }

    // Return next view of a type in a superview. If self isn't inside inView, returns nil.
    func nextView<T: UIView>(_ ofType: T.Type, recursive: Bool = true, inView: UIView?) -> T? {
        guard let inView = (inView ?? self.superview), self.isDescendant(of: inView) else {
            return nil
        }

        let views = inView.subviews(ofType, recursive: recursive)
        let frameRelativeToInView = self.relativeFrame(inView)!
        let sortedViews = views.filter {
            $0.relativeFrame(inView)!.origin.y > frameRelativeToInView.origin.y
        }.sorted {
            $0.relativeFrame(inView)!.origin.y < $1.relativeFrame(inView)!.origin.y
        }
        return sortedViews.first
    }

    // Return previous view of a type in a superview. If self isn't inside inView, returns nil.
    func previousView<T: UIView>(_ ofType: T.Type, recursive: Bool = true, inView: UIView?) -> T? {
        guard let inView = (inView ?? self.superview), self.isDescendant(of: inView) else {
            return nil
        }

        let views = inView.subviews(ofType, recursive: recursive)
        let frameRelativeToInView = self.relativeFrame(inView)!
        let sortedViews = views.filter {
            $0.relativeFrame(inView)!.origin.y < frameRelativeToInView.origin.y
        }.sorted {
            $0.relativeFrame(inView)!.origin.y > $1.relativeFrame(inView)!.origin.y
        }
        return sortedViews.first
    }

    func relativeFrame(_ relativeTo: UIView) -> CGRect? {
        return self.convert(self.bounds, to: relativeTo)
    }
}
