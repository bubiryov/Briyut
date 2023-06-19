//
//  Test.swift
//  Briyut
//
//  Created by Egor Bubiryov on 19.06.2023.
//

import SwiftUI

import SwiftUI


extension UITextField {
    @objc  func next(_ textField: UITextField) {}
}

class WrappableTextField: UITextField, UITextFieldDelegate {

    var onChange: ((UITextField, String)->Void)?
    var didEndEditing: (()->Void)?
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let currentValue = textField.text as NSString? {
            let proposedValue = currentValue.replacingCharacters(in: range, with: string)
            onChange?(textField, proposedValue)
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.endEditing(true)
        didEndEditing?()
    }
    
    
    @objc override func next(_ textField: UITextField) {
        _ = textFieldShouldReturn(textField)
    }
}

struct CTextField: UIViewRepresentable {
    private let tmpView = WrappableTextField()
    
    var tag: Int = 0
    var placeholder: String?
    var changeHandler: ((UITextField, String)->Void)?
    var didEndEditing: (()->Void)?
    
    func makeUIView(context: UIViewRepresentableContext<CTextField>) -> WrappableTextField {
        tmpView.tag = tag
        tmpView.delegate = tmpView
        tmpView.placeholder = placeholder
        tmpView.didEndEditing = didEndEditing
        tmpView.onChange = changeHandler
        return tmpView
    }
    
    func updateUIView(_ uiView: WrappableTextField, context: UIViewRepresentableContext<CTextField>) {
    }

}


struct ContentView2: View {
    var body: some View {

        CTextField(tag: 0, placeholder: "focus 1") { (textfield, string) in
            if string.count > 3 {
                textfield.next(textfield)
            }
        } didEndEditing: {
            print("focus 1")
        }
        
        CTextField(tag: 1, placeholder: "focus 2") {  (textfield, string) in
            print(string)
        } didEndEditing: {
            print("focus 2")
        }

        CTextField(tag: 2, placeholder: "focus 3") {  (textfield, string) in
            print(string)
        } didEndEditing: {
            print("focus 3")
        }

    }
}

struct ContentView2_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}
