local menuroot = menu.my_root()
local wait = util.yield
local getEntityCoords = ENTITY.GET_ENTITY_COORDS
local getPlayerPed = PLAYER.GET_PLAYER_PED

WhiteText = {r = 1.0, g = 1.0, b = 1.0, a = 1.0}
BlackText = {r = 0, g = 0, b = 0, a = 1.0}

function GetColorFrom255(r, g, b, a)
    local red = r/255
    local green = g/255
    local blue = b/255
    local alpha = a
    return {r = red, g = green, b = blue, a = alpha}
end

function RainbowRGB(h, s, v, speed)
    local hh = h
    if hh >= 360 then
        hh = 0
    end
    local rr, gg, bb = HSV_C(hh, s, v)
    hh = hh + speed
    return rr, gg, bb, hh --returns hh for reuse of the func
end

-- Converts HSV to RGB. (input and output range: 0 - 1)
-- https://love2d.org/wiki/HSV_color
function HSV_C(h, s, v)
    h = h / 360 --360, for all degrees
    if s <= 0 then return v,v,v end
    h = h*6
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0, 0, 0
    if h < 1 then
        r, g, b = c, x, 0
    elseif h < 2 then
        r, g, b = x, c, 0
    elseif h < 3 then
        r, g, b = 0, c, x
    elseif h < 4 then
        r, g, b = 0, x, c
    elseif h < 5 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    return r+m, g+m, b+m
end

function GetPlayerNameFromPed(ped)
    local playerID = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(ped)
    local playerName = NETWORK.NETWORK_PLAYER_GET_NAME(playerID)
    return playerName
end
function GetPlayerNameFromPid(pid)
    local playerName = NETWORK.NETWORK_PLAYER_GET_NAME(pid)
    return playerName
end

function GetLocalPed()
    return PLAYER.PLAYER_PED_ID()
end

function GetPlayerCoords(pid)
    local coord = getEntityCoords(getPlayerPed(pid))
    return coord
end

function GetWPHashFromTable(tbl, str)
    for i = 1, #tbl do
        if tbl[i][2] == str then
            return tbl[i][1]
        end
    end
end

function GetClosestPlayerWithRange(range)
    local pedPointers = entities.get_all_peds_as_pointers()
    local rangesq = range * range
    local ourCoords = getEntityCoords(GetLocalPed())
    local tbl = {}
    local closest_player = 0
    for i = 1, #pedPointers do
        local tarcoords = entities.get_position(pedPointers[i])
        local vdist = SYSTEM.VDIST2(ourCoords.x, ourCoords.y, ourCoords.z, tarcoords.x, tarcoords.y, tarcoords.z)
        if vdist <= rangesq then
            local handle = entities.pointer_to_handle(pedPointers[i])
            if (not players.is_in_interior(NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(handle))) and (PED.IS_PED_A_PLAYER(handle)) then tbl[#tbl+1] = handle end
        end
    end
    if tbl ~= nil then
        local dist = 999999
        for i = 1, #tbl do
            if tbl[i] ~= GetLocalPed() then
                local tarcoords = getEntityCoords(tbl[i])
                local e = SYSTEM.VDIST2(ourCoords.x, ourCoords.y, ourCoords.z, tarcoords.x, tarcoords.y, tarcoords.z)
                if e < dist then
                    dist = e
                    closest_player = tbl[i]
                end
            end
        end
    end
    if closest_player ~= 0 then
        return closest_player
    else
        return nil
    end
end

function GetClosestPlayerWithRange_PIDBlacklist(range, blacklistedPIDsTable)
    local pedPointers = entities.get_all_peds_as_pointers()
    local rangesq = range * range
    local ourCoords = getEntityCoords(GetLocalPed())
    local tbl = {}
    local closest_player = 0
    for _,ped in pairs(pedPointers) do
        local tarcoords = entities.get_position(ped)
        local vdist = SYSTEM.VDIST2(ourCoords.x, ourCoords.y, ourCoords.z, tarcoords.x, tarcoords.y, tarcoords.z)
        if vdist <= rangesq then
            local pedhandle = entities.pointer_to_handle(ped)
            local playerID = NETWORK.NETWORK_GET_PLAYER_INDEX_FROM_PED(pedhandle)
            if (not players.is_in_interior(playerID)) and (PED.IS_PED_A_PLAYER(pedhandle)) and (tarcoords.z > 0 --[[below ground/interior check]]) and (not blacklistedPIDsTable[playerID]) then
                tbl[#tbl+1] = pedhandle
            end
        end
    end
    --looping through pointers done
    if #tbl ~= 0 then
        local dist = 99999999
        for i, v in pairs(tbl) do
            if v ~= GetLocalPed() then
                local tcoords = getEntityCoords(v)
                local e = SYSTEM.VDIST2(ourCoords.x, ourCoords.y, ourCoords.z, tcoords.x, tcoords.y, tcoords.z)
                if e < dist then
                    dist = e
                    closest_player = v
                end
            end
        end
    end
    if closest_player ~= 0 then
        return closest_player
    else
        return nil
    end
end

function GetGroundAtCoord(v3int)
    local success, ground_z
    if v3int then
        local tbl = GetTableFromV3Instance(v3int)
        repeat
            STREAMING.REQUEST_COLLISION_AT_COORD(tbl.x, tbl.y, tbl.z)
            success, ground_z = util.get_ground_z(tbl.x, tbl.y)
            util.yield()
        until success
    end
    return ground_z
end

function GetTableFromV3Instance(v3int)
    local tbl = {x = v3.getX(v3int), y = v3.getY(v3int), z = v3.getZ(v3int)}
    return tbl
end

function DrawText(x, y, string, align, scale, color, force_in_bounds)
    directx.draw_text(x, y, string, align, scale, color, force_in_bounds)
end
function DrawRect(x, y, width, height, color)
    directx.draw_rect(x, y, width, height, color)
end
function DrawRectWithOutline(x, y, width, height, colormain, colorpadding, amountpadding)
    directx.draw_rect(x, y, width, height, colormain)
    --top rectangle
    directx.draw_rect(x, y - amountpadding, width, amountpadding, colorpadding)
    --bottom rectangle
    directx.draw_rect(x, y + height, width, amountpadding, colorpadding)
    --left rectangle
    directx.draw_rect(x - amountpadding, y - amountpadding, amountpadding, height + amountpadding*2, colorpadding)
    --right rectangle
    directx.draw_rect(x + width, y - amountpadding, amountpadding, height + amountpadding*2, colorpadding)
end

function DrawRectUsingMiddlePoint(pointx, pointy, width, height, color)
    directx.draw_rect(pointx - width * 0.5, pointy - height * 0.5, width, height, color)
    --ty murten for improving this
end

function DrawRectWithOutlineUsingMiddlePoint2(pointx, pointy, width, height, colormainR, colormainG, colormainB, colormainA, colorpaddingR, colorpaddingG, colorpaddingB, colorpaddingA, amountpadding)
    --top left point is (pointx - width * 0.5), (pointy - height * 0.5)
    local topLeft = {x = (pointx - width * 0.5), y = (pointy - height * 0.5)}
    --main rectangle
    directx.draw_rect(topLeft.x, topLeft.y, width, height, colormainR, colormainG, colormainB, colormainA)
    --top rectangle outline
    directx.draw_rect(topLeft.x, topLeft.y - amountpadding, width, amountpadding, colorpaddingR, colorpaddingG, colorpaddingB, colorpaddingA)
    --bottom rectangle
    directx.draw_rect(topLeft.x, topLeft.y + height, width, amountpadding, colorpaddingR, colorpaddingG, colorpaddingB, colorpaddingA)
    --left rectangle
    directx.draw_rect(topLeft.x - amountpadding, topLeft.y - amountpadding, amountpadding, height + amountpadding*2, colorpaddingR, colorpaddingG, colorpaddingB, colorpaddingA)
    --right rectangle
    directx.draw_rect(topLeft.x + width, topLeft.y - amountpadding, amountpadding, height + amountpadding * 2, colorpaddingR, colorpaddingG, colorpaddingB, colorpaddingA)
end

function DrawRectWithOutlineUsingMiddlePoint(pointx, pointy, width, height, colormain, colorpadding, amountpadding)
    --top left point is (pointx - width * 0.5), (pointy - height * 0.5)
    local topLeft = {x = (pointx - width * 0.5), y = (pointy - height * 0.5)}
    --main rectangle
    directx.draw_rect(topLeft.x, topLeft.y, width, height, colormain)
    --top rectangle outline
    directx.draw_rect(topLeft.x, topLeft.y - amountpadding, width, amountpadding, colorpadding)
    --bottom rectangle
    directx.draw_rect(topLeft.x, topLeft.y + height, width, amountpadding, colorpadding)
    --left rectangle
    directx.draw_rect(topLeft.x - amountpadding, topLeft.y - amountpadding, amountpadding, height + amountpadding*2, colorpadding)
    --right rectangle
    directx.draw_rect(topLeft.x + width, topLeft.y - amountpadding, amountpadding, height + amountpadding * 2, colorpadding)
end

function DrawRect_Outline_MidPoint_Text(pointx, pointy, amountpaddingfromtext, amountoutline, colormain, coloroutline, colortext, scaletext, stringtext)
    local txtw, txth = directx.get_text_size(stringtext, scaletext)
    DrawRectWithOutlineUsingMiddlePoint(pointx, pointy, txtw + (amountpaddingfromtext * 2), txth + (amountpaddingfromtext * 2), colormain, coloroutline, amountoutline)
    --draw text below this one, since it renders last, therefore on top.
    directx.draw_text(pointx, pointy, stringtext, ALIGN_CENTRE, scaletext, colortext, false)
    --return for calculating inputs in the area
    local x1 = (pointx - txtw - amountpaddingfromtext - amountoutline) --[[startx]]
    local y1 = (pointy - txth - amountpaddingfromtext - amountoutline) --[[starty]]
    local x2 = (pointx + txtw + amountpaddingfromtext + amountoutline) --[[endx]]
    local y2 = (pointy + txth + amountpaddingfromtext + amountoutline) --[[endy]]
    return {x1, y1, x2, y2}
end

function DrawRect_Outline_Midpoint_Img(pointx, pointy, amountpaddingfromimg, amountoutline, colormain, coloroutline, textureID, pixelX, pixelY, scaleX, scaleY, windowX, windowY, textureColor)
    if not windowX then windowX = 1920 end
    if not windowY then windowY = 1080 end
    if not textureColor then textureColor = {r = 1.0, g = 1.0, b = 1.0, a = 1.0} end
    --window X, Y | and texture color are optional; this will work if you don't pass them.
    local imgW, imgH = GetTextureSize(windowX, windowY, pixelX, pixelY, scaleX, scaleY)
    DrawRectWithOutlineUsingMiddlePoint(pointx, pointy, imgW + (amountpaddingfromimg * 2), imgH + (amountpaddingfromimg * 2), colormain, coloroutline, amountoutline)
    DrawTexture(textureID, scaleX/2, scaleY/2, 0.5, 0.5, pointx, pointy, 0, textureColor) --use 0.5 for centering, because DirectX is DOGSHIT
    --divide by 2 here ^^ for scale, because, again, directX sucks.
    --return for calculating inputs in the area
    local x1 = (pointx - imgW - amountpaddingfromimg - amountoutline) --[[startx]]
    local y1 = (pointy - imgH - amountpaddingfromimg - amountoutline) --[[starty]]
    local x2 = (pointx + imgW + amountpaddingfromimg + amountoutline) --[[endx]]
    local y2 = (pointy + imgH + amountpaddingfromimg + amountoutline) --[[endy]]
    return {x1, y1, x2, y2}
end

function DrawTexture(id, sizex, sizey, centerx, centery, posx, posy, rotation, color)
    directx.draw_texture(id, sizex, sizey, centerx, centery, posx, posy, rotation, color)
end

function GetTopLeftCornerOfText(textX, textY, string, scale)
    local textwidth, textheight = directx.get_text_size(string, scale)
    local newX = textX - (textwidth / 2)
    local newY = textY
    return newX, newY
end

function GetTextureSize(windowX, windowY, textureX, textureY, sizeX, sizeY)
    local sx = windowX/textureX
    local sy = windowY/textureY

    local x, y
    if (sx > sy) then
        x = 1 * sizeX
        y = (sx/sy) * sizeY
    elseif (sy > sx) then
        x = (sy/sx) * sizeX
        y = 1 * sizeY
    elseif (sx == sy) then
        x = 1*sizeX
        y = 1*sizeY
    end
    return x, y
end
function ShootBulletIgnoreEntity(coord1, coord2, dmg, p7, wphash, ownerped, audible, invis, speed, toIgnore, p14)
    MISC.SHOOT_SINGLE_BULLET_BETWEEN_COORDS_IGNORE_ENTITY(coord1.x, coord1.y, coord1.z, coord2.x, coord2.y, coord2.z, dmg, p7, wphash, ownerped, audible, invis, speed, toIgnore, p14)
end
function SilentAimbotShoot(target, legit, head, body, pelvis, legs, damage, weaponHash, speed)
    local headc = PED.GET_PED_BONE_COORDS(target, 12844, 0, 0, 0)
    local bodyc = PED.GET_PED_BONE_COORDS(target, 24817, 0, 0, 0)
    local pelvisc = PED.GET_PED_BONE_COORDS(target, 11816, 0, 0, 0)
    local rcalfc = PED.GET_PED_BONE_COORDS(target, 36864, 0, 0, 0)
    local lcalfc = PED.GET_PED_BONE_COORDS(target, 63931, 0, 0, 0)
    local localPed = GetLocalPed()
    local veh = 0
    if PED.IS_PED_IN_ANY_VEHICLE(target) then
        veh = PED.GET_VEHICLE_PED_IS_IN(target, false)
    end
    if (legit) and (ENTITY.HAS_ENTITY_CLEAR_LOS_TO_ENTITY(localPed, target, 17) --[[Check if we have line-of-sight, beccause it's useless shooting w/o it.]]) then
        local ouroff = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(localPed, 0, 1.5, 0.7)
        if head then
            ShootBulletIgnoreEntity(ouroff, headc, damage, true, weaponHash, localPed, true, false, speed, veh, true)
        end
        if body then
            ShootBulletIgnoreEntity(ouroff, bodyc, damage, true, weaponHash, localPed, true, false, speed, veh, true)
        end
        if pelvis then
            ShootBulletIgnoreEntity(ouroff, pelvisc, damage, true, weaponHash, localPed, true, false, speed, veh, true)
        end
        if legs then
            ShootBulletIgnoreEntity(ouroff, rcalfc, damage, true, weaponHash, localPed, true, false, speed, veh, true)
            ShootBulletIgnoreEntity(ouroff, lcalfc, damage, true, weaponHash, localPed, true, false, speed, veh, true)
        end
    else
        local ouroff = ENTITY.GET_OFFSET_FROM_ENTITY_IN_WORLD_COORDS(target, 0, 0.5, 0)
        if head then
            ShootBulletIgnoreEntity(ouroff, headc, damage, true, weaponHash, localPed, true, false, speed, veh, true)
        end
        if body then
            ShootBulletIgnoreEntity(ouroff, bodyc, damage, true, weaponHash, localPed, true, false, speed, veh, true)
        end
        if pelvis then
            ShootBulletIgnoreEntity(ouroff, pelvisc, damage, true, weaponHash, localPed, true, false, speed, veh, true)
        end
        if legs then
            ShootBulletIgnoreEntity(ouroff, rcalfc, damage, true, weaponHash, localPed, true, false, speed, veh, true)
            ShootBulletIgnoreEntity(ouroff, lcalfc, damage, true, weaponHash, localPed, true, false, speed, veh, true)
        end
    end
end

--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===
--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===
--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===

---Array List---

FEATURES = {
    {false, "Oppressor MKII Aimbot"},
    {false, "Silent Aimbot (Better)"}
}

--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===
--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===
--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===--===

function GetIntFromStrTBL(tbl, str)
    for index, string in tbl do
        if str == string then
            -- check whole table if the string matches param [str]
            return index
        end
    end
    -- if no strings match param [str], returns nil.
    return nil
end

function SortTableByStringSize(tbl, LongToShort, ShortToLong)
    if LongToShort and ShortToLong then
        print("you cannot do both!")
        util.toast("you cannot do both!")
        return nil
    end
    if LongToShort then
        table.sort(tbl, function (a, b)
            return #a>#b
        end)
        return tbl
    elseif ShortToLong then
        table.sort(tbl, function (a, b)
            return #a<#b
        end)
        return tbl
    end
end

function GetCursorLocation()
    local x = PAD.GET_CONTROL_NORMAL(2, 239)
    local y = PAD.GET_CONTROL_NORMAL(2, 240)
    return x, y
end

function CheckForControlJustPressedOnScreen(startx, starty, endx, endy, intcontrol)
    if startx > endx or starty > endy then
        print("you cannot have starting x/y be greater than end x/y!")
        util.toast("you cannot have starting x/y be greater than end x/y!")
        return nil
    end
    local cx, cy = GetCursorLocation()
    if ((cx >= startx) and (cx <= endx)) and ((cy >= starty) and (cy <= endy)) then
        if PAD.IS_CONTROL_JUST_PRESSED(0, intcontrol) then
            return true
        end
    end
    return false
end

function CheckForControlPressedOnScreen(startx, starty, endx, endy, intcontrol)
    if startx > endx or starty > endy then
        print("you cannot have starting x/y be greater than end x/y!")
        util.toast("you cannot have starting x/y be greater than end x/y!")
        return nil
    end
    local cx, cy = GetCursorLocation()
    if ((cx >= startx) and (cx <= endx)) and ((cy >= starty) and (cy <= endy)) then
        if PAD.IS_CONTROL_PRESSED(0, intcontrol) then
            return true
        end
    end
    return false
end

function MakeGuiButton_Text(x, y, distfromtext, outlinewidth, colormain, coloroutline, colortext, scaletext, stringtext1, stringtext2, buttonpressactivate, buttonpressdrag, funcToTrigger, commandToTrigger, defaultactive)
    local mX, mY = GetCursorLocation() --get cursor location
    local retX, retY = x, y
    local ac
    ac = defaultactive
    local bc1
    HUD._SET_MOUSE_CURSOR_ACTIVE_THIS_FRAME()
    --String drawing for active state.
    if not ac then --if it's false, then we do text option 1
        bc1 = DrawRect_Outline_MidPoint_Text(x, y, distfromtext, outlinewidth, colormain, coloroutline, colortext, scaletext, stringtext1)
    elseif ac then -- if it's true, then we do text option 2
        bc1 = DrawRect_Outline_MidPoint_Text(x, y, distfromtext, outlinewidth, colormain, coloroutline, colortext, scaletext, stringtext2)
    end
    if CheckForControlJustPressedOnScreen(bc1[1], bc1[2], bc1[3], bc1[4], buttonpressactivate) then
        ac = not ac
        if funcToTrigger then
            funcToTrigger()
        elseif commandToTrigger then
            menu.trigger_commands(tostring(commandToTrigger))
        end
    end
    if buttonpressdrag then
        if CheckForControlPressedOnScreen(bc1[1], bc1[2], bc1[3], bc1[4], buttonpressdrag) then
            retX = mX
            retY = mY
        end
    end

    return retX, retY, ac

    --returns button top left x,y || bottom right x,y >|> to use for checking for button presses
    --[[at the end we need to return:
        -active string (1/2). We will need to use this as a param for running the func next frame.
        -dragged x,y. We will need to use this as a param for running the func next frame.
    ]]
end

function MakeGuiButton_Img(x, y, distfromimg, outlinewidth, colorbg, coloroutline, colorimg1, colorimg2, pixelX, pixelY, scaleX, scaleY, windowX, windowY, img1, img2, buttonActive, buttonDrag, funcTrigger, commandTrigger, defaultActive)
    local mx, my = GetCursorLocation()
    local retX, retY = x, y
    local ac
    ac = defaultActive
    local bc1
    --HUD._SET_MOUSE_CURSOR_ACTIVE_THIS_FRAME()
    if not ac then
        bc1 = DrawRect_Outline_Midpoint_Img(x, y, distfromimg, outlinewidth, colorbg, coloroutline, img1, pixelX, pixelY, scaleX, scaleY, windowX, windowY, colorimg1)
    elseif ac then
        bc1 = DrawRect_Outline_Midpoint_Img(x, y, distfromimg, outlinewidth, colorbg, coloroutline, img2, pixelX, pixelY, scaleX, scaleY, windowX, windowY, colorimg2)
    end
    if CheckForControlJustPressedOnScreen(bc1[1], bc1[2], bc1[3], bc1[4], buttonActive) then
        ac = not ac
        if funcTrigger then
            funcTrigger()
        elseif commandTrigger then
            menu.trigger_commands(tostring(commandTrigger))
        end
    end
    if buttonDrag then
        if CheckForControlPressedOnScreen(bc1[1], bc1[2], bc1[3], bc1[4], buttonDrag) then
            retX = mx
            retY = my
        end
    end
    return retX, retY, ac
end

function DrawBackgroundGUI(hgui_freeze, blackBGAlpha, hgui_smoke)
    local localped = GetLocalPed()
    -- <> <> <> <> Background Stuff <> <> <> <> --
    DrawRect(0.0, 0.0, 1.0, 1.0, {r = 0, g = 0, b = 0, a = blackBGAlpha})
    DrawTexture(hgui_smoke, 0.05, 0.05, 0.5, 0.5, 0.5, 0.5, 0, WhiteText)
    DrawText(0.5, 0.55, "Remember to hold Right-Click When Dragging Stuff ;)", ALIGN_CENTRE, 0.4, WhiteText, false)
    -- <> <> <> <> Background Stuff <> <> <> <> --

    -- <> <> <> <> Freeze Stuff <> <> <> <> --
    if hgui_freeze then
        ENTITY.FREEZE_ENTITY_POSITION(localped, true)
    else ENTITY.FREEZE_ENTITY_POSITION(localped, false) end
    -- <> <> <> <> Freeze Stuff <> <> <> <> --

    -- <> <> <> <> Attack Stuff <> <> <> <> --
    PLAYER.DISABLE_PLAYER_FIRING(players.user(), true)
    -- <> <> <> <> Attack Stuff <> <> <> <> --
end

function DrawCursorGUI(hgui_cigarrette)
    -- <> <> <> <> Cursor Draw <> <> <> <> -- (drawn at the bottom to make cursor render over the thing)
    --HUD._SET_MOUSE_CURSOR_ACTIVE_THIS_FRAME()
    local xx, yy = GetCursorLocation()
    DrawTexture(hgui_cigarrette, 0.006, 0.006, 0.5, 0.5, xx, yy, 0, WhiteText)
    -- <> <> <> <> Cursor Draw <> <> <> <> --
end