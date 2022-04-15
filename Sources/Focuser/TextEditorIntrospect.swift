//
//  SwiftUIView.swift
//  
//
//  Created by Augustinas Malinauskas on 13/09/2021.
//

import SwiftUI

class TextViewObserver: NSObject, UITextViewDelegate {
    var onDidBeginEditing: () -> () = {}
    weak var forwardToDelegate: UITextViewDelegate?

    @available(iOS 2.0, *)
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        forwardToDelegate?.textViewShouldBeginEditing?(textView) ?? true
    }

    @available(iOS 2.0, *)
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        forwardToDelegate?.textViewShouldEndEditing?(textView) ?? true
    }

    @available(iOS 2.0, *)
    func textViewDidBeginEditing(_ textView: UITextView) {
        onDidBeginEditing()
        forwardToDelegate?.textViewDidBeginEditing?(textView)
    }

    @available(iOS 2.0, *)
    func textViewDidEndEditing(_ textView: UITextView) {
        forwardToDelegate?.textViewDidEndEditing?(textView)
    }

    @available(iOS 2.0, *)
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        forwardToDelegate?.textView?(textView, shouldChangeTextIn: range, replacementText: text) ?? true
    }

    @available(iOS 2.0, *)
    func textViewDidChange(_ textView: UITextView) {
        forwardToDelegate?.textViewDidChange?(textView)
    }

    @available(iOS 2.0, *)
    func textViewDidChangeSelection(_ textView: UITextView) {
        forwardToDelegate?.textViewDidChangeSelection?(textView)
    }

    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        forwardToDelegate?.textView?(textView, shouldInteractWith: URL, in: characterRange, interaction: interaction) ?? false
    }

    @available(iOS 10.0, *)
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        forwardToDelegate?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange, interaction: interaction) ?? false
    }

    @available(iOS, introduced: 7.0, deprecated: 10.0)
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        forwardToDelegate?.textView?(textView, shouldInteractWith: URL, in: characterRange) ?? false
    }

    @available(iOS, introduced: 7.0, deprecated: 10.0)
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        forwardToDelegate?.textView?(textView, shouldInteractWith: textAttachment, in: characterRange) ?? false
    }
}

public struct FocusModifierTextEditor<Value: FocusStateCompliant & Hashable>: ViewModifier {
    @Binding var focusedField: Value?
    var equals: Value
    @State var observer = TextViewObserver()
    let scrollViewProxy: ScrollViewProxy?

    public func body(content: Content) -> some View {
        content
            .id(equals)
            .introspectTextView { tv in
                if !(tv.delegate is TextViewObserver) {
                    observer.forwardToDelegate = tv.delegate
                    tv.delegate = observer
                }

                observer.onDidBeginEditing = {
                    focusedField = equals
                }

                if focusedField == equals {
                    if !tv.isFirstResponder {
                        tv.becomeFirstResponder()
                        tv.selectedTextRange = tv.textRange(from: tv.endOfDocument, to: tv.endOfDocument)

                        withAnimation {
                            scrollViewProxy?.scrollTo(equals, anchor: .bottom)
                        }
                    } else {
                        scrollViewProxy?.scrollTo(equals, anchor: .bottom)
                    }
                }
            }
            .simultaneousGesture(TapGesture().onEnded {
                focusedField = equals
            })
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification)) { _ in
                guard focusedField == equals, let scrollViewProxy = scrollViewProxy else { return }

                withAnimation {
                    scrollViewProxy.scrollTo(equals, anchor: .bottom)
                }
            }
    }
}
