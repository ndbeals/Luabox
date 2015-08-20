local PANEL = {}

function PANEL:Init()



    self.Files = {}
    self.Directories = {}
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

function PANEL:SetFileSystem( fs )
	self.FileSystem = fs
	self.Files = {}
	self.Directories = {}

	for i , v in ipairs( fs:GetDirectories() ) do
		local node = self:AddNode( v:GetName() )
		node:SetFileSystem( v )

		self.Directories[ i ] = node
	end

	for i , v in ipairs( fs:GetFiles() ) do
		local node = self:AddNode( v , "icon16/page.png")

		self.Files[ i ] = node
	end
end

function PANEL:Refresh()
    if not self.ChildNodes or not self.FileSystem then return end

	local del = self.ChildNodes
	self.ChildNodes = nil
	self:CreateChildNodes()
	del:Remove()

    self.Files = {}
    self.Directories = {}

    self.FileSystem:Refresh( true )

	for i , v in ipairs( self.FileSystem:GetDirectories() ) do
		local node = self:AddNode( v:GetName() )
		node:SetFileSystem( v )

		self.Directories[ i ] = node
	end

	for i , v in ipairs( self.FileSystem:GetFiles() ) do
		local node = self:AddNode( v , "icon16/page.png")

		self.Files[ i ] = node
	end
end

vgui.Register( "Luabox_File_Tree_Node", PANEL, "DTree_Node" )
