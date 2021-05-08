//
//  SimpleFormField.swift
//  SimpleForm
//
//  Created by JoeShon Monroe on 4/26/20.
//  Copyright © 2020 JoeShon Monroe. All rights reserved.
//

import SwiftUI
import Sliders

public struct SimpleFormField: View, Identifiable {
    public var id = UUID()
    @ObservedObject public var model:SimpleFormFieldModel = SimpleFormFieldModel()
    
    public init(textField label:String, labelPosition:SimpleFormFieldLabelPosition = .placeholder, name:String,value:Any,validation:[SimpleFormValidationType] = [], keyboardType:UIKeyboardType = UIKeyboardType.default) {
        self.model.type = .text
        self.model.label = label
        self.model.labelPosition = labelPosition
        self.model.name = name
        self.model.value = value
        self.model.validation = validation
        self.model.keyboardType = keyboardType
    }

    public init(textView label:String, labelPosition:SimpleFormFieldLabelPosition = .placeholder, name:String,value:Any,validation:[SimpleFormValidationType] = [], keyboardType:UIKeyboardType = UIKeyboardType.default) {
        self.model.type = .textView
        self.model.label = label
        self.model.labelPosition = labelPosition
        self.model.name = name
        self.model.value = value
        self.model.validation = validation
        self.model.keyboardType = keyboardType
    }
    
    public init(pickerField label:String, labelPosition:SimpleFormFieldLabelPosition = .placeholder, name:String, selection:Int, options:Array<Any>, display:([Any]) -> AnyView, validation:[SimpleFormValidationType] = []) {
        self.model.type = .picker
        self.model.label = label
        self.model.labelPosition = labelPosition
        self.model.name = name
        self.model.pickerSelection = selection
        self.model.options = options
        self.model.pickerDisplay = display(options)
        self.model.value = self.model.options[selection]
        self.model.validation = validation
    }

    public init(toggleField label:String, name:String, value:Bool = false) {
        self.model.type = .toggle
        self.model.label = label
        self.model.name = name
        self.model.value = value
    }
    
    public init(sliderField label:String, name:String, value:Float = 0, addSliderAccent: Bool = false, quantizeSlider: Bool = false, range:ClosedRange<Float>) {
        self.model.type = .slider
        self.model.label = label
        self.model.labelPosition = .above
        self.model.name = name
        self.model.value = value
        self.model.addSliderAccent = addSliderAccent
        self.model.quantizeSlider = quantizeSlider
        self.model.closedRange = range
        
        
        do {
            try self.checkSliderRange(label: label, value: value, range: range)
        } catch SimpleFormFieldError.runtimeError(let errorMessage) {
            print(errorMessage)
        } catch {
            
        }
        
        
    }
    
    public init(stepperField label:String, name:String, value:Float = 0, range:ClosedRange<Float>) {
        self.model.type = .stepper
        self.model.label = label
        self.model.name = name
        self.model.value = value
        self.model.closedRange = range
    }
    
    public func checkSliderRange(label:String, value:Float, range:ClosedRange<Float>) throws {
        if (!range.contains(value)) {
            throw SimpleFormFieldError.runtimeError("\(label) value is out of given range.")
        }
    }
    
    
    
    
    public var body: some View {
        
        VStack(alignment: .leading) {
            
            if self.model.labelPosition == .above {
                if self.model.type == .slider {
                    HStack {
                        Text(self.model.label)
                        Spacer()
                        Text(String(format: self.model.quantizeSlider ? "%.0f": "%.2f", self.model.value as! Float)).accessibility(hidden: true)
                    }
                } else {
                    if self.model.isRequiredTextElement {
                        Text(self.model.label + " *").accessibility(label: Text(self.model.label + ", " + NSLocalizedString("required",  bundle: .module, comment: "this string is used to mark a field as required")))
                    } else {
                        Text(self.model.label)
                    }
                }

            }
            if self.model.type == .text {
                TextField(self.model.labelPosition == .placeholder ? self.model.label : "", text: Binding(get: {
                    return self.model.value as! String
                }, set: { (newValue) in
                    self.model.value = newValue
                }))
                    .keyboardType(self.model.keyboardType)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .padding(.all, 5)
                    .textFieldStyle(PlainTextFieldStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(self.model.errors.count > 0 ? Color.red : Color.gray, lineWidth: 1)
                )
            } else if self.model.type == .textView {
                TextView(self.model.labelPosition == .placeholder ? self.model.label : "", text: Binding(get: {
                    return self.model.value as! String
                }, set: { (newValue) in
                    self.model.value = newValue
                }))
                    .keyboardType(self.model.keyboardType)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    .padding(.all, 5)
                    .textFieldStyle(PlainTextFieldStyle())
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(self.model.errors.count > 0 ? Color.red : Color.gray, lineWidth: 1)
                )
            } else if(self.model.type == .picker) {
                Picker(selection: Binding(get: {
                    return self.model.pickerSelection
                }, set: { (newValue) in
                    self.model.pickerSelection = newValue
                    self.model.value = self.model.options[newValue]
                }), label: Text("\(self.model.labelPosition == .placeholder ? self.model.label : "")")) {
                    self.model.pickerDisplay
                }
            } else if(self.model.type == .toggle) {
                Toggle(self.model.label, isOn:  Binding(get: {
                    return self.model.value as! Bool
                }, set: { (newValue) in
                    self.model.value = newValue
                }))
            } else if(self.model.type == .slider) {
                ZStack {
                    Slider(value: Binding(get: {
                        return self.model.value as! Float
                    }, set: { (newValue) in
                        self.model.value = newValue
                    }), in: self.model.closedRange, step: 1)
                    .background(Color.clear)
                    .if(self.model.quantizeSlider) { $0.accessibility(value: Text("\(Int(self.model.value as! Float))"))
                    }
                    .padding(20)
                }.if(self.model.addSliderAccent) {
                    $0.background(Color.yellow)
                }
            } else if(self.model.type == .stepper){
                Stepper("\(self.model.label) (\(String(format: "%.0f", self.model.value as! Float)))", value: Binding(get: {
                    return self.model.value as! Float
                }, set: { (newValue) in
                    self.model.value = newValue
                }), in: self.model.closedRange)
            } else {
                EmptyView()
            }
            
            if self.model.errors.count > 0 {
                ForEach(self.model.errors, id: \.self) { error in
                    Text("\(error)").font(.footnote)
                }
                
            }
        }
        
    }
}
