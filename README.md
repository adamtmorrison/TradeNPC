# TradeNPC

Trade an npc up to 8 stacks of items and gil with a single command.

### Command Usage:
```
tradenpc <quantity> <item name> [npc name]
```

Quantities greater than an items stack size are accepted, if you specify too many items the trade will not occur.

For gil CSV and EU decimal mark are optional. e.g. 100000 or 100,000 or 100.000

Accepts auto-translate, short or full item name.

If the item name is more than one word you must use quotes or auto-translate.

Multiple items can be traded in one command.

If trading gil it must be the first set of arguments or the trade will not occur.

If you need to exceed the chatlog character limit, you can type the command from console or execute via a txt script.

### Examples

```
//tradenpc 100 "1 byne bill"

//tradenpc 792 alexandrite

//tradenpc 10,000 gil 24 "fire crystal" 12 "earth crystal" 18 "water crystal" 6 "dark crystal" "Ephemeral Moogle"
```
# TradeNPC (VC - Enhanced)

An enhanced version of the original **TradeNPC** Windower addon by Ivaar for **Final Fantasy XI**.

This version improves automated trading and introduces new functionality for efficiently trading crystals—especially to the **Ephemeral Moogle**.

---

## ✅ Overview

The original TradeNPC addon allows players to trade items to NPCs using commands.

This enhanced version adds:

- Automatic **“trade all”** support
- A new **crystal batch trading command**
- Improved handling of **inventory stacks**

These updates remove the need for manual counting and simplify repetitive trading tasks.

---

## 🚀 New Features

### 🔹 Trade All Items (`all` keyword)

Automatically trade all copies of an item in your inventory:
```
//tradenpc all "Wind Crystals" "Ephemeral Moogle"
````
### Behavior:

Scans inventory
Totals all matching items
Trades the full amount automatically


### 🔹 Trade All Crystal Types (crystals command)
Quickly trade every crystal type you have:
```
//tradenpc crystals "Ephemeral Moogle"
```
or:
```
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

Behavior:

- Detects all crystal types in inventory
- Totals each type individually
- Builds a trade using available stacks
- Sends a single trade request to the target NPC

🔧 Improvements
✅ Smarter Inventory Handling
- Aggregates items across multiple stacks
- Supports mixed partial stacks
- Prevents failures when items are split across slots

✅ Improved Trade Slot Selection
- Prioritizes full stacks when possible
- Falls back to largest available partial stacks
- Ensures more reliable trade construction

🔁 Preserved Features
All original functionality is maintained:
- Standard quantity-based trades still work
- NPC targeting by name is unchanged

⚠️ Limitations
This addon still follows FFXI trade system constraints:
- Trades are sent as a single packet
- Limited number of item slots per trade

### Important:
If you see:
```
Too many items. This trade would require more than 8 trade slots.
```
You will need to run the command multiple times.

### 📘 Usage Examples
Trade all of one item:
```
//tradenpc all "Wind Crystal"
```
Trade all crystals to Ephemeral Moogle:
```
//tradenpc crystals "Ephemeral Moogle"
```
Trade all crystals (target already selected):
```
//tradenpc crystals
```
🛠 Installation

Replace your existing TradeNPC.lua with this version
Reload the addon in-game:
```
//lua r tradenpc
```
🙌 Credits
Original addon: Ivaar
Enhancements done via: VC-MSCP (Vibe coding using Microsoft CoPilot)
Enhancements: Updated version with automated inventory handling and crystal trading support

📜 License
This project retains the original TradeNPC license by Ivaar.
