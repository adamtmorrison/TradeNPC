require('pack')
bit = require('bit')
res_items = require('resources').items

_addon.name = 'TradeNPC'
_addon.author = 'Ivaar + Copilot update'
_addon.version = '1.21.07.1'
_addon.command = 'tradenpc'

local settings = {
    trade_delay = 2.0,

    excluded_crystals = {
        ['fire crystal'] = true,
        ['ice crystal'] = false,
        ['wind crystal'] = false,
        ['earth crystal'] = false,
        ['lightning crystal'] = false,
        ['water crystal'] = false,
        ['light crystal'] = false,
        ['dark crystal'] = false,

        ['fire crystals'] = true,
        ['ice crystals'] = false,
        ['wind crystals'] = false,
        ['earth crystals'] = false,
        ['lightning crystals'] = false,
        ['water crystals'] = false,
        ['light crystals'] = true,
        ['dark crystals'] = false,
    }
}

local crystal_trade_active = false
local crystal_trade_target = nil
local crystal_names = {
    'fire crystal',
    'ice crystal',
    'wind crystal',
    'earth crystal',
    'lightning crystal',
    'water crystal',
    'light crystal',
    'dark crystal',
	'fire crystals',
    'ice crystals',
    'wind crystals',
    'earth crystals',
    'lightning crystals',
    'water crystals',
    'light crystals',
    'dark crystals',
}

function get_item_res(item)
    item = item and item:lower() or ''
    for _, v in pairs(res_items) do
        if v.en and v.en:lower() == item then
            return v
        end
        if v.enl and v.enl:lower() == item then
            return v
        end
    end
    return nil
end

function get_inventory_item_total(inventory, item_id)
    local total = 0
    for _, v in ipairs(inventory) do
        if v.id == item_id and v.status == 0 then
            total = total + v.count
        end
    end
    return total
end

function find_item_for_trade(inventory, item_id, wanted_count, exclude)
    local best_index = nil
    local best_count = 0

    for k, v in ipairs(inventory) do
        if v.id == item_id and v.count > 0 and v.status == 0 and not exclude[k] then
            if v.count >= wanted_count then
                return k, wanted_count
            end

            if v.count > best_count then
                best_index = k
                best_count = v.count
            end
        end
    end

    if best_index then
        return best_index, best_count
    end

    return nil, 0
end

function format_price(price)
    price = not string.match(price, '%a') and price:gsub('%p', '')
    price = price and tonumber(price)
    if price and price > 0 then
        return price
    end
    return nil
end

function add_item_to_trade(inventory, exclude, ind, qty, item, units, label)
    while units > 0 do
        local wanted_count = item.stack and item.stack > 0 and math.min(units, item.stack) or 1
        local index, trade_count = find_item_for_trade(inventory, item.id, wanted_count, exclude)

        if not index then
            print(('%s x%s not found in inventory.'):format(item.name, label or tostring(units)))
            return false
        end

        exclude[index] = true
        ind[#ind + 1] = index
        qty[#qty + 1] = trade_count
        units = units - trade_count
    end

    return true
end

function add_all_crystals_to_trade(inventory, exclude, ind, qty)
    local found_any = false

    for _, crystal_name in ipairs(crystal_names) do

        if not settings.excluded_crystals[crystal_name] then

            local item = get_item_res(crystal_name)

            if item then
                for k, v in ipairs(inventory) do

                    if #ind >= 8 then
                        return true
                    end

                    if v.id == item.id
                    and v.count > 0
                    and v.status == 0
                    and not exclude[k] then

                        exclude[k] = true

                        ind[#ind + 1] = k
                        qty[#qty + 1] = v.count

                        found_any = true
                    end
                end
            end
        end
    end

    return found_any
end

function send_next_crystal_trade()

    if not crystal_trade_active then
        return
    end

    local inventory = windower.ffxi.get_items(0)

    if not inventory then
        crystal_trade_active = false
        return
    end

    local ind = {}
    local qty = {}
    local exclude = {}

    local found = add_all_crystals_to_trade(
        inventory,
        exclude,
        ind,
        qty
    )

    if not found then
        print('[TradeNPC] Crystal trading complete.')
        crystal_trade_active = false
        return
    end

    local num = #ind

    for x = num, 8 do
        ind[x + 1] = 0
        qty[x + 1] = 0
    end

    local menu_item = 'C4I11C10HI':pack(
        0x36, 0x20, 0x00, 0x00,
        crystal_trade_target.id,

        qty[1], qty[2], qty[3], qty[4],
        qty[5], qty[6], qty[7], qty[8],
        qty[9], 0x00,

        ind[1], ind[2], ind[3], ind[4],
        ind[5], ind[6], ind[7], ind[8],
        ind[9], 0x00,

        crystal_trade_target.index,
        num
    )

    windower.packets.inject_outgoing(
        0x36,
        menu_item
    )

    coroutine.schedule(function()

        if crystal_trade_active then
            send_next_crystal_trade()
        end

    end, settings.trade_delay)

end

windower.register_event('addon command', function(...)
    local args = {...}

    if #args < 1 then
        print('tradenpc <quantity|all> <item name> [target name]')
        print('tradenpc crystals [target name]')
        print('e.g. //tradenpc 100 "1 byne bill"')
        print('e.g. //tradenpc all "Wind Crystals" "Ephemeral Moogle"')
        print('e.g. //tradenpc crystals "Ephemeral Moogle"')
        return
    end

    if windower.ffxi.get_mob_by_target('me').status ~= 0 then
        return
    end

    local target = windower.ffxi.get_mob_by_target('t')

    -- Subcommand mode: //tradenpc crystals "Ephemeral Moogle"
    if args[1] and (args[1]:lower() == 'crystals' or args[1]:lower() == 'allcrystals') then
        if #args >= 2 then
            target = windower.ffxi.get_mob_by_name(args[#args])
        end

        if not (target and target.is_npc and bit.band(target.spawn_type, 2) == 2 and target.valid_target and target.distance <= 35.9) then
            print('No target or too far away.')
            return
        end

       crystal_trade_target = target
		crystal_trade_active = true

		send_next_crystal_trade()


        return
    end

    -- Original quantity/item mode
    if #args < 2 then
        print('tradenpc <quantity|all> <item name> [target name]')
        print('e.g. //tradenpc all "Wind Crystals" "Ephemeral Moogle"')
        return
    end

    if #args % 2 == 1 then
        target = windower.ffxi.get_mob_by_name(args[#args])
        args[#args] = nil
    end

    if target and target.is_npc and bit.band(target.spawn_type, 2) == 2 and target.valid_target and target.distance <= 35.9 then
        local ind = {}
        local qty = {}
        local start = 1

        if args[2] and args[2]:lower() == 'gil' then
            local units = format_price(args[1])
            if not units or units > windower.ffxi.get_items('gil') then
                print('Invalid gil amount')
                return
            end
            ind[1] = 0
            qty[1] = units
            start = 2
        end

        local inventory = windower.ffxi.get_items(0)
        if not inventory then return end

        local exclude = {}

        for x = start, 9 do
            if not args[x * 2] then
                break
            end

            local units_arg = tostring(args[x * 2 - 1]):lower()
            local name = windower.convert_auto_trans(args[x * 2]):lower()
            local item = get_item_res(name)

            if not item or item.flags['Linkshell'] == true then
                print(('"%s" not a valid item name: arg %d'):format(name, x * 2))
                return
            end

            local units
            if units_arg == 'all' then
                units = get_inventory_item_total(inventory, item.id)
                if not units or units < 1 then
                    print(('%s not found in inventory.'):format(item.name))
                    return
                end
            else
                units = tonumber(units_arg)
                if not units or units < 1 then
                    print(('Invalid quantity: arg %d'):format(x * 2 - 1))
                    return
                end
            end

            local ok = add_item_to_trade(inventory, exclude, ind, qty, item, units, args[x * 2 - 1])
            if not ok then
                return
            end
        end

        local num = #ind
        if num > 0 and num < start + 8 then
            for x = num, 8 do
                ind[x + 1] = 0
                qty[x + 1] = 0
            end

            local menu_item = 'C4I11C10HI':pack(
                0x36, 0x20, 0x00, 0x00, target.id,
                qty[1], qty[2], qty[3], qty[4], qty[5], qty[6], qty[7], qty[8], qty[9], 0x00,
                ind[1], ind[2], ind[3], ind[4], ind[5], ind[6], ind[7], ind[8], ind[9], 0x00,
                target.index, num
            )

            windower.packets.inject_outgoing(0x36, menu_item)
        else
            print('Too many items. FFXI trade windows can only hold up to 8 item slots at once.')
        end
    else
        print('No target or too far away.')
    end
end)

--[[
Copyright © 2018, Ivaar
All rights reserved.
Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of TradeNPC nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL IVAAR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
]]
