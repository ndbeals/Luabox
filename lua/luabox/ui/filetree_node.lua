local PANEL = {}
PANEL.ClassName = "Luabox_File_Tree_Node"
PANEL.Base = "DTree_Node"

function PANEL:Init()

    self.Label.DoDoubleClick = function( lbl )
        self:InternalDoDoubleClick()
    end

    self.Files = {}
    self.Directories = {}
end

function PANEL:DoDoubleClick()
end

function PANEL:InternalDoDoubleClick()

	self:GetRoot():SetSelectedItem( self )

	if ( self:DoDoubleClick() ) then return end
	if ( self:GetRoot():DoClick( self ) ) then return end

	if self.m_bDoubleClickToOpen then
		self:SetExpanded( !self.m_bExpanded )
	end
end

function PANEL:InternalDoClick()

	self:GetRoot():SetSelectedItem( self )

	if ( self:DoClick() ) then return end
	if ( self:GetRoot():DoClick( self ) ) then return end

	if self.m_bDoubleClickToOpen and (SysTime() - self.fLastClick < 0.2 ) then
		self:SetExpanded( !self.m_bExpanded )
	end
    self.fLastClick = SysTime()
end

function PANEL:AddNode( strName, strIcon )

	self:CreateChildNodes()

	local pNode = vgui.Create( "Luabox_File_Tree_Node", self )
		pNode:SetText( strName )
		pNode:SetParentNode( self )
		pNode:SetRoot( self:GetRoot() )
		pNode:SetIcon( strIcon )
		pNode:SetDrawLines( !self:IsRootNode() )

		self:InstallDraggable( pNode )

	self.ChildNodes:Add( pNode )
	self:InvalidateLayout()

	return pNode

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

function PANEL:SetExpandedRecurse( expanded , supressanim )
    supressanim = supressanim or true

    if not expanded then return end

    self:SetExpanded( expanded.Expanded , supressanim)

    for i , v in ipairs( self.ChildNodes:GetChildren() ) do
        if #v.Directories > 0 or #v.Files > 0 then
            v:SetExpandedRecurse( expanded[ v:GetFileSystem() ] )
        end
    end
end

function PANEL:SetFileSystem( fs )
	self.FileSystem = fs
	self.Files = {}
	self.Directories = {}

    self:CreateChildNodes()

    if fs:GetSingleFile() then return end

	for i , v in ipairs( fs:GetDirectories() ) do
		local node = self:AddNode( v:GetName() )
		node:SetFileSystem( v )

		self.Directories[ i ] = node
	end

	for i , v in ipairs( fs:GetFiles() ) do
		local node = self:AddNode( v:GetName() , "icon16/page.png")
        node:SetFileSystem( v )

		self.Files[ i ] = node
	end
end

function PANEL:GetFileSystem()
    return self.FileSystem
end

function PANEL:Refresh()
    if not self.ChildNodes or not self.FileSystem then return end

    local wasexpanded = self:GetExpanded() or false
    local expanded = expandhelper( self )

	local del = self.ChildNodes
	self.ChildNodes = nil
	self:CreateChildNodes()
	del:Remove()
    del = nil

    self.Files = {}
    self.Directories = {}

    self.FileSystem:Refresh( true )

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
end

function PANEL:GetExpanded()
    return self.m_bExpanded
end

vgui.Register( PANEL.ClassName , PANEL, PANEL.Base )
