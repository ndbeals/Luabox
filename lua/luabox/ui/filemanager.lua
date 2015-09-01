local PANEL = {}
PANEL.ClassName = "Luabox_File_Manager"
PANEL.Base = "DFrame"

local spacing = 4

function PANEL:Init()
    self:SetSize( 600 , 600 )
    self:SetMinWidth( 200 )
    self:SetMinHeight( 100 )
    self:SetSizable( true )
    self:SetDraggable( true )
    self:SetMode( "manager" )
    self:DockPadding( spacing / 2 , 24 + spacing / 2 , spacing / 2 + 1, spacing / 2 )

    self:SetupAddressBar()

    self:SetupFileTree()

    self:SetupFolderView()

    self:SetupSplitters()

    luabox.PlayerContainer():GetFileSystem():Refresh( true )
end

function PANEL:SetupFileTree()

    self.FileTree = vgui.Create( "Luabox_File_Tree" , self )
    self.FileTree:DockMargin( spacing / 2 , spacing / 2 , spacing / 2 , spacing / 2 )
    self.FileTree:Dock( LEFT )
    self.FileTree:SetWide(160)

    self.FileTree:SetFileSystem( luabox.PlayerContainer():GetFileSystem() )

    self.FileTree.DoBaseDoubleClick = function( tree )
        --self.FileTree:SetFileSystem( luabox.PlayerContainer():GetFileSystem() )

        self.FolderView:SetFileSystem( luabox.PlayerContainer():GetFileSystem() )
    end

    self.FileTree.DoBaseRightClick = function( tree )
		local menu = DermaMenu()

        if self.FileMove then
            menu:AddOption( "Move Here" , function() self:FinishFileMove( tree:GetFileSystem() ) end ):SetIcon( "icon16/arrow_down.png" )

            menu:AddSpacer()

            menu:AddOption( "Cancel" , function()
                self.FileCopy = nil
                self.FileMove = nil
            end ):SetIcon( "icon16/cancel.png" )

            return
        elseif self.FileCopy then
            menu:AddOption( "Copy Here" , function() self:FinishFileCopy( tree:GetFileSystem() ) end):SetIcon( "icon16/arrow_down.png" )

            menu:AddSpacer()

            menu:AddOption( "Cancel" , function()
                self.FileCopy = nil
                self.FileMove = nil
            end ):SetIcon( "icon16/cancel.png" )

            return
        else
            menu:AddOption( "New File" , function()
                Derma_StringRequest( "New File" , "Name the new file." , "new" , function( input )
                    tree:GetFileSystem():AddFile( input )

                    self:RefreshFileTree()
                    self:RefreshFolderView()
                end)
            end ):SetIcon( "icon16/page_white_add.png" )

            menu:AddOption( "New Directory" , function()
                Derma_StringRequest( "New Directory" , "Name the new directory." , "new" , function( input )
                    tree:GetFileSystem():AddDirectory( input )

                    self:RefreshFileTree()
                    self:RefreshFolderView()
                end)
            end ):SetIcon( "icon16/folder_add.png" )
        end

        local x , y = tree:LocalToScreen( 0 , 0 )--gui.MouseX() ,
        y = gui.MouseY()
        menu:Open( x + tree:GetIndentSize() , y )
    end


    self:SetupFileTreeButtons()
end

function PANEL:SetupFileTreeButtons( pnl )
	pnl = pnl or self.FileTree

    if pnl.Files then
    	for i , v in ipairs( pnl.Files ) do
    		v:SetDoubleClickToOpen( false )

            v.DoClick = function( but )
                if but.Selected then
                    but:GetRoot():SetSelectedItem( nil )
                    but.Selected = false
                else
                    but.Selected = true
                    but:GetRoot():SetSelectedItem( but )
                end

                if self:GetMode() == "open" then
                    self:SetOpenFile( but:GetFileSystem() )
                elseif self:GetMode() == "save" then
                    self:SetSaveFile( but:GetFileSystem() )
                end

            end

    		v.DoDoubleClick = function( but )
    			--self:OpenFile( but:GetFileSystem() )
    		end

    		v.DoRightClick = function( but )
    			but:GetRoot():SetSelectedItem( but )
    			local menu = DermaMenu()

                if self.FileMove or self.FileCopy then
                    menu:AddOption( "Cancel" , function()
                        self.FileCopy = nil
                        self.FileMove = nil
                    end ):SetIcon( "icon16/cancel.png" )
                else
        			--menu:AddOption( "Open" , function() self:OpenFile( but:GetFileSystem() ) end ):SetIcon( "icon16/folder_page.png")

        			menu:AddOption( "Move" , function() self:StartFileMove( but:GetFileSystem() ) end ):SetIcon( "icon16/page_white_go.png")

                    menu:AddOption( "Copy" , function() self:StartFileCopy( but:GetFileSystem() ) end):SetIcon( "icon16/page_white_copy.png" )

                    menu:AddSpacer()

                    menu:AddOption( "Delete" , function()
                        but:GetFileSystem():Delete()

                        self:RefreshFileTree()
                        self:RefreshFolderView()
                    end):SetIcon( "icon16/page_white_delete.png" )
                end

    			local x , y = but:LocalToScreen( 0 , 0 )
    			menu:Open( x + but:GetIndentSize() + 8 , y + but:GetTall() )
    		end
    	end
    end

    if pnl.Directories then
    	for i , v in ipairs( pnl.Directories ) do

            v.DoClick = function( but )
                self.FolderView:SetFileSystem( but.FileSystem )
                --but:SetExpanded( not but:GetExpanded() )
            end

            v.DoDoubleClick = function( but )
                self.FolderView:SetFileSystem( but.FileSystem )

                if #but.ChildNodes:GetChildren() < 1 then
                    return true
                end
            end

    		v.DoRightClick = function( but )
    			but:GetRoot():SetSelectedItem( but )
    			local menu = DermaMenu()

    			if self.FileMove then
    				menu:AddOption( "Move Here" , function()
                        self:FinishFileMove( but:GetFileSystem() )

                        but:SetExpanded( true , true )
                    end ):SetIcon( "icon16/arrow_down.png" )

                    menu:AddSpacer()

                    menu:AddOption( "Cancel" , function()
                        self.FileCopy = nil
                        self.FileMove = nil
                    end ):SetIcon( "icon16/cancel.png" )
                elseif self.FileCopy then
                    menu:AddOption( "Copy Here" , function()
                        self:FinishFileCopy( but:GetFileSystem() )

                        but:SetExpanded( true , true )
                    end):SetIcon( "icon16/arrow_down.png" )

                    menu:AddSpacer()

                    menu:AddOption( "Cancel" , function()
                        self.FileCopy = nil
                        self.FileMove = nil
                    end ):SetIcon( "icon16/cancel.png" )
    			else
                    menu:AddOption( "New File" , function()
                        Derma_StringRequest( "New File" , "Name the new file." , "new" , function( input )
                            but:GetFileSystem():AddFile( input )

                            but:SetExpanded( true , true )

                            self:RefreshFileTree()
                            self:RefreshFolderView()
                        end)
                    end ):SetIcon( "icon16/page_white_add.png" )

                    menu:AddOption( "New Directory" , function()
                        Derma_StringRequest( "New Directory" , "Name the new directory." , "new" , function( input )
                            but:GetFileSystem():AddDirectory( input )

                            but:SetExpanded( true , true )

                            self:RefreshFileTree()
                            self:RefreshFolderView()
                        end)
                    end ):SetIcon( "icon16/folder_add.png" )

                    menu:AddSpacer()

    				menu:AddOption( "Move" , function() self:StartFileMove( but:GetFileSystem() ) end ):SetIcon( "icon16/folder_go.png")

                    menu:AddOption( "Copy" , function() self:StartFileCopy( but:GetFileSystem() ) end):SetIcon( "icon16/page_white_copy.png" )

                    menu:AddSpacer()

                    menu:AddOption( "Delete" , function()
                        but:GetFileSystem():Delete()

                        self:RefreshFileTree()
                        self:RefreshFolderView()
                    end):SetIcon( "icon16/folder_delete.png" )
    			end

    			local x , y = but:LocalToScreen( 0 , 0 )
    			menu:Open( x + but:GetIndentSize() + 8 , y + 17 )
    		end

    		self:SetupFileTreeButtons( v )
    	end
    end
end

function PANEL:RefreshFileTree( pnl )
	pnl = pnl or self.FileTree

	pnl:Refresh()

    pnl:GetFileSystem():Refresh( true )

	self:SetupFileTreeButtons( pnl )
end

function PANEL:StartFileMove( fs )
	self.FileMove = fs
    self.FileCopy = nil
end

function PANEL:FinishFileMove( fs )
	if self.FileMove == fs or not self.FileMove then return end
	self.FileMove:Move( fs )
	self.FileMove = nil

    self:RefreshFileTree()
    self:RefreshFolderView()
end

function PANEL:StartFileCopy( fs )
	self.FileCopy = fs
    self.FileMove = nil
end

function PANEL:FinishFileCopy( fs )
	if self.FileCopy == fs or not self.FileCopy then return end
	self.FileCopy:Copy( fs )
	self.FileCopy = nil

    self:RefreshFileTree()
    self:RefreshFolderView()
end

function PANEL:SetupFolderView()
    ---[[
    self.FolderArea = vgui.Create( "DPanel" , self )
    self.FolderArea:DockMargin( spacing / 2 , spacing / 2 + 1, spacing / 2 , spacing / 2 + 1 )
    self.FolderArea:DockPadding( 0 , 0 , 0 , 0 )
    self.FolderArea:Dock( FILL )
    self.FolderArea:SetBackgroundColor( luabox.Colors.White )
    --self.FolderArea:SetDrawBackground( false )
    --]]

    self.FolderView = vgui.Create( "Luabox_Folder_View" , self.FolderArea )
    --self.FolderView:DockMargin( spacing / 2 , spacing / 2 + 1, spacing / 2 , spacing / 2 + 1 )
    --self.FolderView:DockPadding( 0 , 0 , 0 , 0 )
    self.FolderView:Dock(FILL)
    self.FolderView:SetBackgroundColor( luabox.Colors.White )

    self.FolderView.DoRightClick = function( view )
        local menu = DermaMenu()

        if self.FileMove then
            menu:AddOption( "Move Here" , function() self:FinishFileMove( view:GetFileSystem() ) end ):SetIcon( "icon16/arrow_down.png" )

            menu:AddSpacer()

            menu:AddOption( "Cancel" , function()
                self.FileCopy = nil
                self.FileMove = nil
            end ):SetIcon( "icon16/cancel.png" )
        elseif self.FileCopy then
            menu:AddOption( "Copy Here" , function() self:FinishFileCopy( view:GetFileSystem() ) end):SetIcon( "icon16/arrow_down.png" )

            menu:AddSpacer()

            menu:AddOption( "Cancel" , function()
                self.FileCopy = nil
                self.FileMove = nil
            end ):SetIcon( "icon16/cancel.png" )
        else
            menu:AddOption( "New File" , function()
                Derma_StringRequest( "New File" , "Name the new file." , "new" , function( input )
                    view:GetFileSystem():AddFile( input )

                    self:RefreshFileTree()
                    self:RefreshFolderView()
                end)
            end ):SetIcon( "icon16/page_white_add.png" )

            menu:AddOption( "New Directory" , function()
                Derma_StringRequest( "New Directory" , "Name the new directory." , "new" , function( input )
                    view:GetFileSystem():AddDirectory( input )

                    self:RefreshFileTree()
                    self:RefreshFolderView()
                end)
            end ):SetIcon( "icon16/folder_add.png" )
        end

        menu:Open( gui.MouseX() , gui.MouseY() )
    end

    self.FolderView:SetFileSystem( luabox.PlayerContainer():GetFileSystem() )

    self:SetupFolderViewButtons()
end

function PANEL:SetupFolderViewButtons()
    for i , v in ipairs( self.FolderView.Files ) do

        v.OnClick = function( but )
            if self:GetMode() == "open" then
                self:SetOpenFile( but:GetFileSystem() )
            elseif self:GetMode() == "save" then
                self:SetSaveFile( but:GetFileSystem() )
            end

        end

        v.DoRightClick = function( but )

            if IsValid( self.FolderView.SelectedRow ) then
                self.FolderView.SelectedRow:SetSelected( false )
            end

            but:SetSelected( true )
            self.FolderView.SelectedRow = but

            local menu = DermaMenu()

            if self.FileMove or self.FileCopy then
                menu:AddOption( "Cancel" , function()
                    self.FileCopy = nil
                    self.FileMove = nil
                end ):SetIcon( "icon16/cancel.png" )
            else
                --menu:AddOption( "Open" , function() self:OpenFile( but:GetFileSystem() ) end ):SetIcon( "icon16/folder_page.png")

                menu:AddOption( "Move" , function() self:StartFileMove( but:GetFileSystem() ) end ):SetIcon( "icon16/page_white_go.png")

                menu:AddOption( "Copy" , function() self:StartFileCopy( but:GetFileSystem() ) end):SetIcon( "icon16/page_white_copy.png" )

                menu:AddSpacer()

                menu:AddOption( "Delete" , function()
                    but:GetFileSystem():Delete()

                    self:RefreshFileTree()
                    self:RefreshFolderView()
                end):SetIcon( "icon16/page_white_delete.png" )
            end

            local x , y = but:LocalToScreen( 0 , 0 )
            menu:Open( gui.MouseX() , y + but:GetTall() )
        end
    end

    for i , v in ipairs( self.FolderView.Directories ) do

        v.DoRightClick = function( but )

            if IsValid( self.FolderView.SelectedRow ) then
                self.FolderView.SelectedRow:SetSelected( false )
            end

            but:SetSelected( true )
            self.FolderView.SelectedRow = but

            local menu = DermaMenu()

            if self.FileMove then
                menu:AddOption( "Move Here" , function() self:FinishFileMove( but:GetFileSystem() ) end ):SetIcon( "icon16/arrow_down.png" )

                menu:AddSpacer()

                menu:AddOption( "Cancel" , function()
                    self.FileCopy = nil
                    self.FileMove = nil
                end ):SetIcon( "icon16/cancel.png" )
            elseif self.FileCopy then
                menu:AddOption( "Copy Here" , function() self:FinishFileCopy( but:GetFileSystem() ) end):SetIcon( "icon16/arrow_down.png" )

                menu:AddSpacer()

                menu:AddOption( "Cancel" , function()
                    self.FileCopy = nil
                    self.FileMove = nil
                end ):SetIcon( "icon16/cancel.png" )
            else
                menu:AddOption( "New File" , function()
                    Derma_StringRequest( "New File" , "Name the new file." , "new" , function( input )
                        but:GetFileSystem():AddFile( input )

                        but:SetExpanded( true , true )

                        self:RefreshFileTree()
                        self:RefreshFolderView()
                    end)
                end ):SetIcon( "icon16/page_white_add.png" )

                menu:AddOption( "New Directory" , function()
                    Derma_StringRequest( "New Directory" , "Name the new directory." , "new" , function( input )
                        but:GetFileSystem():AddDirectory( input )

                        but:SetExpanded( true , true )

                        self:RefreshFileTree()
                        self:RefreshFolderView()
                    end)
                end ):SetIcon( "icon16/folder_add.png" )

                menu:AddSpacer()

                menu:AddOption( "Move" , function() self:StartFileMove( but:GetFileSystem() ) end ):SetIcon( "icon16/folder_go.png")

                menu:AddOption( "Copy" , function() self:StartFileCopy( but:GetFileSystem() ) end):SetIcon( "icon16/page_white_copy.png" )

                menu:AddSpacer()

                menu:AddOption( "Delete" , function()
                    but:GetFileSystem():Delete()

                    self:RefreshFileTree()
                    self:RefreshFolderView()
                end):SetIcon( "icon16/folder_delete.png" )
            end

            local x , y = but:LocalToScreen( 0 , 0 )
            menu:Open( gui.MouseX() , y + but:GetTall() )
        end
    end
end

function PANEL:RefreshFolderView()
    self.FolderView:Refresh()
end

function PANEL:SetupSplitters()
    self.FileSplitter = vgui.Create( "Luabox_Splitter" , self )
    self.FileSplitter:SetOrientation( 1 )
	self.FileSplitter:SetWide(8)
    self.FileSplitter:DockMargin( -spacing *1.5 , spacing / 2 , -spacing / 2 , spacing / 2 )
    self.FileSplitter:DockMargin( -spacing / 2, spacing / 2 , -spacing / 4 , spacing / 2 )
    self.FileSplitter:Dock(LEFT)
    self.FileSplitter:SetPanel1( self.FileTree )
    self.FileSplitter:SetPanel2( self.FolderView )

    --[[
	self.EditorSplitter = vgui.Create( "Luabox_Splitter" , self.EditorArea )
	self.EditorSplitter:DockMargin( spacing / 2 , -spacing , spacing / 2 , -spacing )
	self.EditorSplitter:Dock(BOTTOM)
	self.EditorSplitter:SetTall(8)
	self.EditorSplitter:SetPanel1( self.EditorSheet )
	self.EditorSplitter:SetPanel2( self.OutputArea )
    --]]
end

local function searchhelper( fs , path , filestoo )
    local ret

    if string.TrimRight( fs:GetPath() , "/") == string.TrimRight( path , "/" ) then
        return fs
    end

    for i , v in ipairs( fs:GetDirectories() ) do

        ret = searchhelper( v , path , filestoo )
        if ret then
            return ret
        end
    end

    if filestoo then
        for i , v in ipairs( fs:GetFiles() ) do

            ret = searchhelper( v , path , filestoo )
            if ret then
                return ret
            end
        end
    end
end

function PANEL:SetupAddressBar()
    local buttonsize = 32

    self.AddressArea = vgui.Create( "DPanel" , self )
    self.AddressArea:DockPadding( 0 , 0 , 0 , 0 )
    --self.AddressArea:DockMargin( -spacing / 2 , spacing / 2 , -spacing / 2 , spacing / 2 )
    self.AddressArea:DockMargin( spacing / 2 + 1, spacing / 2 , spacing / 2 , spacing / 2 )
    self.AddressArea:Dock( TOP )
    self.AddressArea:SetTall(32)
    --self.AddressArea:SetBackgroundColor( Color(255,255,255,255) )
    --self.AddressArea:SetPaintBackground( false )
    self.AddressArea.Paint = function( panel , w , h )
        draw.RoundedBox( 4 , 0 , 0 , w , h , luabox.Colors.White )
    end

    self.BackButton = vgui.Create( "DImageButton", self.AddressArea )
	self.BackButton:SetSize( buttonsize, buttonsize )
	self.BackButton:SetMaterial( "gui/HTML/back" )
	self.BackButton:DockMargin( 0 , 0 , 0, 0 )
	self.BackButton:Dock( LEFT )
    self.BackButton:SetColor( luabox.Colors.BorderGray )
	self.BackButton.DoClick = function() print(self.BackButton) end

    self.ForwardButton = vgui.Create( "DImageButton", self.AddressArea )
	self.ForwardButton:SetSize( buttonsize, buttonsize )
	self.ForwardButton:SetMaterial( "gui/HTML/forward" )
	self.ForwardButton:DockMargin( 0 , 0 , 0 , 0 )
	self.ForwardButton:Dock( LEFT )
    self.ForwardButton:SetColor( luabox.Colors.BorderGray )
	self.ForwardButton.DoClick = function() print(self.ForwardButton) end

    self.RefreshButton = vgui.Create( "DImageButton", self.AddressArea )
    self.RefreshButton:SetSize( buttonsize, buttonsize )
    self.RefreshButton:SetMaterial( "gui/HTML/refresh" )
    self.RefreshButton:DockMargin( 0 , 0 , 0 , 0 )
    self.RefreshButton:Dock( LEFT )
    self.RefreshButton:SetColor( luabox.Colors.BorderGray )
    self.RefreshButton.DoClick = function()
        self:RefreshFileTree()

        self:RefreshFolderView()
    end

    self.SearchBarArea = vgui.Create( "DPanel" , self.AddressArea )
    self.SearchBarArea:DockPadding( 0 , 0 , 0 , 0 )
    self.SearchBarArea:DockMargin( spacing / 2 , spacing , spacing , spacing )
    self.SearchBarArea:Dock( RIGHT )
    self.SearchBarArea:SetWide( self:GetWide() / 4 )
    self.SearchBarArea.Paint = function( panel , w , h )
        local skin = panel:GetSkin()

        if ( self.SearchBar:GetDisabled() ) then
            skin.tex.TextBox_Disabled( 0, 0, w, h )
        elseif ( self.SearchBar:HasFocus() ) then
            skin.tex.TextBox_Focus( 0, 0, w, h )
        else
            skin.tex.TextBox( 0, 0, w, h )
        end
    end

    self.SearchBarIcon = vgui.Create( "DImageButton" , self.SearchBarArea )
    self.SearchBarIcon:SetIcon( "icon16/zoom.png" )
    self.SearchBarIcon:DockMargin( spacing / 2 , spacing , spacing / 2 , spacing )
    self.SearchBarIcon:Dock( RIGHT )
    self.SearchBarIcon:SetWide( 16 )
    self.SearchBarIcon.DoClick = function( but )
        print(but)
    end
    self.SearchBarIcon:SetDisabled( true )

    self.SearchBar = vgui.Create( "DTextEntry" , self.SearchBarArea )
    --self.SearchBar:DockMargin( spacing / 2 , spacing , spacing , spacing )
    self.SearchBar:Dock( FILL )
    self.SearchBar:SetDrawBackground( false )

    self.SearchBar:SetDisabled( true )
    self.SearchBar:SetKeyboardInputEnabled( false )
    self.SearchBar:SetMouseInputEnabled( false )

    function self.SearchBar:GetAutoComplete( txt )
        print(txt)
    	return {"test","test2","test3","test4","test5","test6","test7","test8","test9","test10"}
    end

    self.AddressBar = vgui.Create( "DTextEntry", self.AddressArea )
    self.AddressBar:DockMargin( spacing , spacing , spacing / 2 , spacing )
    self.AddressBar:Dock( FILL )
    self.AddressBar.OnEnter = function( text )
        local fs = searchhelper( self.FileTree:GetFileSystem() , text:GetText() )

        if fs then
            self.FolderView:SetFileSystem( fs )
        end
    end
end

function PANEL:SetMode( mode , callback )
    mode = string.lower( mode )

    self.Mode = mode

    if mode == "open" then

        self.OpenBarArea = vgui.Create( "DPanel" , self.FolderArea )
        self.OpenBarArea:DockPadding( spacing / 2 , spacing / 2 , spacing / 2 , spacing / 2 )
        self.OpenBarArea:Dock( BOTTOM )
        self.OpenBarArea:SetTall( 28 )

        self.OpenBar = vgui.Create( "DTextEntry" , self.OpenBarArea )
        self.OpenBar:DockMargin( spacing / 2 , spacing / 2 , spacing / 2 , spacing / 2 )
        self.OpenBar:Dock( FILL )

        self.OpenButton = vgui.Create( "DButton" , self.OpenBarArea )
        self.OpenButton:DockMargin( spacing / 2 , spacing / 2 , spacing / 2 , spacing / 2 )
        self.OpenButton:Dock( RIGHT )
        self.OpenButton:SetWide( 90 )
        self.OpenButton:SetText( "Open" )

        self.OpenButton.DoClick = function( but )

            local openfile = searchhelper( self.FolderView:GetFileSystem() , self.FolderView:GetFileSystem():GetPath() .. "/" .. self.OpenBar:GetText() , true )

            if not openfile then
                openfile = self:GetOpenFile()
            end

            self:SetOpenFile( openfile )

            callback( openfile )

            self:Remove()
        end

        self.OpenBar.OnEnter = function( text )

            local openfile = searchhelper( self.FolderView:GetFileSystem() , self.FolderView:GetFileSystem():GetPath() .. "/" .. text:GetText() , true )

            if not openfile then
                openfile = self:GetOpenFile()
            end

            self:SetOpenFile( openfile )

            callback( openfile )

            self:Remove()
        end


    elseif mode == "save" then

        self.SaveBarArea = vgui.Create( "DPanel" , self.FolderArea )
        self.SaveBarArea:DockPadding( spacing / 2 , spacing / 2 , spacing / 2 , spacing / 2 )
        self.SaveBarArea:Dock( BOTTOM )
        self.SaveBarArea:SetTall( 28 )

        self.SaveBar = vgui.Create( "DTextEntry" , self.SaveBarArea )
        self.SaveBar:DockMargin( spacing / 2 , spacing / 2 , spacing / 2 , spacing / 2 )
        self.SaveBar:Dock( FILL )

        self.SaveButton = vgui.Create( "DButton" , self.SaveBarArea )
        self.SaveButton:DockMargin( spacing / 2 , spacing / 2 , spacing / 2 , spacing / 2 )
        self.SaveButton:Dock( RIGHT )
        self.SaveButton:SetWide( 90 )
        self.SaveButton:SetText( "Save" )

        self.SaveButton.DoClick = function( but )

            local savefile = searchhelper( self.FolderView:GetFileSystem() , self.FolderView:GetFileSystem():GetPath() .. "/" .. self.SaveBar:GetText() , true )

            if not savefile then
                savefile = self:GetSaveFile()
            end

            self:SetSaveFile( savefile )

            callback( savefile )

            self:Remove()
        end

        self.SaveBar.OnEnter = function( text )

            local savefile = searchhelper( self.FolderView:GetFileSystem() , self.FolderView:GetFileSystem():GetPath() .. "/" .. text:GetText() , true )

            if not savefile then
                savefile = self:GetSaveFile()
            end

            self:SetSaveFile( savefile )

            callback( savefile )

            self:Remove()
        end



    end
end

function PANEL:SetOpenFile( fs )
    self.OpenBar:SetText( fs:GetName() )

    self.OpenFile = fs
end

function PANEL:GetOpenFile()
    return self.OpenFile
end

function PANEL:SetSaveFile( fs )
    self.SaveBar:SetText( fs:GetName() )

    self.SaveFile = fs
end

function PANEL:GetSaveFile()
    return self.SaveFile
end

function PANEL:GetMode()
    return self.Mode
end

local function expandhelper( node , fs )

    for i , v in ipairs( node.Directories ) do
        if v.FileSystem == fs then
            if #v.ChildNodes:GetChildren() > 0 then
                v:SetExpanded( true , true )
            end
            return true
        end

        local childopened = expandhelper( v , fs )

        if childopened then
            if #v.ChildNodes:GetChildren() > 0 then
                v:SetExpanded( childopened , true )
            end
            return true
        end
    end
    return false
end

function PANEL:OnFolderViewChanged( fs )
    self.AddressBar:SetText( fs:GetPath() )

    expandhelper( self.FileTree , fs )

    self:SetupFolderViewButtons()
end

function PANEL:PerformLayout( w , h )
    self.BaseClass.PerformLayout( self )

    self.FileSplitter:SetupBounds( self.FileTree.x + 100, self.FolderView.x + self.FolderView:GetWide() - self.FileSplitter:GetWide() - 300 )
    --print(self.BackButton,self.AddressArea)
end

vgui.Register( PANEL.ClassName , PANEL , PANEL.Base )
