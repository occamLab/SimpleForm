//
//  SimpleForm.swift
//  SimpleForm
//
//  Created by JoeShon Monroe on 4/26/20.
//  Copyright © 2020 JoeShon Monroe. All rights reserved.
//

import SwiftUI

extension View {
  @ViewBuilder
  func `if`<Transform: View>(
    _ condition: Bool,
    transform: (Self) -> Transform
  ) -> some View {
    if condition {
      transform(self)
    } else {
      self
    }
  }
}

public struct SF: View {
    @ObservedObject public var model:SimpleFormModel = SimpleFormModel()
    let validator = SimpleFormValidation()
    public init() {
        
    }
    
    public func isValid() -> Bool {
        var errors:[Bool] = []
        var errorsToAnnounce:[String] = []
        
        for section in self.model.sections {
            let fields = section.model.fields
            
            
            for field in fields {
                
                if (field.model.validation.count > 0) {
                    field.model.errors.removeAll()
                    
                    for validation in field.model.validation {
                        switch validation {
                        case .email:
                            if (validator.validateEmail(value: field.model.value) == false && (field.model.isRequired || validator.validateEmpty(value: field.model.value) == true)) {
                                errors.append(false)
                                field.model.errors.append(NSLocalizedString("invalidEmailAddress", bundle: .module, comment: "This text is displayed below the field if the user fails to enter a valid email address"))
                                errorsToAnnounce.append(field.model.errors.last!)
                            }
                        case .required:
                            if (validator.validateEmpty(value: field.model.value) == false) {
                                errors.append(false)
                                field.model.errors.append(NSLocalizedString("missingRequiredFieldHighlight", bundle: .module, comment: "This text is displayed below the field if the user fails to enter a value for a required field"))
                                errorsToAnnounce.append(String(format: NSLocalizedString("missingRequiredFieldAnnouncement", bundle: .module, comment: "This is announced to the user if they are using VoiceOver and they fail to enter a value for a required field"), field.model.label))
                            }
                        case .regex(let regex, let errorMessage):
                            if (validator.validateRegex(value: field.model.value, regex: regex) == false && (field.model.isRequired || validator.validateEmpty(value: field.model.value) == true)) {
                                errors.append(false)
                                field.model.errors.append(errorMessage)
                                errorsToAnnounce.append(field.model.errors.last!)
                            }
                        }
                    }
                }
            }
        }
        
        if errors.count > 0 {
            self.model.isValid = false
            if UIAccessibility.isVoiceOverRunning {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    UIAccessibility.post(notification: .announcement, argument: errorsToAnnounce.joined(separator: "\n"))
                }
            }
            return false
        } else {
            self.model.isValid = true
            return true
        }
    }
    
    public func getValues() -> Dictionary<String, Any> {
        var values:[String:Any] = [:]
        
        for section in self.model.sections {
            let fields = section.model.fields
            
            for field in fields {
                values[field.model.name] = field.model.value
            }
        }
        
        return values
    }
    
    public var hasRequiredTextElement: Bool {
        model.sections.map({ $0.model.hasRequiredTextElement }).firstIndex(of: true) != nil
    }
    
    public var body: some View {
        Form {
            if hasRequiredTextElement {
                Text("* = required").font(.footnote)
            }
            ForEach(self.model.sections, id: \.id) { jamFormSection in
                jamFormSection
            }
        }
        .onAppear {
            //UITableView.appearance().backgroundColor = .orange
            UITableView.appearance().tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
            UITableView.appearance().tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: Double.leastNonzeroMagnitude))
            UITableView.appearance().separatorStyle = .none
            UITableView.appearance().layoutMargins = UIEdgeInsets.zero
            UITableView.appearance().sectionHeaderHeight = 0
        }
    }
}

//struct SimpleForm_Previews: PreviewProvider {
//    static var previews: some View {
//        SimpleForm()
//    }
//}
