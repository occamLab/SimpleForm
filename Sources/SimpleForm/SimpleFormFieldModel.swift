//
//  SimpleFormFieldModel.swift
//  SimpleForm
//
//  Created by JoeShon Monroe on 4/26/20.
//  Copyright © 2020 JoeShon Monroe. All rights reserved.
//

import SwiftUI

public class SimpleFormFieldModel:ObservableObject {
    @Published public var type:SimpleFormFieldType = .text
    @Published public var label:String = ""
    @Published public var labelPosition:SimpleFormFieldLabelPosition = .placeholder
    @Published public var name:String = ""
    @Published public var value:Any = ""
    @Published public var quantizeSlider:Bool = false
    @Published public var addSliderAccent:Bool = false
    @Published public var closedRange:ClosedRange<Float> = 0...1
    @Published public var pickerSelection:Int = 0
    @Published public var options:[Any] = []
    @Published public var pickerDisplay:AnyView = AnyView(EmptyView())
    @Published public var choices:[(String, String)] = []
    @Published public var validation:[SimpleFormValidationType] = []
    @Published public var errors:[String] = []
    @Published public var keyboardType:UIKeyboardType = UIKeyboardType.default
    public var isRequired: Bool {
        return validation.map({$0.isRequired}).firstIndex(of: true) != nil
    }
    public var isTextElement: Bool {
        if case .text = type {
            return true
        }
        if case .textView = type {
            return true
        }
        return false
    }
    public var isRequiredTextElement: Bool {
        return isTextElement && isRequired
    }
}
