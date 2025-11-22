# Block & Role — Manifesto

A cooperative exploration-first RPG built on Luanti (formerly Minetest). Move with purpose, fight with skill, learn by discovery, trade with intent. Nothing is wasted; everything transforms.

## Vision
Block & Role is a systemic, replayable RPG that rewards exploration, cooperation, and mastery over static hoarding or vanity building. The world is alive with ecologies, quests, and challenges that push players out into the unknown and pull them back together to craft solutions.

## Core Tenets
- Exploration over stasis: the world invites travel, discovery, and change.
- Cooperation by default: single-player compatible, co-op oriented, optional PvP.
- Meaningful combat: melee, ranged, explosives, and magic that reflect player skill and build choices.
- Learning by doing and discovery: skills improve through play; alchemy is knowledge, not grind.
- Conservation: nothing is created or destroyed; all resources transform.
- Clean economy: gold mints coins; gold never crafts items. No voluntary item dropping.

## Player Experience Goals
- Purposeful movement: short trips on foot; long distances via jump gates.
- Clear roles without hard locks: races and skills shape playstyle, not restrict it.
- Continuous progression: every session moves skills, knowledge, and network forward.
- Low friction, high signal: minimal busywork, rich decisions, visible outcomes.

## World & Ecologies
- Data-driven biomes ("ecologies") define terrain, flora/fauna, resources, landmarks, and local events.
- Per-world seeds ensure unique alchemy mappings and ecological variation across new games.
- Landmarks and region-specific encounters drive quests and trade routes.

## Races
- Human (balanced), Dwarf (tanky), Elf (agile). Races grant base attributes that synergize with skill choices and gear.

## Combat & Tools
- Weapons: blades, blunts, axes, knives; bows and firearms; grenades; spells.
- Tools and weapons derive their effective capabilities from:
  - The item's intrinsic properties and modifications (runes, stones, sockets).
  - The wielder's current attributes and skills.
  - Context (e.g., ecology effects), when relevant.
- Server-authoritative updates keep wielded items aligned with player state without manual "place" actions.

## Magic & Alchemy
- Magic is a first-class path: spells, resource costs, cooldowns, and synergy with skills.
- Alchemy is not a skill but world knowledge:
  - Each world seeds a unique mapping of ingredients to active principles.
  - Players discover effects experimentally; knowledge persists per world.

## Skills & Progression (Skill Tree)
Investment-focused tree with branches:
- Crafting: Technological, Defense, Offense (unlock recipes, improve outputs).
- Tool Empowerment: runes/stones/sockets and their efficacy.
- Combat: close-range (melee) and long-range (archery, firearms, explosives).
- Magic: spellcraft and mana control.
- Trade: selling and buying as separate proficiencies.
- Mining: extraction efficiency and technique.
- Crafting Efficiency: throughput and waste reduction (separate from unlocking).
- Building: purposeful construction efficiency (mission-linked).
- Orientation: exploration, cartography, landmark sensing.
- Medical: healing, stabilization, support in co-op.
- Stealth: detection reduction, ambush benefits (balanced for optional PvP).

Progression is simple to reason about using a 1–10–100 scale for tiers, rewards, and costs. Detailed balance is deferred to playtesting.

## Economy & Commerce
- Coins are minted from gold; gold never appears in crafting recipes.
- Shops (NPC and structures) handle all exchanges; voluntary item drop is disabled.
- Sinks (e.g., gate upkeep, services) prevent runaway inflation.
- Analytics inform dynamic pricing and availability without breaking conservation.

## Movement & Flow
- No pets or vehicles (no horses, trains, planes).
- Long-range travel via jump gates with clear costs and constraints.
- World layout and gate networks encourage regional specializations and trade.

## Quests & NPCs
- Modular goals: dig/place/craft/talk/escort/explore/combat.
- Chains and dependencies guide narrative and progression.
- Rewards support the core loop: coins, XP, blueprints, access, knowledge.

## Integrity & Safety
- Server-authority: item capabilities, currency, and critical state are validated server-side.
- No voluntary dropping; secure, atomic trades via shops and UI flows.
- Anti-abuse logging and rate-limiting for generation and transformation actions.

## Accessibility & UX
- Clear, readable UI for skill tree, quests, shops, and gates.
- Tooltips and previews for decisions (what changes if I invest?).
- Minimal steps to act; explicit feedback after meaningful actions.

## Architecture (High-Level Modules)
- Core: world rules, wield-change events, configuration, seed management.
- RPG Tools: item meta (runes/sockets), server-side capability synthesis.
- XP & Skills: XP accrual, skill points, investment, triggers for capability updates.
- Quests: goals, rewards, chaining, integration with ecologies.
- Money: wallets, atomic transfers, sinks, logs.
- NPCs & Shops: dialogs, offers, trades.
- Mobs & Combat: spawns, AI, loot transformation (no drop).
- Ecologies: biomes, resources, landmarks, per-world alchemy mapping.
- Gates: jump gates, costs/cooldowns, maintenance.
- (Optional) Analytics: economic telemetry, price suggestions.

These map conceptually to existing inspiration work (e.g., rpg_tool, rpgtest modules, goldstandard analytics, xp frameworks) but are restructured for clarity and reliability.

## Balance Framework
- Use a universal 1–10–100 scale for tiers, rewards, costs, and challenge sizing to keep the prototype legible.
- Deeper tuning is deferred to iterative playtests.

## Non-Goals
- Vanity-first city building without gameplay purpose.
- Vehicles, pets, or passive automation that reduce the value of exploration and cooperation.

## Roadmap (Prototype-Oriented)
1) Foundation: core rules, wield-capability sync, basic skills, and a minimal combat loop.
2) Quests & Shops: guided exploration, coin rewards, coherent sinks.
3) World & Gates: ecologies, spawns, landmarks, jump network.
4) Alchemy & Magic: seed-based discovery, basic spell paths.
5) Analytics & Tuning: telemetry, pricing, skill pacing, and encounter balance.

## Community & License
- Build openly, document decisions, and prioritize playtest feedback.
- Favor modular contributions and clear APIs.
- License: choose a permissive, community-friendly license consistent with Luanti/Minetest ecosystem norms.

—
Block & Role invites players to venture out, team up, and grow through meaningful choices. If it doesn't push you to explore or collaborate, it doesn't belong.
