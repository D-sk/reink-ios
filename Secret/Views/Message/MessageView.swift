//
//  MessageView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/11/05.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol MessageViewDelegate: class {
    func closeDidTap()
    func sendDidTap(message:String)
}

class MessageView: AbstractView {

    @IBOutlet weak var _messageView: UIView!
    @IBOutlet weak var _thumbnail: UIImageView!
    @IBOutlet weak var _bodyView: UITextView!
    @IBOutlet weak var _bodyViewHeight: NSLayoutConstraint!
    @IBOutlet weak var _closeButton: UIButton!
    // Outbox
    @IBOutlet fileprivate weak var _outboxView: UIView!
    @IBOutlet weak var _outboxViewHeight: NSLayoutConstraint!
    @IBOutlet weak var _outboxTableView: UITableView!
    // Compose
    @IBOutlet weak var _composeView: UIView!
    @IBOutlet weak var _composeViewHeight: NSLayoutConstraint!
    @IBOutlet weak var _composeTextView: UITextView!
    @IBOutlet weak var _sendButton: UIButton!
    // Annotation
    @IBOutlet weak var _annotationView: UIView!
    
    weak var delegate: MessageViewDelegate?
    
    fileprivate var _outbox: Array<Message> = [Message]() {
        didSet {
            if _outbox.count == 0 {
                if _outboxView.isHidden == false {
                    _outboxView.isHidden = true
                    _outboxViewHeight.constant = 0
                }
            } else {
                if _outboxView.isHidden {
                    _outboxView.isHidden = false
                    _outboxViewHeight.constant = _messageView.frame.height/2
                }
            }
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func setup() {
        super.setup()
        _composeTextView.delegate = self
        _outboxTableView.delegate = self
        _outboxTableView.dataSource = self
        _outboxTableView.registerCells(types: [SentMessageCell.self])
        _outboxTableView.setBlurEffect()
        _outboxTableView.rowHeight = UITableViewAutomaticDimension
        _outboxView.isHidden = true
        _outboxViewHeight.constant = 0
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if _composeTextView.isFirstResponder {
            _composeTextView.resignFirstResponder()
        } else {
            self.delegate?.closeDidTap()
        }
    }
    
    func setMessage(with message:String) {
        _bodyView.text = message
        let size = _bodyView.sizeThatFits(_bodyView.frame.size)
        if size.height <= _messageView.frame.height {
            if size.height < _thumbnail.frame.height {
                _bodyViewHeight.constant = _thumbnail.frame.height
            } else {
                _bodyViewHeight.constant = size.height
            }
            _bodyView.isScrollEnabled = false
        } else {
            _bodyViewHeight.constant = _messageView.frame.height
            _bodyView.isScrollEnabled = true
        }
    }
    
    func setThumbnail(with url:URL?) {
        guard let url = url else {
            _thumbnail.contentMode = .scaleAspectFit
            _thumbnail.image = #imageLiteral(resourceName: "ProfileThumbnail")
            return
        }
        _thumbnail.contentMode = .scaleAspectFill
        _thumbnail.af_setImage(withURL: url)
    }
    
    func addOutBox(with message:Message) {
        _outbox.append(message)
        _outboxTableView.reloadData()
        _outboxTableView.scrollToRow(at: IndexPath(row:_outbox.count-1, section:0), at: .top, animated: true)
        
    }

    @IBAction func sendButtonDidTap(_ sender: Any) {
        self.delegate?.sendDidTap(message: _composeTextView.text!)
    }
    
    @IBAction func closeButtonDidTap(_ sender: Any) {
        delegate?.closeDidTap()
    }
}

extension MessageView {
    func clearSendMessageText(){
        _composeTextView.text = nil
        self.enableSendButton(false)
        if _composeTextView.isFirstResponder {
            _composeTextView.resignFirstResponder()
        }
    }
    
    func showAnnotationView() {
        _annotationView.isHidden = false
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?._annotationView.alpha = 1.0
        }, completion: {completed in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: { [weak self] in
                UIView.animate(withDuration: 0.5, animations: {
                    self?._annotationView.alpha = 0.0
                }, completion: { [weak self] _ in
                    self?._annotationView.isHidden = true
                })
            })
        })
    }
    
    func canSend() -> Bool {
        return _composeTextView.text.count > 0
    }
    
    func enableSendButton(_ enabled:Bool){
        _sendButton.isUserInteractionEnabled = enabled
        if enabled {
            _sendButton.backgroundColor = UIColor.uiTint
        } else {
            _sendButton.backgroundColor = UIColor.uiLight
        }
    }
}

extension MessageView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _outbox.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(type: SentMessageCell.self, indexPath: indexPath)
        cell.configure(with: _outbox[indexPath.row], isInverse: true)
        return cell
    }
        
}

extension MessageView: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }
    
}
extension MessageView: UITextViewDelegate{
    
    func textViewDidChange(_ textView: UITextView) {
        guard let lineHeight = _composeTextView.font?.pointSize else {
            return
        }
        let minHeight:CGFloat = lineHeight + 32.0
        let maxHeight:CGFloat = lineHeight*3 + 32.0
        
        let size = textView.sizeThatFits(textView.frame.size)
        if(_composeTextView.frame.size.height < maxHeight || size.height < maxHeight){
            if size.height < minHeight{
                _composeViewHeight.constant = minHeight
            }else if size.height < maxHeight {
                _composeViewHeight.constant = size.height
            } else {
                _composeViewHeight.constant = maxHeight
            }
        }
        
        self.enableSendButton(self.canSend())
    }    
    
}


