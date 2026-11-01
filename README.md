# TradeNPC

Trade an NPC up to 8 stacks of items and gil with a single command.

## Command Usage

```text
tradenpc <quantity> <item name> [npc name]
```

### Features

- Supports gil trades
- Supports multiple items per command
- Accepts auto-translate, short, or full item names
- Supports trading all copies of an item
- Supports automated crystal trading

## Examples

```text
//tradenpc 100 "1 byne bill"

//tradenpc 792 alexandrite

//tradenpc all "Wind Crystal"

//tradenpc crystals "Ephemeral Moogle"
```

---

# TradeNPC (VC - Enhanced)

Enhanced version of the original TradeNPC addon by **Ivaar** for **Final Fantasy XI**.

## New Features

### Trade All Items

Trade every copy of a specific item:

```text
//tradenpc all "Wind Crystal"
```

### Automated Crystal Trading

Trade all crystal types with a single command:

```text
//tradenpc crystals "Ephemeral Moogle"
```

or

```text
//tradenpc allcrystals
```

Supported crystal types:

- Fire Crystal
- Ice Crystal
- Wind Crystal
- Earth Crystal
- Lightning Crystal
- Water Crystal
- Light Crystal
- Dark Crystal

### Automatic Multi-Trade Processing

FFXI is limited to **8 inventory slots per trade**.

When more than 8 crystal stacks are present, TradeNPC will:

1. Fill all available trade slots
2. Send the trade
3. Wait for the configured delay
4. Rescan inventory
5. Continue trading automatically

The process repeats until all eligible crystals have been traded.

No re-targeting or multiple commands required.

### Crystal Exclusions

Specific crystal types can be excluded from automatic trading:

```lua
excluded_crystals = {
    ['light crystal'] = true,
    ['light crystals'] = true,
}
```

Useful for keeping crafting crystals while trading everything else.

## Improvements

- Automatic crystal batching
- Continuous multi-trade processing
- Configurable crystal exclusions
- Improved inventory handling
- Better trade slot utilization
- Eliminates long crystal-trading aliases

## Usage Examples

Trade all copies of an item:

```text
//tradenpc all "Wind Crystal"
```

Trade all crystals:

```text
//tradenpc crystals
```

Trade all crystals to the Ephemeral Moogle:

```text
//tradenpc crystals "Ephemeral Moogle"
```

## Installation

1. Replace your existing `TradeNPC.lua`
2. Configure any desired crystal exclusions
3. Reload the addon:

```text
//lua r tradenpc
```

## Credits

**Original Addon:** Ivaar

**Enhancements:** VC-MSCP (Vibe Coding with Microsoft Copilot)

### Added Enhancements

- Trade-all support
- Automated crystal detection
- Continuous crystal batch trading
- Crystal exclusion configuration
- Improved inventory handling

## License

This project retains the original TradeNPC license by Ivaar.
