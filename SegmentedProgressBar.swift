//
//  SegmentedProgressBar.swift
//  SegmentedProgressBar
//
//  Created by Dylan Marriott on 04.03.17.
//  Copyright © 2017 Dylan Marriott. All rights reserved.

import Foundation
import UIKit

protocol SegmentedProgressBarDelegate: class {
    func segmentedProgressBarChangedIndex(index: Int)
    func segmentedProgressBarFinished()
}

class SegmentedProgressBar: UIView {
    
    weak var delegate: SegmentedProgressBarDelegate?
    var topColor = UIColor.gray {
        didSet {
            self.updateColors()
        }
    }
    var bottomColor = UIColor.white.withAlphaComponent(0.1) {
        didSet {
            self.updateColors()
        }
    }
    
    var animator: UIViewPropertyAnimator!

    var padding: CGFloat = 4.0
    
    private var segments = [Segment]()
    var duration: TimeInterval
    private var hasDoneLayout = false // hacky way to prevent layouting again
    var currentAnimationIndex = 0
    
    init(numberOfSegments: Int, duration: TimeInterval = 5.0) {
        self.duration = duration
        super.init(frame: CGRect.zero)
        
        for _ in 0..<numberOfSegments {
            let segment = Segment()
            addSubview(segment.bottomSegmentView)
            addSubview(segment.topSegmentView)
            segments.append(segment)
        }
        self.updateColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if hasDoneLayout {
            return
        }
        let width = (frame.width - (padding * CGFloat(segments.count - 1)) ) / CGFloat(segments.count)
        for (index, segment) in segments.enumerated() {
            let segFrame = CGRect(x: CGFloat(index) * (width + padding), y: 0, width: width, height: frame.height)
            segment.bottomSegmentView.frame = segFrame
            segment.topSegmentView.frame = segFrame
            segment.topSegmentView.frame.size.width = 0
            
            let cr = frame.height / 2
            segment.bottomSegmentView.layer.cornerRadius = cr
            segment.topSegmentView.layer.cornerRadius = cr
        }
        hasDoneLayout = true
    }
    
    func startAnimation() {
        layoutSubviews()
        animate()
    }
    
    func animate(animationIndex: Int = 0) {
        let nextSegment = segments[animationIndex]
        currentAnimationIndex = animationIndex
        
        if self.animator != nil  && self.animator.state == .active{
            self.animator.stopAnimation(false)
            self.animator.finishAnimation(at: UIViewAnimatingPosition.current)
            self.animator = nil
        }
        animator = UIViewPropertyAnimator(duration: duration, curve: .easeInOut) { [weak self] in
            guard let _ = self else {return}
            nextSegment.topSegmentView.frame.size.width = nextSegment.bottomSegmentView.frame.width
        }
        
        animator.addCompletion { (postion) in
            if postion == UIViewAnimatingPosition.end{
                self.next()
            }
        }

    }
    
    func pauseAnimation(){
        if self.animator == nil{
            return
        }
        self.animator.pauseAnimation()
    }
    
    func resumeAnimation(){
        if self.animator == nil{
            return
        }
        self.animator.startAnimation()
    }
    
    private func updateColors() {
        for segment in segments {
            segment.topSegmentView.backgroundColor = topColor
            segment.bottomSegmentView.backgroundColor = bottomColor
        }
    }
    
    private func next() {
        self.cancelAnimation()
        let newIndex = self.currentAnimationIndex + 1
        if newIndex < self.segments.count {
            self.delegate?.segmentedProgressBarChangedIndex(index: newIndex)
            self.animate(animationIndex: newIndex)
        } else {
            self.delegate?.segmentedProgressBarFinished()
        }
    }
    
    func skip() {
        self.cancelAnimation()
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.frame.size.width = currentSegment.bottomSegmentView.frame.width
        currentSegment.topSegmentView.layer.removeAllAnimations()
        self.next()
    }
    
    func rewind() {
        self.cancelAnimation()
        let currentSegment = segments[currentAnimationIndex]
        currentSegment.topSegmentView.layer.removeAllAnimations()
        currentSegment.topSegmentView.frame.size.width = 0
        let newIndex = max(currentAnimationIndex - 1, 0)
        let prevSegment = segments[newIndex]
        prevSegment.topSegmentView.frame.size.width = 0
        self.delegate?.segmentedProgressBarChangedIndex(index: newIndex)
        self.animate(animationIndex: newIndex)
    }
    
    func cancel() {
        self.cancelAnimation()
        for segment in segments {
            segment.topSegmentView.layer.removeAllAnimations()
            segment.bottomSegmentView.layer.removeAllAnimations()
            segment.topSegmentView.backgroundColor = self.bottomColor
            segment.bottomSegmentView.backgroundColor = self.bottomColor
        }
    }
    
    func cancelAnimation(){
        if self.animator != nil && self.animator.state == .active{
            self.animator.stopAnimation(false)
            self.animator.finishAnimation(at: UIViewAnimatingPosition.current)
            self.animator = nil
        }
    }
}

fileprivate class Segment {
    let bottomSegmentView = UIView()
    let topSegmentView = UIView()
    init() {
    }
}
