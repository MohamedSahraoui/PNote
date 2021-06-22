//
//  Copyright © 2021 Mac SE. All rights reserved.
//

import UIKit
import CoreData

class RegistrationViewController: UIViewController {
    
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var usernameTF: UITextField!
    @IBOutlet private weak var passwordTF: UITextField!
    @IBOutlet private weak var passwordConfirmationTF: UITextField!
    @IBOutlet private weak var errorLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
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
        
        passwordConfirmationTF.addTarget(
            self,
            action: #selector(textDidChange),
            for: .editingChanged
        )
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
    
    @IBAction func registerClick(_ sender: Any) {
        registerButton.isUserInteractionEnabled = false
        var errorMessage = ""
        if (usernameTF.text ?? "").isEmpty  {
            errorMessage = "* Please enter your username"
        } else if userNameReserved(usernameTF.text ?? "") {
            errorMessage = "* Username \(usernameTF.text ?? "") taken"
        }
        if (passwordTF.text ?? "").isEmpty {
            if !errorMessage.isEmpty {
                errorMessage = errorMessage + "\n"
            }
            errorMessage = errorMessage + "* Please enter your password"
        }
        if (passwordConfirmationTF.text ?? "").isEmpty {
            if !errorMessage.isEmpty {
                errorMessage = errorMessage + "\n"
            }
            errorMessage = errorMessage + "* Please enter your password confirmation"
        }
        if passwordConfirmationTF.text != passwordTF.text {
            if !errorMessage.isEmpty {
                errorMessage = errorMessage + "\n"
            }
            errorMessage = errorMessage + "* Password and confirmation password do not match"
        }
        if errorMessage.isEmpty {
            if let user = save(username: usernameTF.text!, password: passwordTF.text!) {
                let notesVc = NotesListViewController()
                notesVc.user = user
                navigationController?.setViewControllers([notesVc], animated: true)
            } else {
                errorLabel.text = "error"
            }
        } else {
            errorLabel.text = errorMessage
        }
        registerButton.isUserInteractionEnabled = true
    }
    
    func save(username: String, password: String) -> User? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
          return nil
        }

        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: UserEntiy.userKey, in: managedContext)!
        let user = NSManagedObject(entity: entity, insertInto: managedContext)
        user.setValue(username, forKeyPath: UserEntiy.userNameKey)
        user.setValue(password, forKeyPath: UserEntiy.passowrdKey)
        do {
          try managedContext.save()
            return user as? User
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
            return nil
        }
      }
    
    func userNameReserved(_ userName: String) -> Bool {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return true }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: UserEntiy.userKey)
        do {
            let users = try managedContext.fetch(fetchRequest)
            for user in users {
                if (user.value(forKey: UserEntiy.userNameKey) as! String) == userName {
                    return true
                }
            }
            return false
        } catch let error as NSError {
            print(error)
            return true
        }
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
