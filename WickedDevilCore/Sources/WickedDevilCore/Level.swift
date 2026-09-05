import Foundation

/// A level as emitted by `tools/ccbi-converter` (schema 1.0.0).
///
/// Decoding is deliberately tolerant: unknown `kind`/`mode` strings fall back to
/// `.unknown` rather than throwing, so newly converted levels never break the
/// game, and optional sections (`tips`, `projectileSpawners`, `nodeTree`,
/// `validation`) may be absent.
public struct Level: Codable, Equatable, Sendable {
    public var schemaVersion: String
    public var source: Source
    public var coordinateSpace: CoordinateSpace
    public var metadata: Metadata
    public var playerSpawn: Vec2
    public var goal: Goal?
    public var platforms: [PlatformData]
    public var collectables: [CollectableData]
    public var enemies: [EnemyData]
    public var projectileSpawners: [ProjectileSpawnerData]
    public var triggers: [TriggerData]
    public var tips: [TipData]

    public init(
        schemaVersion: String,
        source: Source,
        coordinateSpace: CoordinateSpace,
        metadata: Metadata,
        playerSpawn: Vec2,
        goal: Goal? = nil,
        platforms: [PlatformData] = [],
        collectables: [CollectableData] = [],
        enemies: [EnemyData] = [],
        projectileSpawners: [ProjectileSpawnerData] = [],
        triggers: [TriggerData] = [],
        tips: [TipData] = []
    ) {
        self.schemaVersion = schemaVersion
        self.source = source
        self.coordinateSpace = coordinateSpace
        self.metadata = metadata
        self.playerSpawn = playerSpawn
        self.goal = goal
        self.platforms = platforms
        self.collectables = collectables
        self.enemies = enemies
        self.projectileSpawners = projectileSpawners
        self.triggers = triggers
        self.tips = tips
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try container.decode(String.self, forKey: .schemaVersion)
        source = try container.decode(Source.self, forKey: .source)
        coordinateSpace = try container.decode(CoordinateSpace.self, forKey: .coordinateSpace)
        metadata = try container.decode(Metadata.self, forKey: .metadata)
        playerSpawn = try container.decode(Vec2.self, forKey: .playerSpawn)
        goal = try container.decodeIfPresent(Goal.self, forKey: .goal)
        platforms = try container.decodeIfPresent([PlatformData].self, forKey: .platforms) ?? []
        collectables = try container.decodeIfPresent([CollectableData].self, forKey: .collectables) ?? []
        enemies = try container.decodeIfPresent([EnemyData].self, forKey: .enemies) ?? []
        projectileSpawners = try container.decodeIfPresent([ProjectileSpawnerData].self, forKey: .projectileSpawners) ?? []
        triggers = try container.decodeIfPresent([TriggerData].self, forKey: .triggers) ?? []
        tips = try container.decodeIfPresent([TipData].self, forKey: .tips) ?? []
    }

    // MARK: - Nested models

    public struct Source: Codable, Equatable, Sendable {
        public var ccbi: String?
        public var world: Int
        public var level: Int

        public init(ccbi: String? = nil, world: Int, level: Int) {
            self.ccbi = ccbi
            self.world = world
            self.level = level
        }
    }

    public struct CoordinateSpace: Codable, Equatable, Sendable {
        public var kind: String
        public var logicalViewport: SizeF
        public var notes: String?

        public init(kind: String = "points", logicalViewport: SizeF, notes: String? = nil) {
            self.kind = kind
            self.logicalViewport = logicalViewport
            self.notes = notes
        }
    }

    public struct Metadata: Codable, Equatable, Sendable {
        public var theme: String
        public var backgroundImage: String
        public var timeLimitSeconds: Int
        public var topBoundaryY: Double
        public var nodeCount: Int?
        public var timelineNames: [String]?
        public var autoPlaySequenceId: Int?

        public init(
            theme: String,
            backgroundImage: String,
            timeLimitSeconds: Int,
            topBoundaryY: Double,
            nodeCount: Int? = nil,
            timelineNames: [String]? = nil,
            autoPlaySequenceId: Int? = nil
        ) {
            self.theme = theme
            self.backgroundImage = backgroundImage
            self.timeLimitSeconds = timeLimitSeconds
            self.topBoundaryY = topBoundaryY
            self.nodeCount = nodeCount
            self.timelineNames = timelineNames
            self.autoPlaySequenceId = autoPlaySequenceId
        }
    }

    public struct Goal: Codable, Equatable, Sendable {
        public var requiresBigCollectables: Int
        public var platformId: String?
        public var position: Vec2?

        public init(requiresBigCollectables: Int, platformId: String? = nil, position: Vec2? = nil) {
            self.requiresBigCollectables = requiresBigCollectables
            self.platformId = platformId
            self.position = position
        }
    }

    public struct Tint: Codable, Equatable, Sendable {
        public var r: Int
        public var g: Int
        public var b: Int
    }

    /// Union of every `behavior` payload the converter emits. Fields are
    /// optional because each mode only populates the ones it needs.
    public struct Behavior: Codable, Equatable, Sendable {
        public var mode: String
        public var offset: Vec2?
        public var durationSeconds: Double?
        public var jumpMultiplier: Double?
        public var controlsTags: [Int]?
        public var group: Int?
        public var initiallyEnabled: Bool?
        public var health: Double?
        public var fallDistance: Double?
        public var fallDurationSeconds: Double?
        public var moveOffset: Vec2?
        public var moveDurationSeconds: Double?
        public var requiresBigCollectables: Int?
        public var completionDelaySeconds: Double?
        public var direction: String?
        public var speedPerFrame: Double?
        public var wrapsAtViewportEdge: Bool?
        public var contactEffect: String?
        public var verticalTravel: Double?
        public var tapToPop: Bool?
        public var triggerRadius: Double?
        public var projectileSpeed: Double?
        public var spawnX: Double?
        public var verticalOffset: Double?
        public var immunePowerup: Int?
        public var destinationChildTag: Int?
        public var cycleSeconds: Double?

        /// The ping-pong movement this behavior describes, if any.
        public var motion: NodeMotion? {
            if let offset, let durationSeconds {
                return NodeMotion(offset: offset, durationSeconds: durationSeconds)
            }
            if let moveOffset, let moveDurationSeconds {
                return NodeMotion(offset: moveOffset, durationSeconds: moveDurationSeconds)
            }
            return nil
        }
    }

    public struct PlatformData: Codable, Equatable, Sendable {
        public var id: String
        public var position: Vec2
        public var size: SizeF
        public var rotationDegrees: Double?
        public var spriteFrame: String?
        public var spriteSheet: String?
        public var tint: Tint?
        public var opacity: Int?
        public var visible: Bool?
        public var legacyTag: Int?
        public var kind: String
        public var behavior: Behavior?
    }

    public struct CollectableData: Codable, Equatable, Sendable {
        public var id: String
        public var position: Vec2
        public var size: SizeF
        public var rotationDegrees: Double?
        public var spriteFrame: String?
        public var spriteSheet: String?
        public var tint: Tint?
        public var opacity: Int?
        public var visible: Bool?
        public var kind: String
        public var value: Int?
    }

    public struct EnemyData: Codable, Equatable, Sendable {
        public var id: String
        public var position: Vec2
        public var size: SizeF
        public var rotationDegrees: Double?
        public var spriteFrame: String?
        public var spriteSheet: String?
        public var tint: Tint?
        public var opacity: Int?
        public var visible: Bool?
        public var legacyTag: Int?
        public var kind: String
        public var behavior: Behavior?
    }

    public struct ProjectileSpawnerData: Codable, Equatable, Sendable {
        public var id: String
        public var kind: String
        public var sourceEnemyId: String
        public var launchPosition: Vec2
        public var projectileSpeed: Double
        public var targeting: String?
    }

    public struct TriggerData: Codable, Equatable, Sendable {
        public var id: String
        public var position: Vec2
        public var size: SizeF
        public var rotationDegrees: Double?
        public var spriteFrame: String?
        public var spriteSheet: String?
        public var tint: Tint?
        public var opacity: Int?
        public var visible: Bool?
        public var legacyTag: Int?
        public var kind: String
    }

    public struct TipData: Codable, Equatable, Sendable {
        public var id: String
        public var position: Vec2
        public var size: SizeF
        public var spriteFrame: String?
        public var visible: Bool?
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion, source, coordinateSpace, metadata, playerSpawn, goal
        case platforms, collectables, enemies, projectileSpawners, triggers, tips
    }
}

// MARK: - Loading

extension Level {
    public static func decode(from data: Data) throws -> Level {
        try JSONDecoder().decode(Level.self, from: data)
    }

    public static func load(contentsOf url: URL) throws -> Level {
        try decode(from: Data(contentsOf: url))
    }

    /// Time limit the original derived from the top boundary height. The
    /// converter precomputes the same value into `metadata.timeLimitSeconds`.
    public var derivedTimeLimitSeconds: Int {
        GameConstants.timeLimit(forTopBoundaryY: metadata.topBoundaryY)
    }

    public var requiredBigCollectables: Int {
        goal?.requiresBigCollectables ?? 1
    }
}

// MARK: - Runtime entity construction

extension Level {
    /// Builds the mutable runtime objects for this level.
    public func makeEntities() -> LevelEntities {
        LevelEntities(
            platforms: platforms.map(Level.makePlatform),
            collectables: collectables.map(Level.makeCollectable),
            enemies: enemies.map(Level.makeEnemy),
            triggers: triggers.map(Level.makeTrigger),
            tips: tips.map(Level.makeTip)
        )
    }

    static func makePlatform(_ data: PlatformData) -> Platform {
        let kind = PlatformKind(rawValue: data.kind) ?? PlatformKind.from(legacyTag: data.legacyTag)
        let toggleGroup: Int?
        switch data.legacyTag {
        case 51: toggleGroup = 1
        case 52: toggleGroup = 2
        default: toggleGroup = data.behavior?.group
        }
        return Platform(
            id: data.id,
            position: data.position,
            contentSize: data.size,
            kind: kind,
            legacyTag: data.legacyTag,
            motion: data.behavior?.motion,
            toggleGroup: toggleGroup,
            requiresBigCollectables: data.behavior?.requiresBigCollectables ?? 1,
            health: data.behavior?.health ?? 1.0,
            // Tag 52 platforms start switched off.
            dead: data.behavior?.initiallyEnabled.map { !$0 } ?? false,
            visible: data.visible ?? true
        )
    }

    static func makeCollectable(_ data: CollectableData) -> Collectable {
        Collectable(
            id: data.id,
            position: data.position,
            contentSize: data.size,
            kind: CollectableKind(rawValue: data.kind) ?? .small,
            value: data.value ?? 1,
            visible: data.visible ?? true
        )
    }

    static func makeEnemy(_ data: EnemyData) -> Enemy {
        let kind = EnemyKind(rawValue: data.kind) ?? EnemyKind.from(legacyTag: data.legacyTag)
        let direction: PatrolDirection? = kind == .bat
            ? PatrolDirection(rawValue: data.behavior?.direction ?? "right") ?? .right
            : nil
        return Enemy(
            id: data.id,
            position: data.position,
            contentSize: data.size,
            kind: kind,
            legacyTag: data.legacyTag,
            patrolDirection: direction,
            motion: data.behavior?.motion,
            visible: data.visible ?? true
        )
    }

    static func makeTrigger(_ data: TriggerData) -> Trigger {
        Trigger(
            id: data.id,
            position: data.position,
            contentSize: data.size,
            kind: TriggerKind(rawValue: data.kind) ?? .trigger,
            legacyTag: data.legacyTag,
            visible: data.visible ?? true
        )
    }

    static func makeTip(_ data: TipData) -> Tip {
        Tip(
            id: data.id,
            position: data.position,
            contentSize: data.size,
            visible: data.visible ?? true
        )
    }
}

/// The mutable runtime objects built from a `Level`.
public struct LevelEntities {
    public var platforms: [Platform]
    public var collectables: [Collectable]
    public var enemies: [Enemy]
    public var triggers: [Trigger]
    public var tips: [Tip]

    public init(
        platforms: [Platform] = [],
        collectables: [Collectable] = [],
        enemies: [Enemy] = [],
        triggers: [Trigger] = [],
        tips: [Tip] = []
    ) {
        self.platforms = platforms
        self.collectables = collectables
        self.enemies = enemies
        self.triggers = triggers
        self.tips = tips
    }
}
