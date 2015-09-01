local PANEL = {}
PANEL.ClassName = "Luabox_File_Tree"
PANEL.Base = "Luabox_Scroll_Panel"

AccessorFunc( PANEL, "m_bShowIcons", 			"ShowIcons" )
AccessorFunc( PANEL, "m_iIndentSize", 			"IndentSize" )
AccessorFunc( PANEL, "m_iLineHeight", 			"LineHeight" )
AccessorFunc( PANEL, "m_pSelectedItem",			"SelectedItem" )
AccessorFunc( PANEL, "m_bClickOnDragHover",		"ClickOnDragHover" )

--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()
	self.Files = {}
	self.Directories = {}

	self.LastClick = RealTime()

	--self:SetMouseInputEnabled( true )
	--self:SetClickOnDragHover( false )

	self:SetShowIcons( true )
	self:SetIndentSize( 14 )
	self:SetLineHeight( 17 )
	--self:SetPadding( 2 )

	self.RootNode = self:GetCanvas():Add( "Luabox_File_Tree_Node" );
	self.RootNode:SetRoot( self )
	self.RootNode:SetParentNode( self )
	self.RootNode:Dock( TOP )
	self.RootNode:SetText( "" )
	self.RootNode:SetExpanded( true, true )
	self.RootNode:DockMargin( 0, 4, 0, 0 )

	self:SetPaintBackground( true )

	self:GetCanvas().OnMousePressed = function( canvas , code )
		if code == MOUSE_RIGHT then
			self:DoBaseRightClick()
		end

		if (RealTime() - self.LastClick) <= 0.2 then
			self:DoBaseDoubleClick()
		end

		self.LastClick = RealTime()
	end

end

function PANEL:GetFileSystem()
	return self.FileSystem
end

function PANEL:SetFileSystem( fs )
	self.FileSystem = fs
	self.Files = {}
	self.Directories = {}

	local del = self.RootNode.ChildNodes
	self.RootNode.ChildNodes = nil
	self.RootNode:CreateChildNodes()
	if del then	del:Remove() end
	del = nil

	if fs:GetSingleFile() then
		local node = self:AddNode( fs:GetName() , "icon16/page.png" )
		node:SetFileSystem( fs )
		self.Files[ 1 ] = node

		return
	end

	for i , v in ipairs( fs:GetDirectories() ) do
		local node = self:AddNode( v:GetName() )
		node:SetFileSystem( v )

		self.Directories[ i ] = node
	end

	for i , v in ipairs( fs:GetFiles() ) do
		local node = self:AddNode( v:GetName() , "icon16/page.png" )
		node:SetFileSystem( v )

		self.Files[ i ] = node
	end
end

local function expandhelper( node , expanded )
	expanded = expanded or {}

	for i , v in ipairs( node.ChildNodes:GetChildren() ) do

		expanded[ v:GetFileSystem() ] = {Expanded = v:GetExpanded()}
		if v.ChildNodes then
			expandhelper( v , expanded[v:GetFileSystem()] )
		end
	end
	return expanded
end

function PANEL:Refresh()

	local expanded = expandhelper( self.RootNode )

	local del = self.RootNode.ChildNodes
	self.RootNode.ChildNodes = nil
	self.RootNode:CreateChildNodes()
	del:Remove()
	del = nil

	self.Files = {}
	self.Directories = {}

	--self.FileSystem:Refresh( true )

	for i , v in ipairs( self.FileSystem:GetDirectories() ) do
		local node = self:AddNode( v:GetName() )
		node:SetFileSystem( v )

		if #v.Directories > 0 or #v.Files > 0 then
			node:SetExpandedRecurse( expanded[ v ] , true )
		end

		self.Directories[ i ] = node
	end

	for i , v in ipairs( self.FileSystem:GetFiles() ) do
		local node = self:AddNode( v:GetName() , "icon16/page.png")
		node:SetFileSystem( v )

		self.Files[ i ] = node
	end

	self:Root():SetExpanded( true , true )
end

--
-- Get the root node
--
function PANEL:Root()
	return self.RootNode;
end

--[[---------------------------------------------------------
   Name: AddNode
-----------------------------------------------------------]]
function PANEL:AddNode( strName, strIcon )

	return self.RootNode:AddNode( strName, strIcon )

end

--[[---------------------------------------------------------
   Name: ChildExpanded
-----------------------------------------------------------]]
function PANEL:ChildExpanded( bExpand )

	self:InvalidateLayout()

end

--[[---------------------------------------------------------
   Name: ShowIcons
-----------------------------------------------------------]]
function PANEL:ShowIcons()

	return self.m_bShowIcons

end

--[[---------------------------------------------------------
   Name: ExpandTo
-----------------------------------------------------------]]
function PANEL:ExpandTo( bExpand )

end

--[[---------------------------------------------------------
   Name: SetExpanded
-----------------------------------------------------------]]
function PANEL:SetExpanded( bExpand )

	-- The top most node shouldn't react to this.

end

--[[---------------------------------------------------------
   Name: Clear
-----------------------------------------------------------]]
function PANEL:Clear()

end

--[[---------------------------------------------------------
   Name: Paint
-----------------------------------------------------------]]
function PANEL:Paint( w, h )

	derma.SkinHook( "Paint", "Tree", self, w, h )
	return true

end

--[[---------------------------------------------------------
   Name: DoClick
-----------------------------------------------------------]]
function PANEL:DoClick( node )
	return false
end

--[[---------------------------------------------------------
   Name: DoRightClick
-----------------------------------------------------------]]
function PANEL:DoRightClick( node )
	return false
end

function PANEL:DoBaseRightClick( node )
	return false
end

function PANEL:DoBaseDoubleClick( node )
	return false
end

--[[---------------------------------------------------------
   Name: SetSelectedItem
-----------------------------------------------------------]]
function PANEL:SetSelectedItem( node )

	if ( IsValid( self.m_pSelectedItem ) ) then
		self.m_pSelectedItem:SetSelected( false )
	end

	self.m_pSelectedItem = node

	if ( node ) then
		node:SetSelected( true )
		node:OnNodeSelected( node )
	end

end

function PANEL:OnNodeSelected( node )

end

function PANEL:MoveChildTo( child, pos )

	self:InsertAtTop( child )

end

function PANEL:LayoutTree()

	self:InvalidateChildren( true )

end

function PANEL:OnKeyCodePressed( code )
    if self:GetParent().OnKeyCodePressed then
        self:GetParent():OnKeyCodePressed( code )
    end
end


vgui.Register( PANEL.ClassName , PANEL, PANEL.Base )
