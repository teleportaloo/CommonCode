//
//  ColorPickerWrapperViewController.swift
//  PDX Bus
//
//  Created by Andy Wallace on 7/10/25.
//
//  Copyright 2025 Andrew Wallace
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import UIKit

@objcMembers
class SimpleColorPickerViewController: UIColorPickerViewController,
    UIColorPickerViewControllerDelegate
{

    /// Called once when the user finishes picking (e.g. dismisses the picker)
    @objc var onColorPicked: ((UIColor) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }

    func colorPickerViewControllerDidFinish(
        _ viewController: UIColorPickerViewController
    ) {
        onColorPicked?(viewController.selectedColor)
    }

    // Optional: Don't use the live updates at all
    func colorPickerViewControllerDidSelectColor(
        _ viewController: UIColorPickerViewController
    ) {
        // no-op
    }

    // Static helper to create a picker with config
    @objc static func create(
        initialColor: UIColor,
        title: String,
        onPicked: @escaping (UIColor) -> Void
    ) -> SimpleColorPickerViewController {
        let picker = SimpleColorPickerViewController()
        picker.selectedColor = initialColor
        picker.title = title
        picker.onColorPicked = onPicked
        picker.modalPresentationStyle = .automatic
        picker.supportsAlpha = false
        return picker
    }
}
