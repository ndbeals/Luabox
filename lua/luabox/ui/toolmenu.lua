local spacing = 4

PANEL.ModelList = {
    ["33%"] = {
        "models/foran/luabox/033pentium4.mdl",
        "models/beer/wiremod/gate_e2_nano.mdl",
        "models/expression 2/cpu_expression_nano.mdl",
        "models/expression 2/cpu_microchip_nano.mdl",
        "models/expression 2/cpu_interface_nano.mdl",
        "models/expression 2/cpu_controller_nano.mdl",
        "models/expression 2/cpu_processor_nano.mdl",
    },
    ["66%"] = {
        "models/foran/luabox/066pentium4.mdl",
        "models/beer/wiremod/gate_e2_mini.mdl",
        "models/expression 2/cpu_expression_mini.mdl",
        "models/expression 2/cpu_microchip_mini.mdl",
        "models/expression 2/cpu_interface_mini.mdl",
        "models/expression 2/cpu_controller_mini.mdl",
        "models/expression 2/cpu_processor_mini.mdl",
    },
    ["100%"] = {
        "models/foran/luabox/pentium4.mdl",
        "models/beer/wiremod/gate_e2.mdl",
        "models/expression 2/cpu_expression.mdl",
        "models/expression 2/cpu_microchip.mdl",
        "models/expression 2/cpu_interface.mdl",
        "models/expression 2/cpu_controller.mdl",
        "models/expression 2/cpu_processor.mdl",
    },
    ["133%"] = {
        "models/foran/luabox/133pentium4.mdl",
    },
}

function PANEL:SetupModelPanel()
    self.ModelScale = vgui.Create( "DPanel" , self )
    self.ModelScale:SetPaintBackground( false )
    self.ModelScale:DockMargin( 0 , 0 , 0 , 0 )
    self.ModelScale:DockPadding( spacing / 2 , 0 , spacing / 2 , 0 )
    self.ModelScale:Dock( TOP )
    --( spacing / 2 , spacing / 2 , spacing / 2 , spacing / 2 )

    self.ModelScaleLabel = vgui.Create( "DLabel" , self.ModelScale )
    self.ModelScaleLabel:SetText( "Model Scale" )
    self.ModelScaleLabel:DockMargin( spacing / 2 , spacing / 2 , 0 , spacing / 2 )
    self.ModelScaleLabel:Dock( LEFT )
    self.ModelScaleLabel:SetTextColor( luabox.Colors.Black )

    self.ModelScaleSelector = vgui.Create( "DComboBox" , self.ModelScale )
    self.ModelScaleSelector:DockMargin( 0 , spacing / 2 , -spacing / 2 , spacing / 2 )
    self.ModelScaleSelector:Dock( FILL )
    self.ModelScaleSelector:AddChoice( "33%" )
    self.ModelScaleSelector:AddChoice( "66%" )
    self.ModelScaleSelector:AddChoice( "100%" , nil , true )
    self.ModelScaleSelector:AddChoice( "133%" )
    self.ModelScaleSelector.OpenMenu = function( self )
        if ( #self.Choices == 0 ) then return end

        if ( IsValid( self.Menu ) ) then
            self.Menu:Remove()
            self.Menu = nil
        end

        self.Menu = DermaMenu()

        for k, v in ipairs( self.Choices ) do
            self.Menu:AddOption( v, function() self:ChooseOption( v, k ) end )
        end

        local x, y = self:LocalToScreen( 0, self:GetTall() )

        self.Menu:SetMinimumWidth( self:GetWide() )
        self.Menu:Open( x, y, false, self )
    end
    self.ModelScaleSelector.OnSelect = function( combo , index , value )
        self:PopulateModelSelector()
    end

    self.ModelSelectorScroll = vgui.Create( "DScrollPanel" , self )
    self.ModelSelectorScroll:DockMargin( 0 , spacing / 2 , 0 , spacing / 2 )
    self.ModelSelectorScroll:Dock( TOP )
    self.ModelSelectorScroll:SetTall(226)
    --self.ModelSelectorScroll:SetPaintBackground( true )

    self.ModelSelector = vgui.Create( "DIconLayout" , self.ModelSelectorScroll )
    self.ModelSelector:SetSpaceX( spacing / 2 )
    self.ModelSelector:SetSpaceY( spacing / 2 )
    self.ModelSelector:SetBorder( 15 )
    self.ModelSelector:DockMargin( 0 , 0 , 0 , 0 )
    self.ModelSelector:Dock(FILL)

    function self.ModelSelector.LayoutIcons_TOP( layout )
    	local x			= layout.m_iBorder
    	local y			= spacing / 2 --layout.m_iBorder
    	local RowHeight = 0;

    	local MaxWidth	= layout:GetWide() -- layout.m_iBorder

        if not self.ModelSelectorScroll.VBar.Enabled then
            MaxWidth = MaxWidth - layout.m_iBorder
        end

    	local chld = layout:GetChildren()
    	for k, v in pairs( chld ) do

            if ( not v:IsVisible( ) ) then continue end

    		local w, h = v:GetSize()
    		if ( x + w > MaxWidth || ( v.OwnLine && x > layout.m_iBorder ) ) then

    			x = layout.m_iBorder
    			y = y + RowHeight + layout.m_iSpaceY
    			RowHeight = 0;
    		end

    		v:SetPos( x, y )

    		x = x + v:GetWide() + layout.m_iSpaceX
    		RowHeight = math.max( RowHeight, v:GetTall() )

    		-- Start a new line if this panel is meant to be on its own line
    		if ( v.OwnLine ) then
    			x = MaxWidth + 1
    		end
    	end
    end

    self:PopulateModelSelector()
end

function PANEL:PopulateModelSelector( )
    self.ModelSelector:Clear( )
    self.ModelSelectorScroll:GetCanvas( ):SetSize( 0, 0 )
    local scale = self.ModelScaleSelector:GetSelected( ):gsub( "%D", "" )
    scale = tonumber( scale )

    for i , v in ipairs( self.ModelList[ self.ModelScaleSelector:GetSelected( ) ] ) do
        if file.Exists( v, "GAME" ) then
            local ico = self.ModelSelector:Add( "DModelPanel" )

            ico.SetModel = function( ico, strModelName )
                if ( IsValid( ico.Entity ) ) then
                    ico.Entity:Remove( )
                    ico.Entity = nil
                end

                ico.Entity = ClientsideModel( strModelName, RENDERGROUP_BOTH )
                if ( not IsValid( ico.Entity ) ) then return end
                ico.Entity:SetNoDraw( true )
            end

            ico:SetModel( v )
            ico:SetSize( 110, 110 )

            ico.Paint = function( ico, w, h )
                draw.RoundedBox( 4, 0, 0, w, h, luabox.Colors.FillerGray )
                if ( not IsValid( ico.Entity ) ) then return end
                local x, y = ico:LocalToScreen( 0, 0 )
                cam.Start3D( ico.vCamPos, ico.aLookAngle, ico.fFOV, x, y, w, h, 2, ico.FarZ )
                ico:DrawModel( )
                cam.End3D( )

                if self.SelectedModel == ico then
                    surface.SetDrawColor( 255, 201, 0 )

                    for i = 3, 7, 1 do
                        surface.DrawOutlinedRect( i, i, w - i * 2, h - i * 2 )
                    end
                end
            end

            local fov = 10
            local min, max = ico.Entity:GetModelBounds( )
            local size = max - min
            local opposite = size.y
            local adjacent = ( opposite / math.tan( math.rad( fov ) ) )

            ico:SetLookAng( Angle( 90, 180, 0 ) )
            ico:SetCamPos( Vector( 0, 0, adjacent ) )
            ico:SetFOV( fov )

            ico.DoClick = function( ico )
                self.SelectedModel = ico
                RunConsoleCommand( "luabox_core_model", ico:GetModel( ) )
            end

            ico:SetToolTip( v )
        end
    end

    self.ModelSelectorScroll:Rebuild( )
    self.ModelSelectorScroll:InvalidateLayout( true )
    self.ModelSelector:InvalidateLayout( true )
end

function PANEL:SetupFileBrowser()
    self.FileArea = vgui.Create( "DPanel" , self )
    self.FileArea:DockMargin( 0 , spacing / 2 , 0 , spacing / 2 )
    self.FileArea:DockPadding( 0 , 0 , 0 , 0 )
    self.FileArea:Dock( TOP )
    self.FileArea:SetTall( 300 )
    self.FileArea.Paint = function( panel , w , h )
        draw.RoundedBox( 2 , 0 , 0 , w , h , luabox.Colors.BorderGray )
        draw.RoundedBox( 2 , 1 , 1 , w - 2 , h - 2 , luabox.Colors.White )
    end


    self.FileBrowser = vgui.Create( "Luabox_File_Tree" , self.FileArea )
    --self.FileBrowser:DockMargin( 0 , 0 , 0 , -1 )
    --self.FileBrowser:SetTall( self.FileArea:GetTall() )
    self.FileBrowser:Dock( FILL )

    self.FileBrowser:SetPaintBackground( false )
    self.FileBrowser:SetFileSystem( luabox.PlayerContainer():GetFileSystem() )

    self.FileBrowserRefresh = vgui.Create( "DButton" , self.FileArea )
    self.FileBrowserRefresh:Dock(BOTTOM)
    self.FileBrowserRefresh:SetText( "Refresh" )
    self.FileBrowserRefresh.DoClick = function( but , test)
        self:RefreshFileBrowser()
    end

    self.FileBrowser.DoBaseRightClick = function( tree )
		local menu = DermaMenu()

        if self.FileMove then
            menu:AddOption( "Move Here" , function() self:FinishFileMove( tree:GetFileSystem() ) end ):SetIcon( "icon16/arrow_down.png" )

            menu:AddSpacer()

            menu:AddOption( "Cancel" , function()
                self.FileCopy = nil
                self.FileMove = nil
            end ):SetIcon( "icon16/cancel.png" )
        elseif self.FileCopy then
            menu:AddOption( "Copy Here" , function() self:FinishFileCopy( tree:GetFileSystem() ) end):SetIcon( "icon16/arrow_down.png" )

            menu:AddSpacer()

            menu:AddOption( "Cancel" , function()
                self.FileCopy = nil
                self.FileMove = nil
            end ):SetIcon( "icon16/cancel.png" )
        else
			menu:AddOption( "New File" , function()
	            Derma_StringRequest( "New File" , "Name the new file." , "new" , function( input )
	                tree:GetFileSystem():AddFile( input )

	                self:RefreshFileBrowser()
	            end)
	        end ):SetIcon( "icon16/page_white_add.png" )

	        menu:AddOption( "New Directory" , function()
	            Derma_StringRequest( "New Directory" , "Name the new directory." , "new" , function( input )
	                tree:GetFileSystem():AddDirectory( input )

	                self:RefreshFileBrowser()
	            end)
	        end ):SetIcon( "icon16/folder_add.png" )
		end

		local x , y = tree:LocalToScreen( 0 , 0 )--gui.MouseX() ,
		y = gui.MouseY()
		menu:Open( x + tree:GetIndentSize() , y )
	end

    self:SetupFileBrowserButtons()
end

function PANEL:StartFileMove( fs )
	self.FileMove = fs
    self.FileCopy = nil
end

function PANEL:FinishFileMove( fs )
	if self.FileMove == fs or not self.FileMove then return end
	self.FileMove:Move( fs )
	self.FileMove = nil

	self:RefreshFileBrowser()
end

function PANEL:StartFileCopy( fs )
	self.FileCopy = fs
    self.FileMove = nil
end

function PANEL:FinishFileCopy( fs )
	if self.FileCopy == fs or not self.FileCopy then return end
	self.FileCopy:Copy( fs )
	self.FileCopy = nil

	self:RefreshFileBrowser()
end

function PANEL:RefreshFileBrowser( pnl )
	pnl = pnl or self.FileBrowser

	pnl:Refresh()

    pnl:GetFileSystem():Refresh( true )

	self:SetupFileBrowserButtons( pnl )
end

function PANEL:SetupFileBrowserButtons( pnl )
	pnl = pnl or self.FileBrowser

    if pnl.Files then
    	for i , v in ipairs( pnl.Files ) do
    		v:SetDoubleClickToOpen( false )

            v.DoClick = function( but )
                if but.Selected then
                    but:GetRoot():SetSelectedItem( nil )
                    but.Selected = false
                else
                    but.Selected = true
                end
            end

    		v.DoDoubleClick = function( but )
    			self:OpenFile( but:GetFileSystem() )
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
        			menu:AddOption( "Open" , function() self:OpenFile( but:GetFileSystem() ) end ):SetIcon( "icon16/folder_page.png")

        			menu:AddOption( "Move" , function() self:StartFileMove( but:GetFileSystem() ) end ):SetIcon( "icon16/page_white_go.png")

                    menu:AddOption( "Copy" , function() self:StartFileCopy( but:GetFileSystem() ) end):SetIcon( "icon16/page_white_copy.png" )

                    menu:AddSpacer()

                    menu:AddOption( "Delete" , function() but:GetFileSystem():Delete() end):SetIcon( "icon16/page_white_delete.png" )
                end

    			local x , y = but:LocalToScreen( 0 , 0 )
    			menu:Open( x + but:GetIndentSize() + 8 , y + but:GetTall() )
    		end
    	end
    end

    if pnl.Directories then
    	for i , v in ipairs( pnl.Directories ) do
    		v.DoClick = function( but )
                if but.Selected then
                    but:GetRoot():SetSelectedItem( nil )
                    but.Selected = false
                else
                    but:GetRoot():SetSelectedItem( but )
                    but.Selected = true
                end
    		end

            v.DoDoubleClick = function( but )
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

                            self:RefreshFileBrowser()
                        end)
                    end ):SetIcon( "icon16/page_white_add.png" )

                    menu:AddOption( "New Directory" , function()
                        Derma_StringRequest( "New Directory" , "Name the new directory." , "new" , function( input )
                            but:GetFileSystem():AddDirectory( input )

                            but:SetExpanded( true , true )

                            self:RefreshFileBrowser()
                        end)
                    end ):SetIcon( "icon16/folder_add.png" )

                    menu:AddSpacer()

    				menu:AddOption( "Move" , function() self:StartFileMove( but:GetFileSystem() ) end ):SetIcon( "icon16/folder_go.png")

                    menu:AddOption( "Copy" , function() self:StartFileCopy( but:GetFileSystem() ) end):SetIcon( "icon16/page_white_copy.png" )

                    menu:AddSpacer()

                    menu:AddOption( "Delete" , function()
                        but:GetFileSystem():Delete()
                        self:RefreshFileBrowser()
                    end):SetIcon( "icon16/folder_delete.png" )
    			end

    			local x , y = but:LocalToScreen( 0 , 0 )
    			menu:Open( x + but:GetIndentSize() + 8 , y + 17 )
    		end

    		self:SetupFileBrowserButtons( v )
    	end
    end
end

function PANEL:Init()
    print("INITED")

    self.Container = luabox.PlayerContainer()
    self:DockPadding( 0 , 0 , 0 , 0 )
    self:DockMargin( 0 , 0 , 0 , 0 )

    self:SetupModelPanel()

    self:SetupFileBrowser()

    --self.Spacer1 = vgui.Create( "DPanel" , self)
    --self.Spacer1:DockMargin()

    self.OpenEditor = vgui.Create( "DButton" , self )
    self.OpenEditor:DockMargin( 0 , spacing / 2 + 20 , 0 , spacing / 2 )
    self.OpenEditor:Dock( TOP )
    self.OpenEditor:SetText( "Open Editor" )
    self.OpenEditor.DoClick = function( but )
        luabox.ShowEditor()
    end

    self.NewFile = vgui.Create( "DButton" , self )
    self.NewFile:DockMargin( 0 , spacing / 2 , 0 , spacing / 2 )
    self.NewFile:Dock( TOP )
    self.NewFile:SetText( "New File" )
    self.NewFile.DoClick = function( but )
        luabox.ShowEditor()
        luabox.GetEditor():AddEditorTab()
    end


    self.FileManager = vgui.Create( "DButton" , self )
    self.FileManager:DockMargin( 0 , spacing / 2 + 20 , 0 , spacing / 2 )
    self.FileManager:Dock( TOP )
    self.FileManager:SetText( "File Manager" )
    self.FileManager.DoClick = function( but )
        luabox.GetEditor():Show()
        luabox.GetEditor():AddEditorTab()
        luabox.GetEditor():MakePopup()
    end


    hook.Add( "OnSpawnMenuOpen" , "Luabox_Refesh_Tool_Browser" , function()
        if self.RefreshFileBrowser then
            self:RefreshFileBrowser()
        end
    end)

    hook.Add( "OnContextMenuOpen" , "Luabox_Refesh_Tool_Browser" , function()
        if self.RefreshFileBrowser then
            self:RefreshFileBrowser()
        end
    end)
end

function PANEL:PerformLayout()
    self:SetTall( ScrH() - 168 )
end
