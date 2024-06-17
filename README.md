# Luminare

<!-- Kai, note, if there is anything missed, changed, added, or incorrect in this readme, please update it to declare what is different. This is a basic overview, aiming to explain how and what Luminaire is and what buttons, etc. it can provide. -->

Luminare is a SwiftUI framework designed to enhance the development of macOS applications by providing a collection of pre-styled components and utilities that adhere to a consistent design language. It simplifies the creation of visually appealing and functional user interfaces.

## Adding Luminare to Xcode

To add Luminare to your Xcode project, you can use Swift Package Manager (SPM). Follow these steps:

1. Open your project in Xcode.
2. Go to `File` > `Swift Packages` > `Add Package Dependency...`.
3. Enter the repository URL for Luminare.
4. Select the version you want to use and add it to your project.

## Components and Views

Luminare offers a variety of components and views, including:

- **Buttons**: Customizable buttons with predefined styles, such as `LuminareCosmeticButtonStyle`, `LuminareCompactButtonStyle`, and `LuminareDestructiveButtonStyle`.
- **Toggles**: A toggle switch view with a clean design, as seen in `LuminareToggle`.
- **Value Adjusters**: Sliders and input fields for numerical values, like `LuminareValueAdjuster`.
- **Pickers**: Custom picker views for selecting options, demonstrated by `LuminarePicker`.
- **Color Pickers**: A color selection tool, `LuminareColorPicker`, for choosing and setting colors.
- **Text Fields**: Styled text input fields, such as `LuminareTextField`.
- **Modal Views**: Support for modal presentations with `luminareModal`.
- **Sections**: Grouping of related UI elements using `LuminareSection`.
- **Lists**: Custom list views, like `LuminareList`, for displaying collections of items.
- **Keybind Recorder**: A view for capturing and setting keyboard shortcuts, shown in `Keycorder` and `TriggerKeycorder`.
- **Visual Effect Views**: Blurred background views, as used in `VisualEffectView`.

## Utilities and Managers

Luminare also provides utilities and managers to handle common tasks:

- **Accessibility Manager**: Manages accessibility permissions and features.
- **Icon Manager**: Handles app icon changes and management.
- **Animation Configuration**: Allows setting and managing animation speeds and styles.
- **Padding Configuration**: Provides tools for setting window padding and margins.
- **Event Monitors**: Monitors for system events, particularly keyboard events.

## Format and Styling

Luminare adopts a declarative syntax that is consistent with SwiftUI. It emphasizes modularity and reusability, allowing developers to create custom interfaces with minimal boilerplate code. The framework uses a combination of system-defined and custom modifiers to apply consistent styling across different components.

## Example Usage

Here's an example of how to use a Luminare button in your SwiftUI view:

```swift
Button("Click Me") {
    // Handle button action
}
.buttonStyle(LuminareCosmeticButtonStyle(Image(systemName: "star")))
```

## Summary

Luminare is a comprehensive framework that streamlines the development of macOS applications with SwiftUI. It provides a wide range of pre-styled components and utilities, making it easier to build consistent and attractive user interfaces. By integrating Luminare into your Xcode project, you can leverage its functionality to enhance your app's design and user experience.
