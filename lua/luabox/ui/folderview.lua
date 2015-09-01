local PANEL = {}
PANEL.ClassName = "Luabox_Folder_View_Row"
PANEL.Base = "DLabel"
local spacing = 4

function PANEL:SetBackgroundColor( col )
    self.m_bgColor = col
end

function PANEL:Init()
    self.Name = ""
    self.Size = 0
    self.Date = 0

    self.DateLabel = vgui.Create( "DLabel" , self )
    self.DateLabel:SetTextColor( luabox.Colors.Outline )

    self.SizeLabel = vgui.Create( "DLabel" , self )
    self.SizeLabel:SetTextColor( luabox.Colors.Outline )

    self.NameLabel = vgui.Create( "DLabel" , self )
    self.NameLabel:SetTextColor( luabox.Colors.Outline )

    self.Icon = vgui.Create( "DImage" , self )
    self.Icon:SetImage( "icon16/folder.png" )

    self:SetText("")
    self.m_bgColor = Color(255,255,255)
end

function PANEL:SetIsFile( bool )
    if bool then
        self.Icon:SetImage( "icon16/page.png" )
    else
        self.Icon:SetImage( "icon16/folder.png" )
    end
end

function PANEL:Paint( w , h )
    surface.SetDrawColor( self.m_bgColor )
    surface.DrawRect( 0 , 0 , w , h )


    if self:IsSelected() then
        derma.SkinHook( "Paint" , "Selection" , self , w , h )
    end
end

function PANEL:SetHeaderWidth( width )
    self.HeaderWidth = width
end

function PANEL:SetInfo( filename , filesize , filedate )
    self.Name = filename
    self.Size = filesize
    self.Date = filedate

    self.NameLabel:SetText( filename )

    if filesize == 0 then
        self.SizeLabel:SetText( "" )
    else
        self.SizeLabel:SetText( string.NiceSize( filesize ) )
    end

    if filedate == 0 then
        self.DateLabel:SetText( "" )
    else
        self.DateLabel:SetText( os.date( "%c" , filedate ) )
    end
end

function PANEL:PerformLayout( w , h )
    self.Icon:SetSize( 16 , 16 )
    self.Icon:SetPos( spacing , (h - self.Icon:GetTall() ) / 2 )

    self.NameLabel:SetWide( self:GetWide() - self.HeaderWidth * 2 - (spacing * 6.5) )
    --self.NameLabel:SetPos( spacing * 1.5 , 0 )
    self.NameLabel.y = (h - self.NameLabel:GetTall() ) / 2
    self.NameLabel:MoveRightOf( self.Icon , spacing * 1.5 )

    self.SizeLabel:SetWide( self.HeaderWidth - spacing * 1.5 )
    self.SizeLabel.y = (h - self.SizeLabel:GetTall() ) / 2
    self.SizeLabel:MoveRightOf( self.NameLabel , spacing * 1.5 )

    self.DateLabel:SetWide( self.HeaderWidth - spacing * 1.5 )
    self.DateLabel.y = (h - self.DateLabel:GetTall() ) / 2
    self.DateLabel:MoveRightOf( self.SizeLabel , spacing * 1.5 )
end

function PANEL:SetFileSystem( fs )
    self.FileSystem = fs
end

function PANEL:GetFileSystem()
    return self.FileSystem
end


vgui.Register( PANEL.ClassName , PANEL , PANEL.Base )



local PANEL = {}
PANEL.ClassName = "Luabox_Folder_View"
PANEL.Base = "DPanel"

--PANEL.MinimumHeaderWidth = 50

function PANEL:Init()

    self:DockPadding( 0 , 0 , 0 , 0 )

    self.Headers = {}

    self.Rows = {}
    self.Files = {}
    self.Directories = {}

    self.HeaderWidth = 100

    self:SetupHeader()

    self:SetupList()
end

function PANEL:Paint( w , h )
    draw.RoundedBox( 4 , 0 , 0 , w , h , self.m_bgColor )
end

function PANEL:SetupHeader()


    self.HeaderArea = vgui.Create( "DPanel" , self )
    self.HeaderArea:Dock( TOP )

    self.FileHeader = vgui.Create( "DButton" , self.HeaderArea )
    self.FileHeader:DockMargin( -1 , -1 , 0 , 0 )
    self.FileHeader:Dock( FILL )
    self.FileHeader:SetText( "Name" )
    --[[
    self.FileHeader.ResizeColumn = function( button , wide )
        self:ResizeColumn( button , self.FileHeaderSizer , wide )
    end

    self.FileHeaderSizer = vgui.Create( "DListView_DraggerBar" , self.FileHeader )
    self.FileHeaderSizer:SetWide( 4 )
    self.FileHeaderSizer:Dock( RIGHT )
    --]]

    table.insert( self.Headers , { Header = self.FileHeader , Sizer = self.FileHeaderSizer } )

    self.DateHeader = vgui.Create( "DButton" , self.HeaderArea )
    self.DateHeader:DockMargin( -1 , -1 , -1 , 0 )
    self.DateHeader:Dock( RIGHT )
    self.DateHeader:SetText( "Date Modified" )
    self.DateHeader:SetWide( self.HeaderWidth )
    --[[
    self.DateHeader.ResizeColumn = function( button , wide )
        self:ResizeColumn( button , self.DateHeaderSizer , wide )
    end

    self.DateHeaderSizer = vgui.Create( "DListView_DraggerBar" , self.DateHeader )
    self.DateHeaderSizer:SetWide( 4 )
    self.DateHeaderSizer:Dock( RIGHT )
    --]]

    table.insert( self.Headers , { Header = self.DateHeader , Sizer = self.DateHeaderSizer } )


    self.SizeHeader = vgui.Create( "DButton" , self.HeaderArea )
    self.SizeHeader:DockMargin( -1 , -1 , 0 , 0 )
    self.SizeHeader:Dock( RIGHT )
    self.SizeHeader:SetText( "Size" )
    self.SizeHeader:SetWide( self.HeaderWidth )
    --[[
    self.SizeHeader.ResizeColumn = function( button , wide )
        self:ResizeColumn( button , self.SizeHeaderSizer , wide )
    end

    self.SizeHeaderSizer = vgui.Create( "DListView_DraggerBar" , self.SizeHeader )
    self.SizeHeaderSizer:SetWide( 4 )
    self.SizeHeaderSizer:Dock( RIGHT )
    --]]

    table.insert( self.Headers , { Header = self.SizeHeader , Sizer = self.SizeHeaderSizer } )

end

function PANEL:ResizeColumn( header , sizer , wide )

    local startsizing = false
    local remainingwidth = 0
    local remainingheaders = 0
    local minwidth = 0

    for i , v in ipairs( self.Headers ) do
        if v.Header == header then
            startsizing = true

            remainingheaders = ( #self.Headers - i)
            minwidth = self.MinimumHeaderWidth * remainingheaders

            if wide + minwidth >= self:GetWide() then
                wide = self:GetWide() - minwidth
            end

            wide = math.Max( wide , self.MinimumHeaderWidth )

            remainingwidth = self:GetWide() - wide

        end

        if startsizing then
            v.Header:SetWide( remainingwidth / remainingheaders )
            --v.Sizer:AlignRight()
        end

    end

    header:SetWide( wide )
    --sizer:AlignRight()
end

function PANEL:SetupList()
    self.FileList = vgui.Create( "DListLayout" , self )
    self.FileList:DockMargin( 0 , -1 , 0 , 0 )
    self.FileList:Dock( FILL )
    --self.FileList:SetTall(400)
    --self.FileList:SetWide(300)
    self.FileList:MakeDroppable( "luabox_file_drop" , true )
    self.FileList:SetSelectionCanvas( true )
    self.FileList:SetDropPos( "5" )

    self.FileList.PerformLayout = function() end

    self.FileList:Receiver( "luabox_file_drop" , self.DropAction )

    self.FileList.OnMousePressed = function( list , mousecode )

        if mousecode == MOUSE_RIGHT then
            self:DoRightClick()
        end

        if ( list.m_bSelectionCanvas && !dragndrop.IsDragging() ) then
            list:StartBoxSelection();
            return
        end

        if ( list:IsDraggable() ) then

            list:MouseCapture( true )
            list:DragMousePress( mousecode );

        end
    end


    self.FileList.PaintOver = function( pnl , w , h )

        if not w or not h then
            w = self:GetWide()
            h = self:GetTall()
        end

        surface.SetDrawColor( Color ( 91 , 96 , 100 , 255 ) )
        surface.DrawLine( -1 , 0 , w , 0 )

        for i = 2 , #self.Headers do
            local header = self.Headers[i].Header
            surface.DrawLine( header.x , 0 , header.x , h )
        end
    end

    self.FileList.OnModified = function( list )
        self:ColorRows()

        self:GetParent():GetParent():RefreshFileTree()
    end

    self.FileList.OldStartBoxSelection = self.FileList.StartBoxSelection

    self.FileList.StartBoxSelection = function( list )

        list.OldStartBoxSelection( list )

        local drawselection = list.PaintOver
        local drawlist = list.PaintOver_Old

        list.PaintOver = function( list , w , h )
            drawlist( list , w , h )

            drawselection( list , w , h )
        end
    end
end

function PANEL:AddRow( filename , filesize , filedate )
    local row = vgui.Create( "Luabox_Folder_View_Row" )
    row:DockPadding( 0 , 0 , 0 , 0 )
    row:SetHeaderWidth( self.HeaderWidth )
    row:SetInfo( filename , filesize , filedate )
    row:SetSelectable(true)

    row.DroppedOn = function( row , drop )
        local success = drop.FileSystem:Move( row.FileSystem )

        if success then
            drop:Remove()

            table.RemoveByValue( self.Rows , drop )
            table.RemoveByValue( self.Files , drop )
            table.RemoveByValue( self.Directories , drop )
        end

    end

    row.DoDoubleClick = function( row )
        if not row.FileSystem:GetSingleFile() then
            self:SetFileSystem( row.FileSystem )

            --self:GetParent():GetParent():OnFolderOpened( row.FileSystem )
        end
    end

    row.DoClick = function( row )
        if self.SelectedRow == row then
            row:SetSelected( false )

            self.SelectedRow = nil
            return
        end

        if IsValid( self.SelectedRow ) then
            self.SelectedRow:SetSelected( false )
        end

        self.SelectedRow = row
        row:SetSelected( true )

        if row.OnClick then
            row:OnClick()
        end

    end

    table.insert( self.Rows , row )

    self:ColorRows()

    self.FileList:Add( row )

    return row
end

function PANEL:ColorRows()
    for i , row in ipairs( self.Rows ) do
        if i % 2 == 1 then
            row:SetBackgroundColor( luabox.Colors.White )
        else
            row:SetBackgroundColor( luabox.Colors.LightGray )
        end
    end
end

function PANEL:DropAction( Drops, bDoDrop, Command, x, y )
	local closest = self:GetClosestChild( x, y )

	if ( !IsValid( closest ) ) then
		return self:DropAction_Simple( Drops, bDoDrop, Command, x, y )
	end

	local h = closest:GetTall()
	local w = closest:GetWide()

	local drop = 0
	if ( self.bDropCenter ) then drop = 5 end

    self:SetDropTarget( closest.x, closest.y, closest:GetWide() , closest:GetTall() )

    for k , v in pairs(Drops) do
        --v.Selected = true
    end

	if ( table.HasValue( Drops, closest ) ) then return end

	if ( !bDoDrop && !self:GetUseLiveDrag() ) then return end

	for k, v in pairs( Drops ) do

        --v.Selected = false
		-- Don't drop one of our parents onto us
		-- because we'll be sucked into a vortex
		if ( v:IsOurChild( self ) ) then continue end

		v = v:OnDrop( self )

		if ( drop == 5 ) then
			closest:DroppedOn( v )
		end
	end

	self:OnModified()
end

function PANEL:SetFileSystem( fs )
    --if self.FileSystem == fs then return end
    self.FileSystem = fs

    self:Clear()

    local back = self:AddRow( ".." , 0 , 0 )
    back:SetFileSystem( self.FileSystem:GetRootFileSystem() )
    back.DoDoubleClick = function( back )
        self:SetFileSystem( back:GetFileSystem() )
    end

    table.insert( self.Directories , back )

    back:SetSelectable( false )

    for i , v in ipairs( fs:GetDirectories() ) do
        local row = self:AddRow( v:GetName() , 0 , file.Time( v:GetPath() , "DATA" ) )
        row:SetFileSystem( v )

        table.insert( self.Directories , row )
    end

    for i , v in ipairs( fs:GetFiles() ) do
        local row = self:AddRow( v:GetName() , file.Size( v:GetPath() , "DATA" ) , file.Time( v:GetPath() , "DATA" ) )
        row:SetIsFile( true )
        row:SetFileSystem( v )

        table.insert( self.Files , row )
    end

    self:GetParent():GetParent():OnFolderViewChanged( fs )
end

function PANEL:GetFileSystem()
    return self.FileSystem
end

function PANEL:Clear()
    for i , v in ipairs( self.Rows ) do
        v:Remove()
    end

    self.Rows = {}
    self.Files = {}
    self.Directories = {}
end

function PANEL:Refresh()
    self:SetFileSystem( self.FileSystem )
end

function PANEL:PerformLayout()



    --[[
    self.FileHeaderSizer:StretchToParent( nil , 0 , nil , 0 )
    self.FileHeaderSizer:AlignRight()

    self.SizeHeaderSizer:StretchToParent( nil , 0 , nil , 0 )
    self.SizeHeaderSizer:AlignRight()

    self.DateHeaderSizer:StretchToParent( nil , 0 , nil , 0 )
    self.DateHeaderSizer:AlignRight()
    --]]
end

function PANEL:OnMousePressed( mousecode )

	if ( self:GetDisabled() ) then return end

	if ( mousecode == MOUSE_LEFT && !dragndrop.IsDragging() && self.m_bDoubleClicking ) then

		if ( self.LastClickTime && SysTime() - self.LastClickTime < 0.2 ) then

			self:DoDoubleClickInternal()
			self:DoDoubleClick()
			return

		end

		self.LastClickTime = SysTime()
	end

	-- If we're selectable and have shift held down then go up
	-- the parent until we find a selection canvas and start box selection
	if ( mousecode == MOUSE_LEFT ) then


		if ( input.IsShiftDown() ) then

			return self.FileList:StartBoxSelection()
		end

	end

	--self:MouseCapture( true )
	--self.Depressed = true
	--self:OnDepressed()
	--self:InvalidateLayout( true )

end

vgui.Register( PANEL.ClassName , PANEL , PANEL.Base )
