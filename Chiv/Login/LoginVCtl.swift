//
//  LoginVCtl.swift
//  Chiv
//
//  Created by user on 2018/7/7.
//  Copyright © 2018年 user. All rights reserved.
//

import UIKit

class LoginVCtl: UIViewController, UITextFieldDelegate
{
    @IBOutlet var facebookBtn:UIButton!
    @IBOutlet var googleBtn:UIButton!
    @IBOutlet var moveHconstraint:NSLayoutConstraint!
    @IBOutlet var usernameFld:UITextField!
    @IBOutlet var passwordFld:UITextField!
    
    var fborg_botline:CGFloat = 0
    var ssize:CGSize = CGSize.zero
    var keyboardh:CGFloat = 0
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let tapget:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onViewTap))
        self.view.addGestureRecognizer(tapget)
    }
    
    @objc func onViewTap(ges:UITapGestureRecognizer)
    {
        usernameFld.resignFirstResponder()
        passwordFld.resignFirstResponder()
        moveViewWhenKeyboardDisappear()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (fborg_botline==0)
        {
            fborg_botline = facebookBtn.frame.origin.y + facebookBtn.frame.size.height
        }
        
        if(ssize==CGSize.zero)
        {
            ssize = UIScreen.main.bounds.size
        }
        print(moveHconstraint.constant)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    func moveViewWhenKeyboardAppear(_ dy:CGFloat)
    {
        moveHconstraint.constant = dy + 250
        UIView.animate(withDuration: 0.31, animations: {
            self.view.layoutIfNeeded()
        }, completion: {finished in })
    }
    
    func moveViewWhenKeyboardDisappear()
    {
        moveHconstraint.constant = 0
        UIView.animate(withDuration: 0.31, animations: {
            self.view.layoutIfNeeded()
        }, completion: {finished in })
    }
    
    @objc func keyboardWillShow(notification:NSNotification)
    {
        if let userInfo = notification.userInfo {
            if let keyboardSize = userInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
                if (keyboardh==0)
                {
                    keyboardh = keyboardSize.height
                }
                let sy:CGFloat = ssize.height - keyboardh
                self.moveViewWhenKeyboardAppear(self.fborg_botline-sy)
            } else {
                
            }
        } else {
                
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        moveViewWhenKeyboardDisappear()
        return true
    }
    
    @IBAction func onMain()
    {
        self.navigationController?.pushViewController(MainVCtl(), animated: true)
    }

}
