//
//  FriendView.swift
//  Secret
//
//  Created by Daisuke Sugimoto on 2017/11/05.
//  Copyright © 2017年 Daisuke Sugimoto. All rights reserved.
//

import UIKit

protocol FriendViewDelegate: class {
    func closeDidTap(messageCount:Int)
    func unlinkDidTap()
    func emailDidTap()
    func messageWillCompose()
    func muteDidTap()
    func phoneDidTap()
    func receiveMessageDidTap(message:Message)
    func sendDidTap(message:String)
}

class FriendView: AbstractView {
    
    @IBOutlet fileprivate weak var _closeButton: UIButton!
    @IBOutlet weak var _deleteButton: UIButton!
    @IBOutlet weak var _muteButton: UIButton!
    //Header
    @IBOutlet fileprivate weak var _headerView: UIView!
    @IBOutlet fileprivate weak var _thumbnail: UIImageView!
    @IBOutlet fileprivate weak var _nameLabel: UILabel!
    @IBOutlet fileprivate weak var _phoneButton: UIButton!
    @IBOutlet fileprivate weak var _phoneButtonWidth: NSLayoutConstraint!
    @IBOutlet fileprivate weak var _emailButton: UIButton!
    @IBOutlet fileprivate weak var _emailButtonWidth: NSLayoutConstraint!
    //Inbox
    @IBOutlet fileprivate weak var _inboxView: UIView!
    @IBOutlet fileprivate weak var _inboxTableView: UITableView!
    @IBOutlet fileprivate weak var _noMessagesLabel: UILabel!
    //Outbox
    @IBOutlet fileprivate weak var _outboxView: UIView!
    @IBOutlet fileprivate weak var _outboxTableView: UITableView!
    @IBOutlet fileprivate weak var _outboxViewHeight: NSLayoutConstraint!
    //Compose
    @IBOutlet fileprivate weak var _composeView: UIView!
    @IBOutlet fileprivate weak var _composeViewHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var _textView: UITextView!

    @IBOutlet fileprivate weak var _sendButton: UIButton!
    @IBOutlet fileprivate weak var _annotationView: UIView!

    fileprivate var _inbox: Array<Message> = [Message]()
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
                    _outboxViewHeight.constant = _inboxView.frame.height/2
                }
            }
        }
    }
    
    fileprivate var _sendMessages: Array<String> = [String]()
    weak var delegate: FriendViewDelegate?
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    override func setup() {
        super.setup()
        _textView.delegate = self
        self.configureTable()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if _textView.isFirstResponder {
            _textView.resignFirstResponder()
        } else {
            self.delegate?.closeDidTap(messageCount: _inbox.count)
        }
    }

    private func configureTable() {
        _inboxTableView.delegate = self
        _inboxTableView.dataSource = self
        _inboxTableView.registerCells(types: [FriendMessageCell.self])
        _inboxTableView.setBlurEffect()
        
        _outboxTableView.delegate = self
        _outboxTableView.dataSource = self
        _outboxTableView.registerCells(types: [SentMessageCell.self])
        _outboxTableView.setBlurEffect()
        _outboxTableView.rowHeight = UITableViewAutomaticDimension
        _outboxView.isHidden = true
        _outboxViewHeight.constant = 0
    }
    
    func setFriend(friend:Friend) {
        if let url = friend.account!.imageURL() {
            _thumbnail.contentMode = .scaleAspectFill
            _thumbnail.af_setImage(withURL: url)
        }
        
        _nameLabel.text = friend.account!.name
        if friend.account!.email.isEmpty {
            _emailButton.isHidden = true
            _emailButtonWidth.constant = 0.0
        }
        
        if friend.account!.phone.isEmpty {
            _phoneButton.isHidden = true
            _phoneButtonWidth.constant = 0.0
        }
        self.setMuteButton(friend.isMuted)
    }
    
    func setMuteButton(_ isMuted: Bool) {
        var color = UIColor.Palette.green.color()
        if isMuted {
            color = UIColor.Palette.gray.color()
            _muteButton.setTitle("OFF", for: .normal)
        } else {
            _muteButton.setTitle("ON", for: .normal)
        }
        _muteButton.tintColor = color
        _muteButton.setTitleColor(color, for: .normal)
    }
    
    func setInbox(with messages:Array<Message>) {
        _inbox = messages
        _inboxTableView.reloadData()
        _noMessagesLabel.isHidden = _inbox.count > 0
    }
    
    func removeMessage(message:Message){
        if let row = _inbox.index(of: message) {
            _inbox.remove(at: row)
            _inboxTableView.deleteRows(at: [IndexPath(row:row,section:0)], with: .automatic)
        }
        _noMessagesLabel.isHidden = _inbox.count > 0
    }
    
    func addOutBox(with message:Message) {
        _outbox.append(message)
        _outboxTableView.reloadData()        
        _outboxTableView.scrollToRow(at: IndexPath(row:_outbox.count-1, section:0), at: .top, animated: true)
        
    }
    
    func clearSendMessageText(){
        _textView.text = nil
        _composeViewHeight.constant = 50.5
        self.enableSendButton(false)
        if _textView.isFirstResponder {
            _textView.resignFirstResponder()
        }
    }
    
    func showAnnotationView() {
        _annotationView.isHidden = false
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?._annotationView.alpha = 1.0
        }, completion: {completed in
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC),execute: {
                UIView.animate(withDuration: 0.5, animations: { [weak self] in
                    self?._annotationView.alpha = 0.0
                }, completion: { [weak self] completed in
                    self?._annotationView.isHidden = true
                })
            })
        })

    }
    
    func canSend() -> Bool {
        return _textView.text.count > 0
    }
    
    func enableSendButton(_ enabled:Bool){
        _sendButton.isUserInteractionEnabled = enabled
        if enabled {
            _sendButton.backgroundColor = UIColor.uiTint
        } else {
            _sendButton.backgroundColor = UIColor.uiLight
        }
    }

    @IBAction func _deleteButtonDidTap(_ sender: Any) {
        self.delegate?.unlinkDidTap()
    }
    
    @IBAction func _muteButtonDidTap(_ sender: Any) {
        self.delegate?.muteDidTap()
    }
    
    @IBAction func closeButtonDidTap(_ sender: Any) {
        self.delegate?.closeDidTap(messageCount: _inbox.count)
    }

    @IBAction func sendButtonDidTap(_ sender: Any) {
        self.delegate?.sendDidTap(message: _textView.text!)
    }
    
    @IBAction func phoneButtonDidTap(_ sender: Any) {
        self.delegate?.phoneDidTap()
    }
    
    @IBAction func emailButtonDidTap(_ sender: Any) {
        self.delegate?.emailDidTap()
    }
}

extension FriendView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == _inboxTableView {
            let message = _inbox[indexPath.row]
            self.delegate?.receiveMessageDidTap(message: message)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNormalMagnitude
    }

}

extension FriendView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == _inboxTableView {
            return _inbox.count
        } else if tableView == _outboxTableView {
            return _outbox.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == _outboxTableView {
            let cell = tableView.dequeueCell(type: SentMessageCell.self, indexPath: indexPath)
            cell.configure(with: _outbox[indexPath.row])
            return cell
        }
        let cell = tableView.dequeueCell(type: FriendMessageCell.self, indexPath: indexPath)
        cell.configure(with: _inbox[indexPath.row])
        return cell
    }
}


extension FriendView: UITextViewDelegate{
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.messageWillCompose()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        guard let lineHeight = _textView.font?.pointSize else {
            return
        }
        let minHeight:CGFloat = lineHeight + 32.0
        let maxHeight:CGFloat = lineHeight*3 + 32.0
        
        let size = textView.sizeThatFits(textView.frame.size)
        if(_textView.frame.size.height < maxHeight || size.height < maxHeight){
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
