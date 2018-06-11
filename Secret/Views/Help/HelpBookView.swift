//
//  HelpBookView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2018/02/11.
//  Copyright © 2018年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol HelpBookViewDelegate: class {
    func backDidTap()
    func closeDidTap()
}

class HelpBookView: AbstractView {
    
    @IBOutlet weak var _scrollView: UIScrollView!
    @IBOutlet weak var _closeButton: UIButton!
    @IBOutlet weak var _backButton: UIButton!
    @IBOutlet weak var _pageControl: UIPageControl!

    weak var delegate: HelpBookViewDelegate?
    
    override func setup() {
        super.setup()
        _scrollView.delegate = self
    }

    func setBook(as book:HelpBook) {
        for v in _scrollView.subviews {
            if v is HelpPageView {
                v.removeFromSuperview()
            }
        }
        
        let frame = self.bounds
        for (i, page) in book.pages().enumerated() {
            let v = HelpPageView(frame: frame)
            v.frame.origin.x = CGFloat(i) * frame.width
            v.setPage(page)
            _scrollView.addSubview(v)
        }
        _pageControl.numberOfPages = book.pages().count
        _scrollView.contentSize.width = CGFloat(_pageControl.numberOfPages) * frame.width
    }
    
    func setButton(isModal:Bool) {
        if isModal {
            _backButton.isHidden = true
        } else {
            _closeButton.isHidden = true
        }
    }
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        self.delegate?.backDidTap()
    }
    @IBAction func closeButtonDidTap(_ sender: Any) {
        self.delegate?.closeDidTap()
    }
}

extension HelpBookView: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        _pageControl.currentPage = Int(_scrollView.contentOffset.x/_scrollView.frame.size.width)
    }

}
