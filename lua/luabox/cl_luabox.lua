--Copyright 2014 Nathan Beals

function luabox.GetEditor()
    if not luabox.Editor then
        luabox.Editor = vgui.Create("Luabox_Editor_Frame")
        luabox.Editor:SetDeleteOnClose( false )
        luabox.Editor:Hide()
    end

    return luabox.Editor
end

function luabox.ShowEditor()
    local editor = luabox.GetEditor()

    if luabox.Editor then
        editor:Show()
        editor:MakePopup()
    end
end
function luabox.HideEditor()
    local editor = luabox.GetEditor()

    if luabox.Editor then
        editor:Hide()
    end
end

function luabox.ToggleEditor()
    luabox.GetEditor()

    if luabox.Editor:IsVisible() then
        luabox.HideEditor()
    else
        luabox.ShowEditor()
    end
end

function luabox.SetCurrentScript( fs )
    luabox.CurrentScript = fs
end

function luabox.GetCurrentScript()
    return luabox.CurrentScript
end

concommand.Add( "luabox_toggle_ide" , luabox.ToggleEditor )
concommand.Add( "luabox_show_ide" , luabox.ShowEditor )
concommand.Add( "luabox_hide_ide" , luabox.HideEditor )
