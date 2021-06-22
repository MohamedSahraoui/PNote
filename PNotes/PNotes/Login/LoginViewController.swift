//
//  Copyright © 2021 Mac SE. All rights reserved.
//

import UIKit
import CoreData

class LoginViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var usernameTF: UITextField!
    @IBOutlet private weak var passwordTF: UITextField!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotifications()
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(UIInputViewController.dismissKeyboard)
        )
        view.addGestureRecognizer(tap)
        usernameTF.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )
        
        passwordTF.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )

    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.tintColor = .darkGray
    }

    private func registerNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    @IBAction func loginClick(_ sender: Any) {
        loginButton.isUserInteractionEnabled = false
        registerButton.isUserInteractionEnabled = false
        var errorMessage = ""
        if (usernameTF.text ?? "").isEmpty {
            errorMessage = "* Please enter your username"
        }
        if (passwordTF.text ?? "").isEmpty {
            if !errorMessage.isEmpty {
                errorMessage = errorMessage + "\n"
            }
            errorMessage = errorMessage + "* Please enter your password"
        }
        errorLabel.text = errorMessage
        if errorMessage.isEmpty {
            if let user = managedObject(userName: usernameTF.text!, password: passwordTF.text!) {
                let notesVc = NotesListViewController()
                notesVc.user = user
                navigationController?.setViewControllers([notesVc], animated: true)
            } else {
                errorLabel.text = "Wrong username or password"
            }
        }
        loginButton.isUserInteractionEnabled = true
        registerButton.isUserInteractionEnabled = true
    }
    
    func managedObject(userName: String, password: String) -> User? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return nil }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: UserEntiy.userKey)
        do {
            let users = try managedContext.fetch(fetchRequest)
            for user in users {
                if (user.value(forKey: UserEntiy.userNameKey) as! String) == userName &&
                    (user.value(forKey: UserEntiy.passowrdKey) as! String) == password {
                    return user as? User
                }
            }
            return nil
        } catch let error as NSError {
            print(error)
            return nil
        }
    }
    
    @IBAction func registerClick(_ sender: Any) {
        self.navigationController?.pushViewController(RegistrationViewController(), animated: true)
    }
    
    @IBAction private func keyboardWillShow(notification: NSNotification){
        guard let keyboardFrame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        scrollView.contentInset.bottom = view.convert(keyboardFrame.cgRectValue, from: nil).size.height
    }

    @IBAction private func keyboardWillHide(notification: NSNotification){
        scrollView.contentInset.bottom = 0
    }
    
    @IBAction private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction private func textDidChange() {
        errorLabel.text = ""
    }
}
