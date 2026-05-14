# VFX System

VFX covers weapon trails, slash effects, hit effects, skill effects and preview/tuning tools.

## Key scripts/modules

- `ReplicatedStorage.Modules.WeaponVFX`
- `ReplicatedStorage.Modules.ItemData`
- `StarterPlayer.StarterPlayerScripts.Controllers.CombatController`
- `StarterPlayer.StarterPlayerScripts.Controllers.VFXTunerController`
- `ReplicatedStorage.VFX`

## VFXEntry schema

From `ItemData`:

```lua
export type VFXEntry = {
    Marker: string,           -- Animation marker name (e.g. "SlashVFX")
    VFXPath: string,          -- Template path in ReplicatedStorage (e.g. "VFX.Slash.Slash-01")
    AttachTo: "RightArm" | "RightHand" | "Weapon" | "HitPoint",
    OffsetCFrame: CFrame?,    -- Offset from attachment point
    Lifetime: number?,        -- Effect lifetime in seconds (default 0.5)
    Scale: number?,
    TimeScale: number?,
    EmitCount: number?,
    ComboHit: number?,        -- Combo hit number (1-4). nil = applies to all hits
}

export type VFXConfig = {
    SlashVFX: {VFXEntry}?,    -- Slash/swing effects
    HitVFX: {VFXEntry}?,      -- Hit/impact effects
}

export type TrailConfig = {
    Enabled: boolean?,
    Lifetime: number?,         -- Trail duration in seconds (default 0.3)
    LightEmission: number?,   -- Glow 0-1 (default 0.8)
    LightInfluence: number?,   -- Light influence 0-1 (default 0.2)
    FaceCamera: boolean?,     -- Face camera (default true)
    Color: ColorSequence?,
    Transparency: NumberSequence?,
    WidthScale: NumberSequence?,
    StartMarker: string?,     -- Animation marker to enable (default "TrailStart")
    EndMarker: string?,       -- Animation marker to disable (default "TrailEnd")
}
```

## Current VFX assets

- `ReplicatedStorage.VFX.Slash` — slash effects (Slash-01, Fire-Slash-01, Slashes-01, Slash-02, Slash-Impact-01)
- `ReplicatedStorage.VFX.Hit` — hit effects (HitEffect)
- `ReplicatedStorage.VFX.Skill` — skill effects (Skill1, Skill2)
- `ReplicatedStorage.StompMaki2Skill` — Maki power strike skill VFX

## Invariants

- Temporary VFX must clean themselves after lifetime.
- Preview VFX should clean previous preview roots.
- Weapon trail setup should preserve intended attachment orientation.
- Gameplay VFX should not become an authoritative hit source.

## Testing checklist

- Weapon trail appears only during intended animation windows.
- Slash/hit/skill effects spawn at intended location.
- Repeated attacks do not leave orphaned effects.
- VFX tuner preview can spawn and clear effects.
- Performance remains acceptable under repeated casts.

## Open questions

- Document exact `ItemData.VFXEntry` schema after next VFX pass.
- Document marker names used by animations.
- Document current VFX asset paths and intended attachment points.
