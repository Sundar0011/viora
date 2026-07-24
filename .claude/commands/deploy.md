---
description: Build, sign, and publish Viora to Google Play and the Apple App Store.
argument-hint: [track / notes]
---
Invoke the release-deployment agent for: $ARGUMENTS

Preconditions to confirm first: tester has verified the build; manager approved; the app points
at Viora's own Supabase PROD config; Android and iOS are at version parity; no signing secrets
are committed.

Then walk both stores:
- Android / Google Play: version bump → signed appbundle → chosen track (internal → closed → prod).
- iOS / App Store: certificates/provisioning → ipa → TestFlight → review → release.
