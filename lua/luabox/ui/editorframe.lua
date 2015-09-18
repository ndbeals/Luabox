local PANEL = {}

PANEL.ClassName = "Luabox_Editor_Frame"
PANEL.Base = "DFrame"


local spacing = 4

function PANEL:Init()
	self.Settings = {}
	self.Maximized = {}
	self.Editors = {}
	self.Container = luabox.PlayerContainer()
	self.HotKeyTime = FrameNumber()

	self:SetMinWidth(350)
	self:SetMinHeight(150)
	self:SetSizable(true)
	self:SetDraggable(true)
	self:SetTitle("Luabox Editor")


	self.btnMaxim:SetDisabled( false )
	self.btnMaxim.DoClick = function( btn )
		if not self.Maximized[1] then
			self.Maximized = {{self:GetSize()} , {self:GetPos()}}
			self:SetPos( 0 , 0 )
			self:SetSize( ScrW() , ScrH() )
		else
			self:SetSize( unpack( self.Maximized[1] ) )
			self:SetPos( unpack( self.Maximized[2] ) )
			self.Maximized = {}
		end
	end

	self.btnMinim:SetDisabled( false )
	self.btnMinim.DoClick = function( btn )
		self:SaveSettings()
		if not self.Maximized then
			self.Maximized = {{self:GetSize()} , {self:GetPos()}}
			self:SetPos( 0 , 0 )
			self:SetSize( ScrW() , ScrH() )
		else
			self:SetSize( unpack( self.Maximized[1] ) )
			self:SetPos( unpack( self.Maximized[2] ) )
			self.Maximized = nil
		end
	end

	self.btnClose.DaoClick = function( btn )
		self:Hide()
	end

	self.Menu = vgui.Create( "DMenuBar", self )
	self.Menus = self.Menu.Menus
	self.Menu:Dock(NODOCK)

	self.Menu.OnKeyCodePressed = function( self, code )
		if self:GetParent().OnKeyCodePressed then
			self:GetParent():OnKeyCodePressed(code)
		end
	end

	self:SetupFileMenu()

	self:DockPadding(spacing / 2, (spacing / 2) + 24 + self.Menu:GetTall(), spacing / 2, spacing / 2)

	self:SetupProjectTree()

	self:SetupAreas()

	self:SetupEditMenu()

	self:SetupViewMenu()

	self:SetupToolsMenu()

	self:SetupHelpMenu()

	self:SetupEditorSheet()

	self:SetupOutput()

	self:SetupSplitters()

	if not self:LoadSettings() then
		self:DefaultSettings()
	end
end

function PANEL:SetupFileMenu()
	self.Menu:AddMenu("File")

	self.Menus.File:AddOption("New", function()
		self:AddEditorTab()
	end):SetIcon("icon16/page_white_add.png")

	self.Menus.File:AddOption("Open", function()
		local filemanager = vgui.Create( "Luabox_File_Manager" )
		filemanager:SetMode( "open" , function( fs )
			self:OpenFile( fs )
		end)

		filemanager:MakePopup()
	end):SetIcon("icon16/folder_page.png")

	self.Menus.File:AddOption("Save", function()
		print("saved")
	end):SetIcon("icon16/disk.png")

	self.Menus.File:AddOption("Save As...", function()
		local filemanager = vgui.Create( "Luabox_File_Manager" )
		filemanager:SetMode( "save" , function( fs , path)
			if not (string.GetExtensionFromFilename( path ) == "txt" ) then
				print "ASFASFADSGSDG"
				path = path .. ".txt"
			end
			print("AS",fs:GetPath(),fs:GetSingleFile(),path,string.GetExtensionFromFilename( path )=="txt")
			if fs then
				local contents = self:GetTabContents()
				--print("haha",contents)
				if fs:GetSingleFile() then
					fs:Write( contents )
				else
					local newfs = fs:AddFile( path )
					print("NESTFS",newfs)
					--newfs:Write( contents )

				end
			end
		end)

		filemanager:MakePopup()
	end):SetIcon("icon16/disk.png")

	self.Menus.File:AddOption("Save All", function()
		print("saved")
	end):SetIcon("icon16/disk_multiple.png")

	self.Menus.File:AddOption("Close", function()
		self:RemoveEditorTab()
	end):SetIcon("icon16/delete.png")

	self.Menus.File:AddSpacer()

	self.Menus.File:AddOption("Exit", function()
		self:Close()
	end):SetIcon("icon16/cross.png")
end

function PANEL:SetupEditMenu()
	self.Menu:AddMenu("Edit")

	self.Menus.Edit:AddOption("Undo", function()
		if self:GetActiveEditor() then
			self:GetActiveEditor():DoUndo()
		end
	end):SetIcon("icon16/arrow_undo.png")

	self.Menus.Edit:AddOption("Redo", function()
		if self:GetActiveEditor() then
			self:GetActiveEditor():DoRedo()
		end
	end):SetIcon("icon16/arrow_redo.png")

	self.Menus.Edit:AddSpacer()

	self.Menus.Edit:AddOption("Cut", function()
		if self:GetActiveEditor() then
			self:GetActiveEditor():Cut()
		end
	end):SetIcon("icon16/page_white_add.png")

	self.Menus.Edit:AddOption("Copy", function()
		if self:GetActiveEditor() then
			self:GetActiveEditor():Copy()
		end
	end):SetIcon("icon16/folder_page.png")

	self.Menus.Edit:AddOption("Paste", function()
		if self:GetActiveEditor() then
			self:GetActiveEditor():Paste()
		end
	end):SetIcon("icon16/disk.png")
end

function PANEL:SetupViewMenu()
	self.Menu:AddMenu( "View" )
	self.Menus.View.FileBrowser = self.Menus.View:AddOption( "File Browser" )
	self.Menus.View.FileBrowser:SetIcon( "icon16/folder.png" )
	self.Menus.View.FileBrowser:SetIsCheckable( true )

	self.Menus.View.FileBrowser.OnChecked = function( option , checked )
		if checked then
			self:ShowProjectTree( )
		else
			self:HideProjectTree( )
		end
	end

	self.Menus.View.FileBrowser.PaintOver = function( option )
		if option:GetChecked( ) then
			option.Hovered = true
		end
	end

	self.Menus.View.Output = self.Menus.View:AddOption( "Output", function( )
		print( "saved" )
	end )

	self.Menus.View.Output:SetIcon( "icon16/application_xp_terminal.png" )
	self.Menus.View.Output:SetIsCheckable( true )

	self.Menus.View.Output.OnChecked = function( option, checked )
		if checked then
			self:ShowOutput( )
		else
			self:HideOutput( )
		end
	end

	self.Menus.View.Output.PaintOver = function( option )
		if option:GetChecked() then
			option.Hovered = true
		end
	end
end

function PANEL:SetupToolsMenu()
	self.Menu:AddMenu( "Tools" )

	local reset = self.Menus.Tools:AddOption( "Reset Editor Settings", function( )
		self:DefaultSettings( )
		file.Delete( "luabox_editor_settings.txt" )
	end )
	reset:SetIcon( "icon16/exclamation.png" )
	reset:SetTooltip( "Deletes the settings file and applies the default settings to the editor" )

	self.Menus.Tools.TildeIgnore = self.Menus.Tools:AddOption( "Ignore Tilde (console button)" )
	--tildeignore:SetIcon( "icon16/application_xp_terminal.png" )
	self.Menus.Tools.TildeIgnore:SetIsCheckable( true )

	self.Menus.Tools.TildeIgnore.OnChecked = function( option, checked )
		for k, v in pairs(self.Editors) do
			if v.Panel then
				v.Panel:SetIgnoreTilde(checked)
			end
		end
	end

	self.Menus.Tools.TildeIgnore.PaintOver = function( option )
		if option:GetChecked( ) then
			option.Hovered = true
		end
	end
end

function PANEL:SetupHelpMenu()
	self.Menu:AddMenu("Help")
	--[[
	self.Menus.Help:AddOption( "New" , function() print("saved") end ):SetIcon( "icon16/page_white_add.png" )

	self.Menus.Help:AddOption( "Open" , function() print("saved") end ):SetIcon( "icon16/folder_page.png" )

	self.Menus.Help:AddOption( "Save" , function() print("saved") end ):SetIcon( "icon16/disk.png" )

	self.Menus.Help:AddOption( "Save As..." , function() print("saved") end ):SetIcon( "icon16/disk.png" )

	self.Menus.Help:AddOption( "Save All" , function() print("saved") end ):SetIcon( "icon16/disk_multiple.png" )

	self.Menus.Help:AddOption( "Close" , function() print("saved") end ):SetIcon("icon16/circlecross.png")

	self.Menus.Help:AddOption( "Exit" , function() print("saved") end ):SetIcon("icon16/cross.png")
	--]]
end

function PANEL:SetupProjectTree( )
	self.ProjectTree = vgui.Create( "Luabox_File_Tree", self )
	self.ProjectTree:DockMargin( spacing / 2, spacing / 2 - 1, spacing * 1.5, spacing / 2 )
	self.ProjectTree:Dock( LEFT )
	self.ProjectTree.DoClick = function( tree , but ) end

	--print("projectree" , tree , but , tree == but )
	self.ProjectTree.DoBaseRightClick = function(tree)
		local menu = DermaMenu()

		if self.FileMove then
			menu:AddOption("Move Here", function()
				self:FinishFileMove(tree:GetFileSystem())
			end):SetIcon("icon16/arrow_down.png")

			menu:AddSpacer()

			menu:AddOption("Cancel", function()
				self.FileCopy = nil
				self.FileMove = nil
			end):SetIcon("icon16/cancel.png")
		elseif self.FileCopy then
			menu:AddOption("Copy Here", function()
				self:FinishFileCopy(tree:GetFileSystem())
			end):SetIcon("icon16/arrow_down.png")

			menu:AddSpacer()

			menu:AddOption("Cancel", function()
				self.FileCopy = nil
				self.FileMove = nil
			end):SetIcon("icon16/cancel.png")
		else
			menu:AddOption("New File", function()
				Derma_StringRequest("New File", "Name the new file.", "new", function(input)
					tree:GetFileSystem():AddFile(input)
					self:RefreshProjectTree()
				end)
			end):SetIcon("icon16/page_white_add.png")

			menu:AddOption("New Directory", function()
				Derma_StringRequest("New Directory", "Name the new directory.", "new", function(input)
					tree:GetFileSystem():AddDirectory(input)
					self:RefreshProjectTree()
				end)
			end):SetIcon("icon16/folder_add.png")
		end

		local x, y = tree:LocalToScreen(0, 0)
		--gui.MouseX() ,
		y = gui.MouseY()
		menu:Open(x + tree:GetIndentSize(), y)
	end

	self.Container:GetFileSystem():Refresh(true)
	self.ProjectTree:SetFileSystem(self.Container:GetFileSystem())
	self:SetupProjectTreeButtons()
end

function PANEL:HideProjectTree()
	self.ProjectTree:Hide()
	self.FileSplitter:Hide()
	self.Menus.View.FileBrowser:SetChecked( false )
	self.Menus.View.FileBrowser.Hovered = false

	self:InvalidateLayout( true )
end

function PANEL:ShowProjectTree()
	self.ProjectTree:Show()
	self.FileSplitter:Show()
	self.Menus.View.FileBrowser:SetChecked( true )

	self:InvalidateLayout( true )
end

function PANEL:RefreshProjectTree( pnl )
	pnl = pnl or self.ProjectTree

	pnl:Refresh()

	pnl:GetFileSystem():Refresh( true )

	self:SetupProjectTreeButtons( pnl )
end

function PANEL:SetupProjectTreeButtons( pnl )
	pnl = pnl or self.ProjectTree

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
				return true
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

							self:RefreshProjectTree()

						end)
					end ):SetIcon( "icon16/page_white_add.png" )

					menu:AddOption( "New Directory" , function()
						Derma_StringRequest( "New Directory" , "Name the new directory." , "new" , function( input )
							but:GetFileSystem():AddDirectory( input )

							but:SetExpanded( true , true )

							self:RefreshProjectTree()

						end)
					end ):SetIcon( "icon16/folder_add.png" )

					menu:AddSpacer()

					menu:AddOption( "Move" , function() self:StartFileMove( but:GetFileSystem() ) end ):SetIcon( "icon16/folder_go.png")

					menu:AddOption( "Copy" , function() self:StartFileCopy( but:GetFileSystem() ) end):SetIcon( "icon16/page_white_copy.png" )

					menu:AddSpacer()

					menu:AddOption( "Delete" , function()
						but:GetFileSystem():Delete()
						self:RefreshProjectTree()
					end):SetIcon( "icon16/folder_delete.png" )
				end

				local x , y = but:LocalToScreen( 0 , 0 )
				menu:Open( x + but:GetIndentSize() + 8 , y + 17 )
			end

			self:SetupProjectTreeButtons( v )
		end
	end
end

function PANEL:StartFileMove( fs )
	self.FileMove = fs
	self.FileCopy = nil
end

function PANEL:FinishFileMove( fs )
	if self.FileMove == fs or not self.FileMove then return end
	self.FileMove:Move( fs )
	self.FileMove = nil

	self:RefreshProjectTree()
end

function PANEL:StartFileCopy( fs )
	self.FileCopy = fs
	self.FileMove = nil
end

function PANEL:FinishFileCopy( fs )
	if self.FileCopy == fs or not self.FileCopy then return end
	self.FileCopy:Copy( fs )
	self.FileCopy = nil

	self:RefreshProjectTree()
end

function PANEL:SetupAreas()
	self.EditorArea = vgui.Create( "DPanel" , self )
	self.EditorArea:SetPaintBackground( false )
	self.EditorArea:DockMargin( 0 , 0 , 0 , 0 )
	self.EditorArea:Dock(FILL)
	self.EditorArea.OnKeyCodePressed = function( self , code )
		if self:GetParent().OnKeyCodePressed then
			self:GetParent():OnKeyCodePressed( code )
		end
	end

	self.OutputArea = vgui.Create( "DPanel" , self.EditorArea )
	self.OutputArea:DockMargin( spacing / 2 , spacing , spacing / 2 , spacing / 2 )
	self.OutputArea:Dock(BOTTOM)
	self.OutputArea.Paint = function( pnl , w , h )
		draw.RoundedBox( 4 , 0 , 0 , w , h , luabox.Colors.Outline )
		draw.RoundedBox( 4 , 1 , 1 , w - 2 , h - 2 , luabox.Colors.FillerGray )
	end

	self.OutputArea.OnKeyCodePressed = function( self , code )
		if self:GetParent().OnKeyCodePressed then
			self:GetParent():OnKeyCodePressed( code )
		end
	end
end

function PANEL:SetupSplitters()
	self.FileSplitter = vgui.Create( "Luabox_Splitter" , self )
	self.FileSplitter:SetOrientation( 1 )
	self.FileSplitter:SetWide(8)
	self.FileSplitter:DockMargin( -spacing * 1.5, spacing / 2, -spacing / 2, spacing / 2 )
	self.FileSplitter:Dock(LEFT)
	self.FileSplitter:SetPanel1( self.ProjectTree )
	self.FileSplitter:SetPanel2( self.EditorArea )

	self.EditorSplitter = vgui.Create( "Luabox_Splitter" , self.EditorArea )
	self.EditorSplitter:DockMargin( spacing / 2 , -spacing , spacing / 2 , -spacing )
	self.EditorSplitter:Dock(BOTTOM)
	self.EditorSplitter:SetTall(8)
	self.EditorSplitter:SetPanel1( self.EditorSheet )
	self.EditorSplitter:SetPanel2( self.OutputArea )
end

function PANEL:SetupOutput()
	self.Output = vgui.Create( "Luabox_Console_Output" , self.OutputArea )
	--self.Output:DockMargin( spacing / 2 , spacing / 2 , spacing / 2 , spacing / 2 )
	self.Output:DockMargin( spacing , spacing , spacing , spacing )
	self.Output:Dock(FILL)
	--self.Output:SetTall(100)
end

function PANEL:HideOutput()
	self.OutputArea:Hide()
	self.EditorSplitter:Hide()
	self.Menus.View.Output:SetChecked( false )
	self.Menus.View.Output.Hovered = false

	self.EditorArea:InvalidateLayout( true )

	self:InvalidateLayout( true )
end

function PANEL:ShowOutput()
	self.OutputArea:Show()
	self.EditorSplitter:Show()
	self.Menus.View.Output:SetChecked( true )

	--self.EditorSheet:InvalidateLayout( true )
	self.EditorSheet:SetTall(100)

	--self:InvalidateLayout( true )
end

function PANEL:SetupEditorSheet()
	self.EditorSheet = vgui.Create( "DPropertySheet" , self.EditorArea )
	self.EditorSheet:SetPadding( spacing )
	self.EditorSheet:DockMargin( spacing / 2 , spacing / 2 , spacing / 2 , spacing )
	self.EditorSheet:Dock(FILL)
	self.EditorSheet:SetFadeTime(0)

	self.EditorSheet.OnKeyCodePressed = function( self , code )
		if self:GetParent().OnKeyCodePressed then
			self:GetParent():OnKeyCodePressed( code )
		end
	end


	self.EditorSheet.tabScroller:SetOverlap( 2 )

	self.EditorSheet.tabScroller.PerformLayout = function( self , w , h )

		local w , h = self:GetSize( )

		self.pnlCanvas:SetTall( h )

		local x = 0

		for k, v in pairs( self.Panels ) do

			v:SetPos( x + 2 , 0 )
			v:SetTall( h )
			v:ApplySchemeSettings()

			x = x + v:GetWide() - self.m_iOverlap

		end

		self.pnlCanvas:SetWide( x + self.m_iOverlap + 2 )

		if ( w < self.pnlCanvas:GetWide() ) then
			self.OffsetX = math.Clamp( self.OffsetX, 0, self.pnlCanvas:GetWide() - self:GetWide() )
		else
			self.OffsetX = 0
		end

		self.pnlCanvas.x = self.OffsetX * -1

		self.btnLeft:SetSize( 15, 15 )
		self.btnLeft:AlignLeft( 4 )
		self.btnLeft:AlignBottom( 5 )

		self.btnRight:SetSize( 15, 15 )
		self.btnRight:AlignRight( 4 )
		self.btnRight:AlignBottom( 5 )

		self.btnLeft:SetVisible( self.pnlCanvas.x < 0 )
		self.btnRight:SetVisible( self.pnlCanvas.x + self.pnlCanvas:GetWide() > self:GetWide() )

	end
end

function PANEL:AddEditorTab( name , icon )
	name = name or "new " .. #self.Editors + 1
	icon = icon or "icon16/page.png"

	local editor = vgui.Create( "Luabox_Editor" , self )
	editor:SetIgnoreTilde( self.Menus.Tools.TildeIgnore:GetChecked() )
	editor.OldLayout = editor.PerformLayout

	editor.PerformLayout = function( editor , w , h )
		editor.OldLayout( editor , w , h )
		editor:SetTall( self.EditorSheet:GetTall() - (20)  - (spacing * 2) )
		editor:SetWide( self.EditorSheet:GetWide() - (spacing * 2) )
	end

	if #self.Editors == 0 then
		editor:RequestFocus()
	end

	local sheet = self.EditorSheet:AddSheet( name , editor , icon , false , false , name )

	local tab = sheet.Tab
	tab.Sheet = sheet

	tab.oldsize = tab.GetContentSize
	tab.GetContentSize = function( tab )
		local x , y = tab.oldsize( tab )
		return (x + 12 ) , y
	end

	tab.OldClick = tab.DoClick
	tab.DoClick = function( tab )
		tab.OldClick( tab )

		tab.Sheet.Panel:RequestFocus()
	end

	tab:InvalidateLayout( true )

	local closebutton = vgui.Create( "Luabox_Tab_Close" , tab )
	closebutton:SetSize( 12 , 12 )
	closebutton:SetPos( tab:GetWide() - 18 , 6 )
	closebutton.InvalidateLayout = function( closebutton )
		closebutton:SetPos( tab:GetWide() - 18 , 6 )
	end

	closebutton.DoClick = function( closebutton )
		self:RemoveEditorTab( tab )
	end

	table.insert( self.Editors , sheet )

	return sheet
end

function PANEL:OpenFile( file )
	if not file:GetSingleFile() then return end

	local sheet = self:AddEditorTab( file:GetName() )

	local contents = string.Explode( "\n" , file:Read() )

	for i , v in ipairs( contents ) do
		sheet.Panel.Rows[ i ] = v
	end

	self:SetActiveEditor( sheet )
	sheet.Panel:SetCaretPos( #contents , #contents[#contents] + 1)
end

function PANEL:GetTabContents( tab )
	tab = tab or self.EditorSheet:GetActiveTab()
	local contents

	if tab then
		if tab.Sheet then
			if tab.Sheet.Panel then
				contents = table.concat( tab.Sheet.Panel.Rows , "\n" )
			end
		end
	end

	return contents
end

function PANEL:RemoveEditorTab( tab )
	tab = tab or self.EditorSheet:GetActiveTab()
	local key = table.RemoveByValue( self.Editors , tab.Sheet )


	if #self.EditorSheet.Items == 1 then
		self.EditorSheet:SetActiveTab(nil)
	elseif key > 1 then
		self:SetActiveEditor( self.Editors[ key - 1 ] )
	else
		self:SetActiveEditor( self.Editors[ key ] )
	end

	self.EditorSheet:CloseTab( tab , true )
end

function PANEL:GetActiveEditor()
	if not self.EditorSheet:GetActiveTab() then return end
	return self.EditorSheet:GetActiveTab().Sheet.Panel
end

function PANEL:SetActiveEditor( sheet )
	self.EditorSheet:SetActiveTab( sheet.Tab )
	sheet.Panel:RequestFocus()
end

function PANEL:LoadSettings()
	if not file.Exists( "luabox_editor_settings.txt" , "DATA" ) then return false end
	local settings = util.JSONToTable( file.Read( "luabox_editor_settings.txt" , "DATA" ) )

	self.Settings = settings

	if settings.General then
		if settings.General.IgnoreTilde then
			self.Menus.Tools.TildeIgnore:SetChecked( settings.General.IgnoreTilde )
			self.Menus.Tools.TildeIgnore:OnChecked( settings.General.IgnoreTidle )
		end
	end

	if settings.Frame then
		if settings.Frame.Size then
			self:SetSize( settings.Frame.Size.Width , settings.Frame.Size.Height )
		end

		if settings.Frame.Position then
			self:SetPos( settings.Frame.Position.X , settings.Frame.Position.Y )
		end

		if settings.Frame.Size.Maximized then
			self.Maximized = settings.Frame.Size.Maximized
		end
	end

	if settings.ProjectTree then
		if settings.ProjectTree.Size then
			self.ProjectTree:SetWide( settings.ProjectTree.Size.Width )
		end

		if settings.ProjectTree.Visible then
			self:ShowProjectTree()
		else
			self:HideProjectTree()
		end
	end

	if settings.EditorSheet then
		if settings.EditorSheet.Size then
			self.OutputArea:SetTall( settings.EditorSheet.Size.Height )
		end
	end

	if settings.Output then
		if settings.Output.Visible then
			self:ShowOutput()
		else
			self:HideOutput()
		end
	end

	return true
end

function PANEL:SaveSettings()

	self.Settings.General = {
		IgnoreTilde = self.Menus.Tools.TildeIgnore:GetChecked()

	}

	self.Settings.Frame = {
		Size = {
			Width = math.Clamp( self:GetWide() , self:GetMinWidth() , ScrW() ),
			Height = math.Clamp( self:GetTall() , self:GetMinHeight() , ScrH() ),
			Maximized = self.Maximized,
		},
		Position = {
			X = math.Clamp( self.x , 0 , ScrW() - self:GetWide() ),
			Y = math.Clamp( self.y , 0 , ScrH() - self:GetTall() ),
		},
	}

	self.Settings.ProjectTree = {
		Size = {
			Width = self.ProjectTree:GetWide(),
		},
		Visible = self.ProjectTree:IsVisible(),
	}

	self.Settings.EditorSheet = {
		Size = {
			Height = self.OutputArea:GetTall(),
		},
	}

	self.Settings.Output = {
		Visible = self.OutputArea:IsVisible()
	}

	file.Write( "luabox_editor_settings.txt" , util.TableToJSON( self.Settings , true ) )
end

function PANEL:DefaultSettings()
	self:SetSize( ScrW() / 1.3 , ScrH() / 1.4 )
	self:Center()

	self:ShowProjectTree()
	self:ShowOutput()

	self.ProjectTree:SetWide( math.max( self:GetWide() / 7 , 125 ) )

	self.OutputArea:SetTall( math.max( self:GetTall() / 5 , 125 ) )

	self.Menus.Tools.TildeIgnore:SetChecked( false )
	self.Menus.Tools.TildeIgnore:OnChecked( false )
	self.Menus.Tools.TildeIgnore.Hovered = false
end



function PANEL:PerformLayout( w , h )
	self.BaseClass.PerformLayout( self )

	self.Menu:SetPos( 1 , 24 )
	self.Menu:SetWide( self:GetWide() - 2 )

	if self.OutputArea:IsVisible() then
		self.EditorSplitter:SetupBounds( self.EditorSheet.y + 50 , self.OutputArea.y + self.OutputArea:GetTall() - self.EditorSplitter:GetTall() - 28 )

		if h <= ( self.OutputArea:GetTall() + self.EditorSplitter:GetTall() + spacing * 2 + 97 ) then
			self.OutputArea:SetTall( math.max( h - self.EditorSplitter:GetTall() - spacing * 2 - 97 , 50 ) )
		end

	end
	if self.ProjectTree:IsVisible() then
		self.FileSplitter:SetupBounds( self.ProjectTree.x + 100, self.EditorArea.x + self.EditorArea:GetWide() - self.FileSplitter:GetWide() - 100 )

		if w <= (self.ProjectTree:GetWide() + spacing * 2 + 100 ) then
			self.ProjectTree:SetWide( math.Max( w - spacing * 2 - 100 , 100 ) )

		end
	end
end

function PANEL:OnKeyCodePressed( code )
	if self.HotKeyTime == FrameNumber() then return end
	self.HotKeyTime = FrameNumber()

	local alt = input.IsKeyDown(KEY_LALT) or input.IsKeyDown(KEY_RALT)
	local shift = input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)
	local control = input.IsKeyDown(KEY_LCONTROL) or input.IsKeyDown(KEY_RCONTROL)

	local hover = vgui.GetHoveredPanel()

	if control then
		if code == KEY_N then
			self:AddEditorTab()
		end

		if code == KEY_W then
			self:RemoveEditorTab()
		end
	end

	if self.ProjectTree:IsChildHovered(10) then

		if self.ProjectTree:GetSelectedItem() and code == KEY_F5 then
			self:RefreshProjectTree( self.ProjectTree:GetSelectedItem() )

			self.ProjectTree:SetSelectedItem(nil)
			return
		end

		if hover:GetName() == "DTree_Node_Button" and code == KEY_F5 then
			self:RefreshProjectTree( hover:GetParent() )
			return
		end

		if code == KEY_F5 then

			self:RefreshProjectTree()
		end
	end
end

function PANEL:Think()
	self.BaseClass.Think( self )

	if self:IsVisible() then
		if input.IsKeyDown( KEY_ESCAPE ) then
			if gui.IsGameUIVisible () then
				gui.HideGameUI ()
			else
				gui.ActivateGameUI ()
			end

			self:Close()
		end
	end
end

function PANEL:OnClose()
	self:SaveSettings()
end

vgui.Register( PANEL.ClassName , PANEL , PANEL.Base )
