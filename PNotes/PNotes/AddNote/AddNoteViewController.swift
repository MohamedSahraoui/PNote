//
//  Copyright © 2021 Mac SE. All rights reserved.
//

import UIKit
import CoreData

class AddNoteViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    var addNote: ((_ title: String, _ description: String) -> Void)!
    
    @IBOutlet private weak var titleTF: UITextField!
    @IBOutlet private weak var descriptionTV: UITextView!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNotifications()
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(UIInputViewController.dismissKeyboard)
        )
        view.addGestureRecognizer(tap)
        
        titleTF.addTarget(
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
    
    @IBAction func saveClick(_ sender: Any) {
        saveButton.isUserInteractionEnabled = false
        var errorMessage = ""
        if (titleTF.text ?? "").isEmpty {
            errorMessage = "* Please enter a title"
        }
        if (descriptionTV.text ?? "").isEmpty {
            if !errorMessage.isEmpty {
                errorMessage = errorMessage + "\n"
            }
            errorMessage = errorMessage + "* Please enter a description"
        }
        errorLabel.text = errorMessage
        if errorMessage.isEmpty {
            addNote(titleTF.text!, descriptionTV.text!)
            self.navigationController?.popViewController(animated: true)
        }
        saveButton.isUserInteractionEnabled = true
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

extension AddNoteViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        errorLabel.text = ""
    }
}
