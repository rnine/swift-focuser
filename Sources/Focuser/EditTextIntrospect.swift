//
//  EditTextIntrospect.swift
//  
//
//  Created by Alexandre Nussbaumer on 22.03.22.
//

import SwiftUI
import Introspect

class EditTextObserver: NSObject, UITextViewDelegate {
    var onReturnTap: () -> () = {}
    weak var forwardToDelegate: UITextViewDelegate?

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        forwardToDelegate?.textViewShouldBeginEditing?(textView) ?? true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        forwardToDelegate?.textViewDidBeginEditing?(textView)
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        forwardToDelegate?.textViewShouldEndEditing?(textView) ?? true
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        forwardToDelegate?.textViewDidEndEditing?(textView)
    }

    func textViewDidChange(_ textView: UITextView) {
        forwardToDelegate?.textViewDidChange?(textView)
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        forwardToDelegate?.textViewDidChangeSelection?(textView)
    }
}
