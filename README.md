# Luminare

Luminare is a SwiftUI framework designed to enhance the development of macOS applications by providing a collection of pre-styled components that adhere to a consistent design language. It simplifies the creation of visually appealing and functional user interfaces.

## Features

- **Adopts a declarative syntax** that is consistent with SwiftUI.
- **Emphasizes modularity and reusability**, allowing developers to create custom interfaces with minimal boilerplate code.
- Uses a combination of system-defined and custom modifiers to apply **consistent styling** across different components.

## Add to your Project

To add Luminare to your Xcode project, you can use Swift Package Manager (SPM). Follow these steps:

1. Open your project in Xcode.
2. Go to `File` > `Swift Packages` > `Add Package Dependency...`.
3. Enter the repository URL for Luminare.
4. Select the version you want to use and add it to your project.

## Components

Luminare offers a variety of components, organized for easy reference:

<table>
  <!-- Headers -->
  <tr>
    <th>Component Type</th>
    <th>Component</th>
    <th>Preview</th>
  </tr>
  <!-- Buttons -->
  <tr>
    <th rowspan="4">Buttons</th>
    <td><code>LuminareButtonStyle</code></td>
    <td align="right"><img src="assets/LuminareButtonStyle.png" width="300"></td>
  </tr>
  <tr>
    <td><code>LuminareDestructiveButtonStyle</code></td>
    <td align="right"><img src="assets/LuminareDestructiveButtonStyle.png" width="150"></td>
  </tr>
  <tr>
    <td><code>LuminareCompactButtonStyle</code></td>
    <td align="right"><img src="assets/LuminareCompactButtonStyle.png" width="300"></td>
  </tr>
  <tr>
    <td><code>LuminareCosmeticButtonStyle</code></td>
    <td align="right"><img src="assets/LuminareCosmeticButtonStyle.png" width="300"></td>
  </tr>
  <!-- Toggle Buttons -->
  <tr>
    <th rowspan="1">Toggle Buttons</th>
    <td><code>LuminareToggle</code></td>
    <td align="right"><img src="assets/LuminareToggle.png" width="300"></td>
  </tr>
  <!-- Value Adjusters -->
  <tr>
    <th rowspan="1">Value Adjusters</th>
    <td><code>LuminareValueAdjuster</code></td>
    <td align="right"><img src="assets/LuminareValueAdjuster.png" width="300"></td>
  </tr>
  <!-- Pickers -->
  <tr>
    <th rowspan="2">Pickers</th>
    <td><code>LuminarePicker</code></td>
    <td align="right"><img src="assets/LuminarePicker.png" width="300"></td>
  </tr>
  <tr>
    <td><code>LuminareSliderPicker</code></td>
    <td align="right"><img src="assets/LuminareSliderPicker.png" width="300"></td>
  </tr>
  <!-- Color Pickers -->
  <tr>
    <th rowspan="1">Color Pickers</th>
    <td><code>LuminareColorPicker</code></td>
    <td align="right"><img src="assets/LuminareColorPicker.png" width="300"></td>
  </tr>
  <!-- Text Fields -->
  <tr>
    <th rowspan="1">Text Fields</th>
    <td><code>LuminareTextField</code></td>
    <td align="right"><img src="assets/LuminareTextField.png" width="300"></td>
  </tr>
  <!-- Modal Views -->
  <tr>
    <th rowspan="1">Modal Views</th>
    <td><code>.luminareModal(...)</code></td>
    <td align="right"><img src="assets/LuminareModal.png" width="300"></td>
  </tr>
  <!-- Sections -->
  <tr>
    <th rowspan="1">Sections</th>
    <td><code>LuminareSection</code></td>
    <td align="right"><img src="assets/LuminareSection.png" width="300"></td>
  </tr>
  <!-- Lists -->
  <tr>
    <th rowspan="1">Lists</th>
    <td><code>LuminareList</code></td>
    <td align="right"><img src="assets/LuminareList.png" width="300"></td>
  </tr>
</table>

## Example Usage

Luminare can be used pretty much exactly like how you would use SwiftUI. For a practical example, please check [Loop's code](https://github.com/MrKai77/Loop/blob/1b6e4f8555be2dfaf4e0ae0225224d71d36a5078/Loop/Luminare/Settings/Behavior/BehaviorConfiguration.swift#L97).

## License

Luminare is released under **GNU General Public License v3.0.** See the [LICENSE](LICENSE) file in the repository for the full license text.
