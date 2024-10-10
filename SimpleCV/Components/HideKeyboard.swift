//
//  HideKeyboard.swift
//  SimpleCV
//
//  Created by asia on 10.10.2024.
//

import SwiftUI

func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
}
