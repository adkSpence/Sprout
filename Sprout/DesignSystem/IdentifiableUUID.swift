import Foundation

/// Wraps a bare `UUID` so it can be used with `.sheet(item:)`, which needs an
/// `Identifiable` value rather than a plain optional.
struct IdentifiableUUID: Identifiable {
    let id: UUID
}
