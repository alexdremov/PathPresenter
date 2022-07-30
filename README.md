# PathPresenter
![GitHub release (latest by date)](https://img.shields.io/github/v/release/AlexRoar/PathPresenter)
![GitHub top language](https://img.shields.io/github/languages/top/AlexRoar/PathPresenter)
[![Codacy Badge](https://app.codacy.com/project/badge/Grade/054cef3e06ed4bf69725db51a81e1c1b)](https://www.codacy.com/gh/AlexRoar/PathPresenter/dashboard?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=AlexRoar/PathPresenter&amp;utm_campaign=Badge_Grade)


https://user-images.githubusercontent.com/25539425/181922855-3ff3aa77-757b-4091-b682-63456fe963a1.mp4


Pure SwiftUI routing with transitions, animations, and `.sheet()` support.

In SwiftUI, View is a function of the state. Routing is not an exception.

## Why
- `.sheet()` usages are usually messy, deviate from app architecture, and require additional business-logic
- Creating view sequences in SwiftUI is not elegant and even not messy
- MVVM is gorgeous, but what about one level above? Routing between MVVM modules is cluttered.

## Advantages
- **Purely state-driven**.
No ObservableObjects, no EnvironmentObjects, no Singletons.
- **Pure SwiftUI**.
- **SwiftUI transitions and animations**.
- **Structured `.sheet()` support**.
No need to remaster the whole codebase to present the view with `.sheet()`. It just works.

## Example

The view hierarchy is managed through the `PathPresenter.Path()` structure.
You can push new views into it using `.append` methods and delete views from the top using `.removeLatest`.

Internally, the view's layout is managed by `ZStack`, so all views history is visible.

Possible presentation ways:
```swift
enum PathType {
  /**
   * Just show a view. No animation, no transition.
   * Show view above all other views
   */
  case plain
  
  /**
   * Show view with in and out transitions.
   * Transition animation also can be specified.
   */
  case animated(transition: AnyTransition, animation: Animation)
  
  /**
   * Show view in .sheet()
   * - Note: If you want to present several views in sheet,
   * you can create a second RoutingView and use it in sheet!
   */
  case sheet(onDismiss: Action)
}
```

Complete example:

<hr>
<img width="800" src="https://i.ibb.co/9ydVzgG/ezgif-com-gif-maker-5.gif">

```swift
struct RootViewGitHub: View {
    @State var path = PathPresenter.Path()

    var body: some View {
        PathPresenter.RoutingView(path: $path) {
            // Root view. Always presented
            VStack {
                Button("Push") {
                    path.append(
                        VStack {
                            Text("Hello from plain push")
                            backButton
                        }.frame(width: 300, height: 300)
                         .background(.white)
                         .border(.red),
                        type: .plain
                    )
                }
                Button("Sheet") {
                    path.append(
                        VStack {
                            Text("Hello from sheet")
                            backButton
                        }.frame(width: 300, height: 300)
                         .background(.white)
                         .border(.red),
                        type: .sheet(onDismiss: {print("dismissed")})
                    )
                }
                Button("Left animation") {
                    path.append(
                        VStack {
                            Text("Hello from left animation")
                            backButton
                        }.frame(width: 300, height: 300)
                         .background(.white)
                         .border(.red),
                        type: .animated(transition: .move(edge: .leading),
                                        animation: .easeIn)
                    )
                }
            }
            .frame(width: 300, height: 300)
        }
    }
    
    var backButton: some View {
        Button("Back") {
            if !path.isEmpty {
                path.removeLast()
            }
        }
    }
}
```
<hr>

## Transitions and animation example
<img width=900 src="https://i.ibb.co/NVwcQp5/ezgif-com-gif-maker-4.gif">

## Documentation

Code is mostly commented and simply structured. Check it out! 

## TODO
- **Path-based routing**. Define view hierarchy with URL-like structures for better views switching architecture
