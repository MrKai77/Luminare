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

| Component Type | Component | Modifier | Description |
|---|---|---|---|
| **Button Styles** | `LuminareButtonStyle` | `.luminareButtonMaterial()` | Button material styling |
| | | `.luminareButtonCornerRadii()` | Button corner radii |
| | | `.luminareButtonCornerRadius()` | Button corner radius |
| | | `.luminareButtonHighlightOnHover()` | Enable hover highlighting |
| | `LuminareCompactButtonStyle` | `.luminareCompactButtonCornerRadii()` | Compact button corner radii |
| | | `.luminareCompactButtonCornerRadius()` | Compact button corner radius |
| | `LuminareCosmeticButtonStyle` | - | Button style for cosmetic buttons |
| | `LuminareProminentButtonStyle` | - | Prominent button style |
| **Composes** | `LuminareButton` | `.luminareComposeControlSize()` | Control size configuration |
| | | `.luminareComposeStyle()` | Compose style |
| | | `.luminareComposeIgnoreSafeArea()` | Safe area behavior |
| | `LuminareCompose` | - | Compose container for controls |
| | `LuminareToggle` | - | Toggle control |
| | `LuminareSlider` | `.luminareSliderLayout()` | Slider layout configuration |
| | `LuminareSliderPicker` | `.luminareSliderPickerLayout()` | Slider picker layout |
| **Pickers** | `LuminarePicker` | `.luminarePickerRoundedCorner()` | Rounded corner behavior |
| | `LuminareCompactPicker` | `.luminareCompactPickerStyle()` | Compact picker style |
| **Color Pickers** | `LuminareColorPicker` | `.luminareColorPickerControls()` | Configure cancel/done controls |
| **Text Inputs** | `LuminareTextField` | - | Styled text field |
| | `LuminareTextEditor` | - | Styled text editor |
| **Steppers** | `LuminareStepper` | `.luminareStepperAlignment()` | Stepper alignment (macOS 15.0+) |
| | | `.luminareStepperDirection()` | Stepper direction (macOS 15.0+) |
| **Sections** | `LuminareSection` | `.luminareSectionLayout()` | Section layout configuration |
| | | `.luminareSectionMaterial()` | Section background material |
| | | `.luminareSectionMaxWidth()` | Maximum section width |
| | | `.luminareSectionMasked()` | Enable/disable masking |
| **Lists** | `LuminareList` | `.luminareListItemCornerRadii()` | List item corner radii |
| | | `.luminareListItemCornerRadius()` | List item corner radius |
| | | `.luminareListItemHeight()` | List item height |
| | | `.luminareListItemHighlightOnHover()` | Hover highlighting |
| | | `.luminareListFixedHeight()` | Fixed list height |
| | | `.luminareListRoundedCorner()` | Rounded corner behavior |
| | `LuminareListItem` | - | Individual list item |
| **Main Window** | `LuminareWindow` | - | Main window container |
| | `LuminareView` | - | Main view container |
| | `LuminarePane` | `.luminarePaneLayout()` | Pane layout configuration |
| | | `.luminareTitleBarHeight()` | Title bar height |
| | `LuminareDividedStack` | - | Divided stack container |
| | `LuminareSidebar` | `.luminareSizebarOverflow()` | Sidebar overflow |
| | `LuminareSidebarSection` | - | Sidebar section |
| | `LuminareSidebarTab` | - | Sidebar tab |
| | `LuminareTabItem` | - | Tab item |
| **Modal Windows** | `LuminareModalWindow` | `.luminareModal()` | Display modal windows |
| | | `.luminareModalWithPredefinedSheetStyle()` | Modal with predefined styling |
| | | `.luminareModalStyle()` | Configure modal appearance |
| | | `.luminareModalContentWrapper()` | Wrap modal content |
| | | `.luminareSheetCornerRadii()` | Sheet corner radii |
| | | `.luminareSheetCornerRadius()` | Sheet corner radius |
| | | `.luminareSheetPresentation()` | Sheet presentation config |
| | | `.luminareSheetMovableByWindowBackground()` | Make sheets draggable |
| | | `.luminareSheetClosesOnDefocus()` | Auto-close on defocus |
| | `LuminareModalView` | - | Modal view |
| | `LuminareTrafficLightedWindow` | - | Window with traffic lights |
| | `LuminareTrafficLightedWindowView` | - | Traffic lighted window view |
| **Popups** | - | `.luminarePopover()` | Display popovers |
| | | `.luminarePopoverTrigger()` | Configure popover triggers |
| | | `.luminarePopoverShade()` | Configure popover shading |
| | | `.luminarePopup()` | Display popup panels |
| | | `.luminarePopupPadding()` | Popup padding |
| | | `.luminarePopupCornerRadii()` | Popup corner radii |
| **Auxiliary Views** | `AutoScrollView` | - | Auto-scrolling view |
| | `DividedVStack` | - | Vertical stack with dividers |
| | `InfiniteScrollView` | - | Infinite scroll view |
| **Form Styles** | `LuminareFormStyle` | `.luminareFormSpacing()` | Form spacing (macOS 15.0+) |
| **Global Modifiers** | - | `.luminareTint()` | Custom tint color |
| | | `.luminareBackground()` | Apply background effects |
| | | `.luminareBordered()` | Add borders |
| | | `.luminareCornerRadii()` | Corner radii |
| | | `.luminareCornerRadius()` | Corner radius |
| | | `.luminareHasBackground()` | Toggle background |
| | | `.luminareHasDividers()` | Toggle dividers |
| | | `.luminareAspectRatio()` | Aspect ratio control |
| | | `.luminareContentMargins()` | Content margins |
| | | `.luminareMinHeight()` | Minimum height |
| | | `.luminareHorizontalPadding()` | Horizontal padding |
| | | `.luminareAnimation()` | Custom animation |
| | | `.luminareAnimationFast()` | Fast animation |
| | | `.booleanThrottleDebounced()` | Throttled/debounced boolean changes |
| **Utilities** | `LuminareSelectionData` | - | Protocol for selection behavior |
| | `StringFormatStyle` | - | String formatting utilities |
| | `EventMonitorManager` | - | Event monitoring manager |

## Example Usage

Luminare can be used pretty much exactly like how you would use SwiftUI. For a practical example, please check [Loop's code](https://github.com/MrKai77/Loop).

## License

Luminare is released under **BSD 3-Clause License.** See the [LICENSE](LICENSE) file in the repository for the full license text.
