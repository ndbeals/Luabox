ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:OnRemove()
	if self.Container then
		self.Container:RemoveEnvironment( self.Environment )
	end
end

function ENT:SetLuaboxPlayer( ply )
	if self.Container then
		if self.Environment then
			self.Container:RemoveEnvironment( self.Environment )

		end
	end

	self:SetContainer( luabox.PlayerContainer( ply ) )
	--self:SetEnvironment( self.Container:AddNewEnvironment() )
end

function ENT:SetContainer( container )
	self.Container = container
end

function ENT:GetContainer()
	return self.Container
end

function ENT:SetEnvironment( env )
	env.Entity = self

	self.Environment = env
end

function ENT:GetEnvironment()
	return self.Environment
end

function ENT:NewEnvironment()
	if self:GetEnvironment() then
		self:GetContainer():RemoveEnvironment( self:GetEnvironment() )
	end

	self:SetEnvironment( self:GetContainer():AddNewEnvironment() )

	return self.Environment
end

function ENT:SetLuaPack( pack )
	self.LuaPack = pack
end

function ENT:GetLuaPack()
	return self.LuaPack
end

function ENT:RunLuaPack( pack )
	self:SetLuaPack( pack )

	local environment = self:NewEnvironment()

	luabox.luapack.RunPack( self:GetContainer() , pack , environment)
end
