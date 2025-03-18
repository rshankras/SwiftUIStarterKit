# macOS Background Image App

A modern macOS app demonstrating how to create a desktop application with a custom background image and transparent UI components using SwiftUI.

## Features

- Full-window background image
- Responsive sidebar navigation
- Adaptive bottom bar that adjusts to window size
- Multiple screen views (Home, Settings, Profile, etc.)
- Transparent UI components
- Organized SwiftUI code structure

## Project Structure

```
MacOSBackroundImage/
├── Views/
│   ├── Screens/          # Main screen views
│   └── Components/       # Reusable UI components
├── Utilities/            # Helper functions
└── Assets.xcassets/      # Images and assets
```

## Getting Started

1. Clone the repository
2. Open `MacOSBackroundImage.xcodeproj` in Xcode
3. Add your background image to `Assets.xcassets` named as "background_image"
4. Build and run the project (⌘R)

## Requirements

- macOS 13.0+
- Xcode 15.0+
- Swift 5.9+

## Key Concepts Demonstrated

- SwiftUI view organization
- Responsive layouts
- Component reusability
- Window transparency
- Navigation patterns
- State management

## Tips for Beginners

- Start by examining `ContentView.swift` to understand the main structure
- Look at individual screen views in the `Screens` folder
- Check out reusable components in the `Components` folder
- Experiment with different background images
- Try modifying the UI colors and transparency values

## Learn More

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [macOS App Development](https://developer.apple.com/macos/planning/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/macos) 