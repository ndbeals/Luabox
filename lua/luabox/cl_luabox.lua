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






--[[

--- luabox.FileSystem Class.
--@section luabox.FileSystem

luabox.FileSystem = Class()

--- luabox.FileSystem Class Constructor.
-- Creates the FileSystem class (CLIENT ONLY).
--@param path File path for the Filesystem to load.
--@param root the root file system
function luabox.FileSystem:Initialize( path , root )
	self:SetSingleFile( false )
	self:SetPath( path or "luabox" )
	self:SetRootFileSystem( root or self )

	self:Build()
end

--- SetSingleFile.
-- Sets if the File System represents just a single file
--@param bool is single file
function luabox.FileSystem:SetSingleFile( bool )
	self.SingleFile = bool
end

--- GetSingleFile.
-- Gets if the File System represents just a single file
--@return singlefile boolean if it's a single file
function luabox.FileSystem:GetSingleFile()
	return self.SingleFile
end

function luabox.FileSystem:GetRootFileSystem()
	return self.RootFileSystem
end

function luabox.FileSystem:SetRootFileSystem( root )
	self.RootFileSystem = root
end

function luabox.FileSystem:SetPath( path )
	self.Path = path

	self:SetShortPath( path )
end

function luabox.FileSystem:GetPath()
	return self.Path
end

function luabox.FileSystem:SetShortPath( path )
	local paths = string.Explode( "/" , path )

	self.ShortPath = paths[ #paths ]
end

function luabox.FileSystem:GetShortPath()
	return self.ShortPath
end

luabox.FileSystem.GetName = luabox.FileSystem.GetShortPath

function luabox.FileSystem:GetFiles()
	return self.Files
end

function luabox.FileSystem:GetDirectories()
	return self.Directories
end

function luabox.FileSystem:Search( path )
	local ret

	if string.TrimRight( self:GetPath() , "/") == string.TrimRight( path , "/" ) then
		return self
	end

	if string.find(string.TrimRight( self:GetPath() , "/") , string.TrimRight( path , "/" )) then
		return self
	end

	for i , v in ipairs( self.Directories ) do

		ret = v:Search( path )
		if ret then
			return ret
		end
	end

	for i , v in ipairs( self.Files ) do

		ret = v:Search( path )
		if ret then
			return ret
		end
	end
end

function luabox.FileSystem:Delete()
	for i , v in ipairs( self.Files ) do
		v:Delete()
	end

	for i , v in ipairs( self.Directories ) do
		v:Delete()
	end

	file.Delete( self:GetPath() )

	self:GetRootFileSystem():Refresh( true )
end

function luabox.FileSystem:Copy( destfs )
	if not destfs then return false end
	if (destfs:GetPath() .. "/" .. self:GetShortPath()) == self:GetPath() then return false end
	if destfs:GetSingleFile() then return false end

	local newpath = destfs:GetPath() .. "/" .. self:GetShortPath()

	local newfs = luabox.FileSystem( newpath , destfs )

	file.CreateDir( destfs:GetPath() .. "/" .. self:GetShortPath() )

	table.insert( destfs.Directories , newfs )

	for i , v in ipairs( self.Files ) do
		v:Copy( newfs )
	end

	for i , v in ipairs( self.Directories ) do
		v:Copy( newfs )
	end

	self:GetRootFileSystem():Refresh( true )

	return true
end

function luabox.FileSystem:Move( destfs )
	if not destfs then return false end
	if (destfs:GetPath() .. "/" .. self:GetShortPath()) == self:GetPath() then return false end
	if destfs:GetSingleFile() then return false end

	local oldpath = self:GetPath()

	file.CreateDir( destfs:GetPath() .. "/" .. self:GetShortPath() )
	self:SetPath( destfs:GetPath() .. "/" .. self:GetShortPath() )

	for i , v in ipairs( self.Files ) do
		v:Move( self )
	end

	for i , v in ipairs( self.Directories ) do
		v:Move( self )
	end

	file.Delete( oldpath )

	self:GetRootFileSystem():Refresh( true )

	return true
end

function luabox.FileSystem:AddFile( name )
	if not name then return false end
	if self:GetSingleFile() then return false end

	if not (string.GetExtensionFromFilename( name ) == "txt") then
		name = name .. ".txt"
	end

	local newfile = luabox.File( self:GetPath() .. "/" .. name , self )

	file.Write( newfile:GetPath() , "" )

	table.insert( self.Files , newfile )

	self:GetRootFileSystem():Refresh( true )

	return newfile
end

function luabox.FileSystem:AddDirectory( name )
	if not name then return false end
	if self:GetSingleFile() then return false end

	local directory = luabox.FileSystem( self:GetPath() .. "/" .. name , self)

	file.CreateDir( self:GetPath() .. "/" .. name )

	table.insert( self.Directories , directory )

	self:GetRootFileSystem():Refresh( true )

	return directory
end

function luabox.FileSystem:Build()
	self.Files = {}
	self.Directories = {}

	if self:GetSingleFile() then return end

	local files , directories = file.Find( self.Path .. "/*" , "DATA" , "namedesc" )

	for i , v in ipairs( files ) do
		self.Files[ i ] = luabox.File( self.Path .. "/" .. v , self )
	end

	for i , v in ipairs( directories ) do
		self.Directories[ i ] = luabox.FileSystem( self.Path .. "/" .. v , self )
	end
end

function luabox.FileSystem:Refresh( recurse , changed )
	if self:GetSingleFile() then return end

	changed = changed or false

	local files , directories = file.Find( self.Path .. "/*" , "DATA" , "namedesc" )

	local i = 1
	while i <= (#self.Directories) do

		if not TableHasValue( directories , self.Directories[i]:GetName()) then

			table.remove( self.Directories , i )

			i = i - 1
			changed = true
		end

		i = i + 1
	end

	for i , v in ipairs( directories ) do
		local new = true
		for _i , _v in ipairs( self.Directories ) do

			if v == _v:GetName() then
				--new = true
				new = false
				break
			end

		end

		if new then
			table.insert( self.Directories , i , luabox.FileSystem( self.Path .. "/" .. v , self ) )

			changed = true
		end
	end

	i = 1
	while i <= (#self.Files) do

		if not TableHasValue( files , self.Files[i]:GetName()) then

			table.remove( self.Files , i )

			i = i - 1

			changed = true
		end

		i = i + 1
	end

	for i , v in ipairs( files ) do
		local new = true
		for _i , _v in ipairs( self.Files ) do

			if v == _v:GetName() then
				--new = true
				new = false
				break
			end

		end

		if new then
			table.insert( self.Files , i , luabox.File( self.Path .. "/" .. v , self ) )

			changed = true
		end
	end

	if recurse then
		for i , v in ipairs( self.Directories ) do
			changed = v:Refresh( recurse , changed )
		end
		for i , v in ipairs( self.Files ) do
			changed = v:Refresh( recurse  , changed )
		end
	end
	return changed
end

luabox.File = Class( luabox.FileSystem )

--- luabox.File Class.
--@section luabox.File

--- luabox.File Class Constructor.
-- Creates the FileSystem class (CLIENT ONLY).
--@param path File path for the Filesystem to load.
--@param root the root file system
function luabox.File:Initialize( path , root )
	self:SetSingleFile( true )
	self:SetPath( path or "luabox" )
	self:SetRootFileSystem( root or self )

	self.Files = {}
	self.Directories = {}
end

function luabox.File:Copy( destfs )
	if not destfs then return false end
	if (destfs:GetPath() .. "/" .. self:GetShortPath()) == self:GetPath() then return false end
	if destfs:GetSingleFile() then return false end

	local newpath = destfs:GetPath() .. "/" .. self:GetShortPath()

	local newfs = File( newpath , destfs )

	file.Write( newpath , file.Read( self:GetPath() , "DATA" ) )

	newfs:SetSingleFile( true )
	table.insert( destfs.Files , newfs )

	return true
end

function luabox.File:Move( destfs )
	if not destfs then return false end
	if (destfs:GetPath() .. "/" .. self:GetShortPath()) == self:GetPath() then return false end
	if destfs:GetSingleFile() then return false end

	file.Write( destfs:GetPath() .. "/" .. self:GetShortPath() , file.Read( self:GetPath() , "DATA" ) )
	file.Delete( self:GetPath() )
	self:SetPath( destfs:GetPath() .. "/" .. self:GetShortPath() )
	return true
end

function luabox.File:Read()
	return file.Read( self:GetPath() , "DATA" )
end

function luabox.File:Write( str )
	file.Write( self:GetPath() , str )
end
--]]
