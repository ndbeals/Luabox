local PANEL = {}

PANEL.ClassName = "Luabox_Editor_Frame"
PANEL.Base = "DFrame"


local spacing = 4
local crossPoly1 =
{
	{ x = 0, y = 0 },
	{ x = 2, y = 0 },
	{ x = 8, y = 7 },
	{ x = 8, y = 8 },
	{ x = 7, y = 8 },
	{ x = 0, y = 2 }
}

local crossPoly2 =
{
	{ x = 8, y = 0 },
	{ x = 7, y = 0 },
	{ x = 0, y = 7 },
	{ x = 0, y = 8 },
	{ x = 2, y = 8 },
	{ x = 8, y = 2 }
}

local colors = {
    Gray        = Color (0x80, 0x80, 0x80, 0xFF),
    DarkGray    = Color (0xA9, 0xA9, 0xA9, 0xFF),
    LightGray   = Color (0xD3, 0xD3, 0xD3, 0xFF),
    Gray707070  = Color (0x70, 0x70, 0x70, 0xFF)
}

function PANEL:SetupFileMenu()
    self.Menu:AddMenu("File")

    self.Menus.File:AddOption( "New" , function() self:AddEditorTab() end ):SetIcon( "icon16/page_white_add.png" )

    self.Menus.File:AddOption( "Open" , function() print("saved") end ):SetIcon( "icon16/folder_page.png" )

    self.Menus.File:AddOption( "Save" , function() print("saved") end ):SetIcon( "icon16/disk.png" )

    self.Menus.File:AddOption( "Save As..." , function() print("saved") end ):SetIcon( "icon16/disk.png" )

    self.Menus.File:AddOption( "Save All" , function() print("saved") end ):SetIcon( "icon16/disk_multiple.png" )

    self.Menus.File:AddOption( "Close" , function() print("saved") end ):SetIcon("icon16/circlecross.png")

    self.Menus.File:AddOption( "Exit" , function() print("saved") end ):SetIcon("icon16/cross.png")

end

function PANEL:SetupEditMenu()
    self.Menu:AddMenu("Edit")

    self.Menus.Edit:AddOption( "New" , function() print("saved") end ):SetIcon( "icon16/page_white_add.png" )

    self.Menus.Edit:AddOption( "Open" , function() print("saved") end ):SetIcon( "icon16/folder_page.png" )

    self.Menus.Edit:AddOption( "Save" , function() print("saved") end ):SetIcon( "icon16/disk.png" )

    self.Menus.Edit:AddOption( "Save As..." , function() print("saved") end ):SetIcon( "icon16/disk.png" )

    self.Menus.Edit:AddOption( "Save All" , function() print("saved") end ):SetIcon( "icon16/disk_multiple.png" )

    self.Menus.Edit:AddOption( "Close" , function() print("saved") end ):SetIcon("icon16/circlecross.png")

    self.Menus.Edit:AddOption( "Exit" , function() print("saved") end ):SetIcon("icon16/cross.png")
end

function PANEL:SetupViewMenu()
    self.Menu:AddMenu("View")

    self.Menus.View:AddOption( "New" , function() print("saved") end ):SetIcon( "icon16/page_white_add.png" )

    self.Menus.View:AddOption( "Open" , function() print("saved") end ):SetIcon( "icon16/folder_page.png" )

    self.Menus.View:AddOption( "Save" , function() print("saved") end ):SetIcon( "icon16/disk.png" )

    self.Menus.View:AddOption( "Save As..." , function() print("saved") end ):SetIcon( "icon16/disk.png" )

    self.Menus.View:AddOption( "Save All" , function() print("saved") end ):SetIcon( "icon16/disk_multiple.png" )

    self.Menus.View:AddOption( "Close" , function() print("saved") end ):SetIcon("icon16/circlecross.png")

    self.Menus.View:AddOption( "Exit" , function() print("saved") end ):SetIcon("icon16/cross.png")
end

function PANEL:SetupToolsMenu()
    self.Menu:AddMenu("Tools")

    self.Menus.Tools:AddOption( "New" , function() print("saved") end ):SetIcon( "icon16/page_white_add.png" )

    self.Menus.Tools:AddOption( "Open" , function() print("saved") end ):SetIcon( "icon16/folder_page.png" )

    self.Menus.Tools:AddOption( "Save" , function() print("saved") end ):SetIcon( "icon16/disk.png" )

    self.Menus.Tools:AddOption( "Save As..." , function() print("saved") end ):SetIcon( "icon16/disk.png" )

    self.Menus.Tools:AddOption( "Save All" , function() print("saved") end ):SetIcon( "icon16/disk_multiple.png" )

    self.Menus.Tools:AddOption( "Close" , function() print("saved") end ):SetIcon("icon16/circlecross.png")

    self.Menus.Tools:AddOption( "Exit" , function() print("saved") end ):SetIcon("icon16/cross.png")
end

function PANEL:SetupHelpMenu()
    self.Menu:AddMenu("Help")

    self.Menus.Help:AddOption( "New" , function() print("saved") end ):SetIcon( "icon16/page_white_add.png" )

    self.Menus.Help:AddOption( "Open" , function() print("saved") end ):SetIcon( "icon16/folder_page.png" )

    self.Menus.Help:AddOption( "Save" , function() print("saved") end ):SetIcon( "icon16/disk.png" )

    self.Menus.Help:AddOption( "Save As..." , function() print("saved") end ):SetIcon( "icon16/disk.png" )

    self.Menus.Help:AddOption( "Save All" , function() print("saved") end ):SetIcon( "icon16/disk_multiple.png" )

    self.Menus.Help:AddOption( "Close" , function() print("saved") end ):SetIcon("icon16/circlecross.png")

    self.Menus.Help:AddOption( "Exit" , function() print("saved") end ):SetIcon("icon16/cross.png")
end

function PANEL:SetupFileTree()
    self.ProjectTree = vgui.Create( "Luabox_File_Tree" , self )
    self.ProjectTree:SetWide( math.max( self:GetWide() / 8 , 100 ) )
    self.ProjectTree:DockMargin( spacing / 2 , spacing / 2 , spacing / 2 , spacing /2 )
    self.ProjectTree:Dock(LEFT)
end

function PANEL:SetupEditorSheet()
    self.EditorSheet = vgui.Create( "DPropertySheet" , self.EditorArea )
    self.EditorSheet:SetPadding( spacing )
    self.EditorSheet:DockMargin( spacing / 2 , spacing / 2 , spacing / 2 , spacing / 2 )
    self.EditorSheet:Dock(FILL)
    self.EditorSheet:SetFadeTime(0)

    self.EditorSheet.tabScroller:SetOverlap( 2 )

    self.EditorSheet.tabScroller.PerformLayout = function( self , w , h )

    	local w, h = self:GetSize()

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

function PANEL:SetupAreas()
    self.EditorArea = vgui.Create( "DPanel" , self )
    self.EditorArea:SetPaintBackground( false )
    self.EditorArea:DockMargin( 0 , 0 , 0 , 0 )
    self.EditorArea:Dock(FILL)

    self.OutputArea = vgui.Create( "DPanel" , self.EditorArea )
    self.OutputArea:DockMargin( spacing / 2 , spacing / 2 , spacing / 2 , spacing / 2 )
    self.OutputArea:Dock(BOTTOM)
    self.OutputArea:SetTall( 140 )
    self.OutputArea.GetActiveTab = function() end --hack so I can use DPropertySheet draw hook
    self.OutputArea.Paint = function( pnl , w , h )
        derma.SkinHook( "Paint" , "PropertySheet" , pnl , w , h )
    end

    self.EditorSplitter = vgui.Create( "Luabox_Splitter" , self.EditorArea )
    self.EditorSplitter:DockMargin( spacing / 2 , -spacing / 4 , spacing / 2 , -spacing / 4 )
    self.EditorSplitter:Dock(BOTTOM)
    self.EditorSplitter:SetTall(10)
    self.EditorSplitter:SetPanel1( self.EditorSheet )
    self.EditorSplitter:SetPanel2( self.OutputArea )

    self.FileSplitter = vgui.Create( "Luabox_Splitter" , self )
    self.FileSplitter:SetOrientation( 1 )
    self.FileSplitter:DockMargin( -spacing / 4 , spacing / 2 , -spacing / 4 , spacing / 2 )
    self.FileSplitter:Dock(LEFT)
    self.FileSplitter:SetPanel1( self.ProjectTree )
    self.FileSplitter:SetPanel2( self.EditorArea )
end

function PANEL:SetupConsoleOutput()
    self.ConsoleOutput = vgui.Create( "Luabox_Console_Output" , self.OutputArea )
    --self.ConsoleOutput:DockMargin( spacing / 2 , spacing / 2 , spacing / 2 , spacing / 2 )
    self.ConsoleOutput:DockMargin( spacing , spacing , spacing , spacing )
    self.ConsoleOutput:Dock(FILL)

    --self.ConsoleOutput
    --self.ConsoleOutput:SetSelection("test\ngfdg\nsdg")
    --self.ConsoleOutput:SetSelection("ararar")
    --self.ConsoleOutput.Scroll[2] = 1
    --self.ConsoleOutput:SetText("gagsfdgfssdfgghjkghjkghjkghjkghjkghjkghjkghjkghjkghjkghjkghjkcfgndtyumrtyufgyjghmitfyi dfghjcvgchkghjkghkbkhjsdfhdghfgjfghjkghjhfjklxfhglsernitulsovhldfigusvlgusdfilhxdfkvhudiofghseoriugeufuhsdovbsdfoivnseipurogberubsfidvsdouhkghjkghjkhghdfghdfghjkghjkooooooooooooooook")
    self.ConsoleOutput.Rows[1] = "hello"
    self.ConsoleOutput.Rows[2] = "World"
    --self.ConsoleOutput:SetText("gag2")
    --PrintTable(self.ConsoleOutput.Rows)
end

function PANEL:AddEditorTab( name , icon )
    name = name or "new"..#self.Editors
    icon = icon or "icon16/page.png"

    local editor = vgui.Create( "Luabox_Editor" , self )

    local sheet = self.EditorSheet:AddSheet( name , editor , icon , false , false , name )

    local tab = sheet.Tab
    tab.oldsize = tab.GetContentSize

    function tab.GetContentSize( tab )
        local x , y = tab.oldsize( tab )
        return (x + 12 ) , y
    end
    tab:PerformLayout()

    local closebutton = vgui.Create( "Luabox_Tab_Close" , tab )
    closebutton:SetSize( 12 , 12 )
    closebutton:SetPos( tab:GetWide() - 18 , 6 )
    closebutton.InvalidateLayout = function( closebutton )
        closebutton:SetPos( tab:GetWide() - 18 , 6 )
    end

    closebutton.DoClick = function( closebutton )
        if #self.EditorSheet.Items == 1 then
            self.EditorSheet:SetActiveTab(nil)
        end

        self.EditorSheet:CloseTab( tab , true )
    end

    function editor.InvalidateLayout( editor )
    	editor:SetTall( self.EditorSheet:GetTall() - (20)  - (spacing * 2) )
    	editor:SetWide( self.EditorSheet:GetWide() - (spacing * 2) )
    end

    table.insert( self.Editors , sheet )

    return sheet
end

function PANEL:RemoveEditorTab()

end


function PANEL:Init()
    local SW , SH = ScrW() , ScrH()
    self:SetSize( SW / 1.1 , SH / 1.125 )
    self:SetMinWidth( 200 )
    self:SetMinHeight( 100 )

    self.Editors = {}

    self.Menu = vgui.Create( "DMenuBar" , self )
    self.Menus = self.Menu.Menus
    self.Menu:Dock(NODOCK)
    self:DockPadding( spacing / 2 , (spacing / 2) + 23 + self.Menu:GetTall() , spacing / 2 , spacing / 2 )

    self:SetupFileTree()

    self:SetupAreas()

    self:SetupFileMenu()

    self:SetupEditMenu()

    self:SetupViewMenu()

    self:SetupToolsMenu()

    self:SetupHelpMenu()

    self:SetupEditorSheet()

    self:SetupConsoleOutput()



    --self:AddEditorTab("googoocaakaapoopooothreeletterwordsarenothatlong")

    --self:AddEditorTab()

    --self.ProjectTree:Root():AddNode("test1"):AddNode("test2"):AddNode("test3")

    local node = self.ProjectTree:Root()
    node:AddNode("test")
    for i = 1 , 30 do
        --self.ProjectTree:Root():AddNode("blah"..i)
        node = node:AddNode("test"..i)
        node:AddNode("Space")
        node:AddNode("Space")

        --self.ProjectTree.pnlCanvas:PerformLayout()
        --self.ProjectTree:InvalidateLayout()
    end

--[[

    self.ProjectTree:Root():AddFolder("Test" , "luapad" , "DATA" , true ):AddFolder("Test1" , "luapad" , "DATA" , true ):AddFolder("Test2" , "luapad" , "DATA" , true ):AddFolder("Test3" , "luapad" , "DATA" , true ):AddFolder("Test4" , "luapad" , "DATA" , true ):AddFolder("Test5" , "luapad" , "DATA" , true ):AddFolder("Test6" , "luapad" , "DATA" , true ):AddFolder("Test7" , "luapad" , "DATA" , true ):AddFolder("Test8" , "luapad" , "DATA" , true ):AddFolder("Test9" , "luapad" , "DATA" , true ):AddFolder("Test10" , "luapad" , "DATA" , true )
    self.ProjectTree:Root():AddFolder("Test" , "luapad" , "DATA" , true )
    self.ProjectTree:Root():AddFolder("Test" , "luapad" , "DATA" , true )
    self.ProjectTree:Root():AddFolder("Test" , "luapad" , "DATA" , true )

    --self.ProjectTree:PerformLayout()


	--local test = vgui.Create("DPanel",self)

	--self.Editor = vgui.Create( "Luabox_Editor" , self )
	--self.Editor:SetSize(900,600)




--]]

end


function PANEL:PerformLayout( w , h )
    self.BaseClass.PerformLayout( self )

    self.Menu:SetPos( 1 , 24 )
    self.Menu:SetWide( self:GetWide() - 2 )

    if self.ProjectTree:GetWide() > ( w - 100 ) then
        print("wafa")
        self.ProjectTree:SetWide( math.Max( w - 100 , 100 ) )
    end

    --self.EditorSplitter:SetPos( self.EditorSheet.x , self.EditorSheet.y + self.EditorSheet:GetTall() + spacing )
    --self.EditorSplitter:SetSize( self.EditorSheet:GetWide() , 8 )
    self.EditorSplitter:SetupBounds( self.EditorSheet.y + 50 , self.OutputArea.y + self.OutputArea:GetTall() - self.EditorSplitter:GetTall() - 28 )
    self.FileSplitter:SetupBounds( self.ProjectTree.x + 100, self.EditorArea.x + self.EditorArea:GetWide() - self.FileSplitter:GetWide() - 100 )

    --print("wgds",w,h)
end

vgui.Register( PANEL.ClassName , PANEL , PANEL.Base )



PANEL = {}
PANEL.ClassName = "Luabox_Tab_Close"
PANEL.Base = "DButton"

function PANEL:DrawCross( col , xo , yo )
	local sw , sh = ScrW() , ScrH()

	render.SetViewPort( 2 + xo , 2 + yo , sw , sh )

	surface.SetTexture ( -1 )
	surface.SetDrawColor ( col )
	surface.DrawPoly ( crossPoly1 )
	surface.DrawPoly ( crossPoly2 )

    render.SetViewPort( 0 , 0 , sw , sh )
end

function PANEL:Init()
	self:SetText( "" )
    self:SetMouseInputEnabled( true )
end

function PANEL:Paint( w , h )
    if self:IsHovered () then
		-- Enabled and hovered
		if self.Pressed then
			draw.RoundedBox (4, 0, 0, w , h , colors.Gray)
			draw.RoundedBox (4, 1, 1, w - 2, h - 2, colors.DarkGray)
		else
			draw.RoundedBox (4, 0, 0, w , h , colors.Gray)
			draw.RoundedBox (4, 1, 1, w - 2, h - 2, colors.LightGray)
		end
	end

    if not self:GetDisabled() then
        -- Enabled
        if self.Pressed then
            self:DrawCross( colors.Gray , 1 , 1 )
        elseif self:IsHovered () then
            self:DrawCross( colors.Gray , 0 , 0 )
        else
            if self:GetParent () and not self:GetParent ():IsSelected () then
                self:DrawCross( colors.Gray707070 , 0 , 0 )
            else
                self:DrawCross( colors.DarkGray , 0 , 0 )
            end
        end
    else
        -- Disabled
        self:DrawCross( colors.Gray , 0 , 0 )
    end
end

function PANEL:OnDepressed()
	self.Pressed = true
end

function PANEL:OnReleased()
	self.Pressed = false
end

function PANEL:DoClick()
	print "clocked"
end

function PANEL:PerformLayout()
	self.BaseClass.PerformLayout( self )
end

vgui.Register( PANEL.ClassName , PANEL , PANEL.Base )

print("reloadeded")
