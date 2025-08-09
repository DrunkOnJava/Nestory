# Xcode Project Fix Instructions

## Issue: Duplicate .keep files in Copy Bundle Resources

The project currently has build errors due to `.keep` files being included in the Copy Bundle Resources phase.

## To Fix:

1. Open `Nestory.xcodeproj` in Xcode
2. Select the **Nestory** project in the navigator (top blue icon)
3. Select the **Nestory** target
4. Go to the **Build Phases** tab
5. Expand **Copy Bundle Resources**
6. Find and select all `.keep` files in the list
7. Click the **-** button to remove them
8. Build and run the project

## Alternative Fix (Command Line):

Remove all .keep files from the project:
```bash
find Nestory -name ".keep" -type f -delete
```

## Prevention:

The `.keep` files are only needed for git to track empty directories. They should never be included in the Xcode project as resources.

## Project Structure:

The project has been reorganized to have a cleaner structure:
```
/Users/griffin/Projects/Nestory/          # Project root
├── Nestory.xcodeproj                     # Xcode project file
├── Nestory/                              # App source files
│   ├── Assets.xcassets
│   ├── ContentView.swift
│   ├── NestoryApp.swift
│   ├── Models/
│   ├── Views/
│   ├── Utilities/
│   └── ...
├── NestoryTests/                         # Unit tests
├── NestoryUITests/                       # UI tests
└── run_screenshots.sh                    # Screenshot script
```

This eliminates the previous triple-nested Nestory directories.