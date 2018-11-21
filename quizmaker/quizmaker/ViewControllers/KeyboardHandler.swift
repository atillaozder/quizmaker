//
//  KeyboardHandler.swift
//  QuizApp
//
//  Created by Atilla Özder on 12.11.2018.
//  Copyright © 2018 Atilla Özder. All rights reserved.
//

import UIKit

protocol KeyboardHandler {
    var scrollView: UIScrollView { get }
    var contentView: UIView { get }
    
    func setupViews()
    func addObservers()
    func removeObservers()
    
    func keyboardWillShow(notification: Notification)
    func keyboardWillHide(notification: Notification)
    
    func updateContent()
}

extension KeyboardHandler where Self: UIViewController {
    
    func setupViews() {
        view.addSubview(scrollView)
        scrollView.fillSafeArea()
        scrollView.addSubview(contentView)
        contentView.fillSafeArea()
        contentView.setCenter()
        scrollView.isScrollEnabled = true
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil) { [weak self] (notification) in
            guard let strongSelf = self else { return }
            strongSelf.keyboardWillShow(notification: notification)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil) { [weak self] (notification) in
            guard let strongSelf = self else { return }
            strongSelf.keyboardWillHide(notification: notification)
        }
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
    
    func keyboardWillShow(notification: Notification) {
        //        guard let userInfo = notification.userInfo,
        //            let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
        //                return
        //        }
        //
        //        var contentInset: UIEdgeInsets = .zero
        //        contentInset.bottom = frame.size.height
        //        scrollView.contentInset = contentInset
        //        scrollView.scrollIndicatorInsets = contentInset
        
        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)
        
        let animationDuration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.additionalSafeAreaInsets.bottom = intersection.height
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func keyboardWillHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
                return
        }
        
        let keyboardFrameInView = view.convert(keyboardFrame, from: nil)
        let safeAreaFrame = view.safeAreaLayoutGuide.layoutFrame.insetBy(dx: 0, dy: -additionalSafeAreaInsets.bottom)
        let intersection = safeAreaFrame.intersection(keyboardFrameInView)
        
        let animationDuration: TimeInterval = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawNSN = notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
        let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        let animationCurve = UIView.AnimationOptions(rawValue: animationCurveRaw)
        
        UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: {
            self.additionalSafeAreaInsets.bottom = intersection.height
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func updateContent() {
        var contentRect = CGRect.zero
        contentView.subviews.forEach({ contentRect = contentRect.union($0.frame) })
        contentRect.size.height += 10
        scrollView.contentSize = contentRect.size
    }
}
