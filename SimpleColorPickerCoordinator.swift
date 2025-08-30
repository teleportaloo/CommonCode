//
//  ColorPickerWrapperViewController.swift
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
class SimpleColorPickerCoordinator: NSObject,
    UIColorPickerViewControllerDelegate
{
    private let picker = UIColorPickerViewController()
    private var pickedColor: UIColor
    private let onPicked: (UIColor?) -> Void

    init(
        initialColor: UIColor,
        title: String,
        onPicked: @escaping (UIColor?) -> Void
    ) {
        self.pickedColor = initialColor
        self.onPicked = onPicked
        super.init()

        picker.selectedColor = initialColor
        picker.supportsAlpha = false
        picker.delegate = self
        picker.navigationItem.title = title

        // Add Done/Cancel buttons
        picker.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(doneTapped)
        )
        picker.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelTapped)
        )
    }

    // Keep track of the selected color as the user changes it
    func colorPickerViewControllerDidSelectColor(
        _ viewController: UIColorPickerViewController
    ) {
        pickedColor = viewController.selectedColor
    }

    // Present wrapped in navigation controller
    @objc static func create(
        initialColor: UIColor,
        title: String,
        onPicked: @escaping (UIColor?) -> Void
    ) -> UINavigationController {
        let coordinator = SimpleColorPickerCoordinator(
            initialColor: initialColor,
            title: title,
            onPicked: onPicked
        )

        let nav = UINavigationController(rootViewController: coordinator.picker)
        nav.modalPresentationStyle = .formSheet
        nav.view.backgroundColor = .systemBackground

        // Retain coordinator using associated object so it isn't deallocated
        objc_setAssociatedObject(
            nav,
            Unmanaged.passUnretained(nav).toOpaque(),
            coordinator,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        return nav
    }

    @objc private func doneTapped() {
        picker.dismiss(animated: true) {
            self.onPicked(self.pickedColor)
        }
    }

    @objc private func cancelTapped() {
        picker.dismiss(animated: true) {
            self.onPicked(nil)
        }
    }
}
