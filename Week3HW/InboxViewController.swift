//
//  InboxViewController.swift
//  Week3HW
//
//  Created by Yi on 8/19/14.
//  Copyright (c) 2014 Dropbox. All rights reserved.
//

import UIKit

class InboxViewController: UIViewController {

    @IBOutlet weak var inboxScrollView: UIScrollView!
    @IBOutlet weak var archiveDeleteIconImageVew: UIImageView!
    @IBOutlet weak var laterListIconImageView: UIImageView!
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var inboxImageView: UIView!
    @IBOutlet weak var feedImageView: UIImageView!
    
    var messageOriPos: CGPoint!
    var archiveIconOriXPos: CGFloat!
    var laterIconOriXPos: CGFloat!
    var feedOriPos: CGPoint!
    
    @IBOutlet weak var composeView: UIView!
    @IBOutlet weak var composeImageView: UIImageView!
    @IBOutlet weak var composeToTextField: UITextField!
    
    @IBOutlet weak var archiveScrollView: UIScrollView!
    @IBOutlet weak var archiveFeedImageView: UIImageView!
    
    @IBOutlet weak var laterScrollView: UIScrollView!
    @IBOutlet weak var laterFeedImageView: UIImageView!
    
    @IBOutlet weak var rescheduleView: UIView!
    @IBOutlet weak var rescheduleImageView: UIImageView!
    
    @IBOutlet weak var mailSegControl: UISegmentedControl!
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet var screenEdgePanGestureRecognizer: UIScreenEdgePanGestureRecognizer!
    
    var canUndo: Bool!
    var prevInboxSeg: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        archiveIconOriXPos = 25
        laterIconOriXPos = 275
        inboxScrollView.contentSize = CGSize(width: inboxScrollView.frame.width, height: 37 + 1202 + 42)
        panGestureRecognizer.enabled = false
        
        var edgeGesture = UIScreenEdgePanGestureRecognizer(target: self, action: "onEdgeSwipe:")
        edgeGesture.edges = UIRectEdge.Left
        inboxImageView.addGestureRecognizer(edgeGesture)
        
        archiveScrollView.contentSize = CGSize(width: laterFeedImageView.frame.width, height: laterFeedImageView.frame.height)
        laterScrollView.contentSize = CGSize(width: laterFeedImageView.frame.width, height: laterFeedImageView.frame.height)
        archiveScrollView.frame.origin.x = 320
        laterScrollView.frame.origin.x = 320
        
        rescheduleView.hidden = true
        composeView.hidden = true
        
        canUndo = false
        
        mailSegControl.selectedSegmentIndex = 1
        prevInboxSeg = mailSegControl.selectedSegmentIndex
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onEdgeSwipe(sender: UIPanGestureRecognizer) {
        var location = sender.locationInView(view)
        var velocity = sender.velocityInView(view)
        var translation = sender.translationInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            
            feedOriPos = inboxImageView.frame.origin
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            if inboxImageView.frame.origin.x > 280 {
                inboxImageView.frame.origin.x = 280 + (translation.x - 280) / 1.5
            } else {
                inboxImageView.frame.origin.x = translation.x + feedOriPos.x
            }
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            
            if velocity.x > 100  {
                showMenu(true)
            } else if velocity.x < -100 {
                showMenu(false)
            } else if inboxImageView.frame.origin.x > 160 {
                showMenu(true)
            } else {
                showMenu(false)
            }
            
        }
    }
    
    @IBAction func toggleMenu(sender: AnyObject) {
        var shouldShow = inboxImageView.frame.origin.x == 0
        showMenu(shouldShow)
    }
    
    func showMenu(shouldShow: Bool) {
        if shouldShow {
            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: nil, animations: {
                self.inboxImageView.frame.origin.x = 280
                }, completion: {
                    (finished: Bool) in
                    self.panGestureRecognizer.enabled = true
                    
            })
        } else {
            UIView.animateWithDuration(0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: nil, animations: {
                self.inboxImageView.frame.origin.x = 0
                }, completion: {
                    (finished: Bool) in
                    self.panGestureRecognizer.enabled = false
            })
        }
    }
    
    @IBAction func onRescheduleButton(sender: AnyObject) {
        UIView.animateWithDuration(0.4, animations: {
            self.rescheduleView.alpha = 0
            }, completion: {
                (finished: Bool) in
                self.rescheduleView.hidden = false
                self.hideMessage()
        })
    }
    
    @IBAction func onPan(sender: UIPanGestureRecognizer) {
        var location = sender.locationInView(view)
        var velocity = sender.velocityInView(view)
        var translation = sender.translationInView(view)
        var gestureView = sender.view
        var x = messageImageView.frame.origin.x
        
        if sender.state == UIGestureRecognizerState.Began {
            
            messageOriPos = messageImageView.frame.origin
            
            archiveDeleteIconImageVew.frame.origin.x = archiveIconOriXPos
            laterListIconImageView.frame.origin.x = laterIconOriXPos
            
            archiveDeleteIconImageVew.image = UIImage(named: "archive_icon")
            laterListIconImageView.image = UIImage(named: "later_icon")
            
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            messageImageView.frame.origin.x = translation.x + messageOriPos.x
            messageView.backgroundColor = UIColor(red: 226/255, green: 226/255, blue: 226/255, alpha: 1)
            
            archiveDeleteIconImageVew.alpha = min(1, x/60)
            laterListIconImageView.alpha = min(1, -x/60)
            
            if x > 60 {
                
                archiveDeleteIconImageVew.frame.origin.x = translation.x + archiveIconOriXPos - 60
                if x > 260 {
                    archiveDeleteIconImageVew.image = UIImage(named: "delete_icon")
                    messageView.backgroundColor = UIColor(red: 237/255, green: 83/255, blue: 41/255, alpha: 1)
                } else {
                    archiveDeleteIconImageVew.image = UIImage(named: "archive_icon")
                    messageView.backgroundColor = UIColor(red: 108/255, green: 219/255, blue: 91/255, alpha: 1)
                }
                
            } else if x < -60 {
                
                laterListIconImageView.frame.origin.x = translation.x + laterIconOriXPos + 60
                if x < -260 {
                    laterListIconImageView.image = UIImage(named: "list_icon")
                    messageView.backgroundColor = UIColor(red: 217/255, green: 166/255, blue: 113/255, alpha: 1)
                } else {
                    laterListIconImageView.image = UIImage(named: "later_icon")
                    messageView.backgroundColor = UIColor(red: 251/255, green: 212/255, blue: 13/255, alpha: 1)
                }
            }
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            
            if x <= 60 && x >= -60 {
                UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: nil, animations: {
                    self.messageImageView.frame.origin.x = self.messageOriPos.x
                    }, completion: {
                        (finished: Bool) in
                        // something here
                })
            } else if x > 60 {
                UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: nil, animations: {
                    self.messageImageView.frame.origin.x = 320 + 60
                    self.archiveDeleteIconImageVew.frame.origin.x = 320 + self.archiveIconOriXPos
                    }, completion: {
                        (finished: Bool) in
                        self.hideMessage()
                })
            } else if x < -60 {
                UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: nil, animations: {
                    self.messageImageView.frame.origin.x = -320 - 60
                    self.laterListIconImageView.frame.origin.x = -320 - self.laterIconOriXPos
                    }, completion: {
                        (finished: Bool) in
                        // something here
                })
                if x < -260 {
                    showRescheduleOrList(false)
                } else {
                    showRescheduleOrList(true)
                }
            }
        }
    }
    
    func showRescheduleOrList(isSchedule: Bool) {
        rescheduleView.hidden = false
        rescheduleView.alpha = 0
        if isSchedule {
            rescheduleImageView.image = UIImage(named: "reschedule")
        } else {
            rescheduleImageView.image = UIImage(named: "list")
        }
        UIView.animateWithDuration(0.4, animations: {
            self.rescheduleView.alpha = 1
            }, completion: {
                (finished: Bool) in
        })
    }
    
    func hideMessage() {
        UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: nil, animations: {
            self.feedImageView.frame.origin.y = self.feedImageView.frame.origin.y - self.messageView.frame.height
            self.messageView.frame.origin.y = self.messageView.frame.origin.y - self.messageView.frame.height
            }, completion: {
                (finished: Bool) in
                self.messageView.hidden = true
                self.inboxScrollView.contentSize = CGSize(width: self.inboxScrollView.contentSize.width, height: self.inboxScrollView.contentSize.height - self.messageView.frame.height)
                self.messageImageView.frame.origin.x = self.messageOriPos.x
        })
        canUndo = true
    }
    
    func showMessage() {
        if canUndo == true {
            self.messageView.hidden = false
            UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 10, options: nil, animations: {
                self.feedImageView.frame.origin.y = self.feedImageView.frame.origin.y + self.messageView.frame.height
                self.messageView.frame.origin.y = self.messageView.frame.origin.y + self.messageView.frame.height
                }, completion: {
                    (finished: Bool) in
                    self.inboxScrollView.contentSize = CGSize(width: self.inboxScrollView.contentSize.width, height: self.inboxScrollView.contentSize.height + self.messageView.frame.height)
            })
            canUndo = false
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent!) {
        if motion == UIEventSubtype.MotionShake {
            showMessage()
        }
    }
    
    @IBAction func onInboxSegChange(sender: AnyObject) {
        var curSeg = mailSegControl.selectedSegmentIndex
        if curSeg == 2 {
            if prevInboxSeg == 1 { // inbox -> archive
                archiveScrollView.frame.origin.x = 320
                UIView.animateWithDuration(0.25, animations: {
                    self.archiveScrollView.frame.origin.x = 0
                    self.inboxScrollView.frame.origin.x = -320
                    self.mailSegControl.tintColor = UIColor(red: 108/255, green: 219/255, blue: 91/255, alpha: 1)
                    }, completion: {
                        (finished: Bool) in
                        self.laterScrollView.frame.origin.x = 320
                        self.inboxScrollView.frame.origin.x = 320
                        self.archiveScrollView.frame.origin.x = 0
                })
            } else { // later -> archive
                archiveScrollView.frame.origin.x = 320
                UIView.animateWithDuration(0.25, animations: {
                    self.archiveScrollView.frame.origin.x = 0
                    self.laterScrollView.frame.origin.x = -320
                    self.mailSegControl.tintColor = UIColor(red: 108/255, green: 219/255, blue: 91/255, alpha: 1)
                    }, completion: {
                        (finished: Bool) in
                        self.laterScrollView.frame.origin.x = 320
                        self.inboxScrollView.frame.origin.x = 320
                        self.archiveScrollView.frame.origin.x = 0
                })
            }
        } else if curSeg == 1 {
            if prevInboxSeg == 0 { // later -> inbox
                inboxScrollView.frame.origin.x = 320
                UIView.animateWithDuration(0.25, animations: {
                    self.inboxScrollView.frame.origin.x = 0
                    self.laterScrollView.frame.origin.x = -320
                    self.mailSegControl.tintColor = UIColor(red: 108/255, green: 197/255, blue: 226/255, alpha: 1)
                    }, completion: {
                        (finished: Bool) in
                        self.laterScrollView.frame.origin.x = 320
                        self.inboxScrollView.frame.origin.x = 0
                        self.archiveScrollView.frame.origin.x = 320
                })
            } else { // archive -> inbox
                inboxScrollView.frame.origin.x = -320
                UIView.animateWithDuration(0.25, animations: {
                    self.inboxScrollView.frame.origin.x = 0
                    self.archiveScrollView.frame.origin.x = 320
                    self.mailSegControl.tintColor = UIColor(red: 108/255, green: 197/255, blue: 226/255, alpha: 1)
                    }, completion: {
                        (finished: Bool) in
                        self.laterScrollView.frame.origin.x = 320
                        self.inboxScrollView.frame.origin.x = 0
                        self.archiveScrollView.frame.origin.x = 320
                })
            }
        } else {
            if prevInboxSeg == 1 { // inbox -> later
                laterScrollView.frame.origin.x = -320
                UIView.animateWithDuration(0.25, animations: {
                    self.laterScrollView.frame.origin.x = 0
                    self.inboxScrollView.frame.origin.x = 320
                    self.mailSegControl.tintColor = UIColor(red: 251/255, green: 212/255, blue: 13/255, alpha: 1)
                    }, completion: {
                        (finished: Bool) in
                        self.laterScrollView.frame.origin.x = 0
                        self.inboxScrollView.frame.origin.x = 320
                        self.archiveScrollView.frame.origin.x = 320
                })
            } else { // archive -> later
                laterScrollView.frame.origin.x = -320
                UIView.animateWithDuration(0.25, animations: {
                    self.laterScrollView.frame.origin.x = 0
                    self.archiveScrollView.frame.origin.x = 320
                    self.mailSegControl.tintColor = UIColor(red: 251/255, green: 212/255, blue: 13/255, alpha: 1)
                    }, completion: {
                        (finished: Bool) in
                        self.laterScrollView.frame.origin.x = 0
                        self.inboxScrollView.frame.origin.x = 320
                        self.archiveScrollView.frame.origin.x = 320
                })
            }
        }
        prevInboxSeg = curSeg
    }
    
    @IBAction func onComposeCancel(sender: AnyObject) {
        self.view.endEditing(true)
        UIView.animateWithDuration(0.25, animations: {
            self.composeView.alpha = 0
            self.composeImageView.frame.origin.y = 568
            }, completion: {
                (finished: Bool) in
                self.composeView.hidden = true
        })
    }
    
    @IBAction func onComposeButton(sender: AnyObject) {
        composeView.hidden = false
        composeView.alpha = 0
        composeImageView.frame.origin.y = 568
        composeToTextField.becomeFirstResponder()
        UIView.animateWithDuration(0.25, animations: {
            self.composeView.alpha = 1
            self.composeImageView.frame.origin.y = 73
            }, completion: {
                (finished: Bool) in
                
        })
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
