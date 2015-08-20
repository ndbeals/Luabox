function PANEL:Init()
    self.Container = luabox.PlayerContainer()

    self.Sheet = vgui.Create( "DPropertySheet" , self )

    self.test = vgui.Create("DPanel",self)
    local pa1 = self.test
    pa1:SetSize(100,100)
--pa1:SetPos(400,51)
pa1:SetBackgroundColor( Color( 255, 200, 100, 255 ))

end

function PANEL:PerformLayout()
    self:SetTall( ScrH() - 168 )

    



    self.test:SetSize(200,200)
    self.test:SetPos(10,10)


end
