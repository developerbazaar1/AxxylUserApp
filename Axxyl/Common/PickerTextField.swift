//
//  PickerTextField.swift
//  Axxyl
//
//  Created by Mangesh Kondaskar on 08/12/22.
//

import UIKit

class PickerTextField: UITextField {
    
    override func caretRect(for position: UITextPosition) -> CGRect {
      return .zero
    }
    
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
      return []
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
      return false
    }

}
