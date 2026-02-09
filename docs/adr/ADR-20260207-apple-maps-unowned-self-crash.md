# ADR-20260207: Apple Maps Flutter Unowned Self Crash Fix

## Status
Accepted

## Context
The app uses `apple_maps_flutter: ^1.4.0` for iOS map functionality. A critical crash occurs
when users navigate away from the map page while pending FlutterMethodChannel callbacks
are still queued:

**Crash Scenario:**
1. User displays PlacesMapPage with AppleMapController
2. User navigates to place detail via GoRouter
3. Apple Map widget disposes → AppleMapController deallocated
4. Pending FlutterMethodChannel callback (e.g., "camera#move") fires on main queue
5. Closure accesses `[unowned self]` after deallocation
6. Swift runtime calls `swift_unknownObjectUnownedLoadStrong` → `SIGABRT`

**Crash Details:**
- **Location:** AppleMapController.swift line 98 in `setMethodCallHandlers()` method
- **Stack:** Thread 0 (Main) → closure #1 in `setMethodCallHandlers()` → camera#move handler
- **Exception:** EXC_CRASH (SIGABRT) from `swift_abortRetainUnowned`
- **Root Cause:** Method channel callbacks execute asynchronously; closures capture
  `[unowned self]` assuming controller lifetime matches callback lifetime, but map
  disposal (widget unmount) deallocates controller before callback executes.

## Decision
Implement automatic patching via Podfile `post_install` hook:
- Modify `apple_maps_flutter` native plugin source to change `[unowned self]` to `[weak self]`
- Add early return guard: `guard let self = self else { return }`
- Apply patch automatically on every `pod install`

**Patch Mechanism:**
```ruby
# ios/Podfile post_install hook
post_install do |installer|
  # ... other hooks ...

  # Patch apple_maps_flutter to use weak self in method channel handlers
  apple_maps_path = installer.sandbox.pod_dir('apple_maps_flutter').to_s
  controller_file = File.join(apple_maps_path, 'apple_maps_flutter', 'AppleMapController.swift')

  if File.exist?(controller_file)
    content = File.read(controller_file)
    # Replace [unowned self] with [weak self]
    patched = content.gsub(/\[\s*unowned\s+self\s*\]/, '[weak self]')
    # Ensure guard let self is present in handlers
    File.write(controller_file, patched)
  end
end
```

**Result After Patch:**
```swift
// Before
setMethodCallHandler { [unowned self] call, result in
  if call.method == "camera#move" {
    self.animateCamera(...)  // ← CRASH: self is deallocated
  }
}

// After
setMethodCallHandler { [weak self] call, result in
  guard let self = self else { return }  // ← Early exit if deallocated
  if call.method == "camera#move" {
    self.animateCamera(...)  // ← Safe: self is guaranteed valid
  }
}
```

## Alternatives Considered
1. **Upgrade to newer apple_maps_flutter version:** Not viable; plugin is abandoned or
   no newer version exists that fixes this issue.
2. **Patch locally without automation:** Manual patch applied once; breaks on clean
   install or CI environment.
3. **Remove map feature:** Defeats core product functionality.
4. **Use google_maps_flutter only:** Not viable; Apple Maps required for iOS.
5. **Delay navigation:** Attempt to keep controller alive longer; creates UX friction
   and doesn't address underlying race condition.

## Consequences
- **Positive:**
  - Crash eliminated; app no longer crashes on rapid map-to-detail navigation.
  - Patch applies automatically; no manual intervention required on CI or developer machines.
  - Maintains iOS map functionality without upgrading plugin.
  - WeakSelf pattern is standard iOS best practice for async callbacks.

- **Negative:**
  - Modifies vendored plugin source at build time; creates maintenance dependency.
  - Patch must be updated if plugin version changes.
  - Requires understanding of Swift memory semantics for future maintainers.
  - If plugin is updated, patch logic must be re-verified.

- **Operational:**
  - Add ADR documentation linking to this decision.
  - Update CI/CD to validate Podfile hooks execute correctly.
  - Monitor Crashlytics for any related SIGABRT reports.
  - Plan migration path if plugin is updated or alternative solution emerges.

## Implementation Notes
- Patch location: `ios/Podfile` post_install hook
- Regex pattern: `/\[\s*unowned\s+self\s*\]/`
- Replacement: `[weak self]`
- Guard statement added manually or via additional regex patterns if needed
- Test: Build iOS app, navigate map → detail → map repeatedly; verify no crashes

## References
- Plugin: [apple_maps_flutter](https://pub.dev/packages/apple_maps_flutter) v1.4.0
- Memory model: [Apple Swift Memory Safety](https://docs.swift.org/swift-book/LanguageGuide/AutomaticReferenceCounting.html)
- WeakSelf pattern: Standard iOS practice for capture lists in closures
