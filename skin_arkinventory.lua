--[[
    ArkInventory skin for TukUI by Mankar - Runetotem
	Special thanks to Darth Android / Telroth-Black Dragonflight for their Editless Skins
    Skins ArkInventory windows to fit TukUI

    TODO:
     + Add Integration options

]]
if (TukuiDB == nil or ArkInventory == nil) then return; end
TukuiDB.skins = TukuiDB.skins or {}
TukuiDB.skins.ArkInventory = TukuiDB.skins.ArkInventory or {}
local ArkInventory = ArkInventory
local _G = _G

do
	
	-- hook the main draw function
	ArkInventory.Frame_Main_Draw_ = ArkInventory.Frame_Main_Draw
	ArkInventory.Frame_Main_Draw = function( frame )
		ArkInventory.Frame_Main_Draw_( frame )
		local af = frame:GetName( )
		for _, v in pairs{ "Title", "Search", "Container", "Changer", "Status" } do
			TukuiDB:SetTemplate( _G[af..v] )
		end
	end
	
	TukuiDB:SetTemplate( _G["ARKINV_RulesTitle"] )
	TukuiDB:SetTemplate( _G["ARKINV_RulesFrame"] )
	TukuiDB:SetTemplate( _G["ARKINV_RulesFrameViewTitle"] )
	TukuiDB:SetTemplate( _G["ARKINV_RulesFrameViewSearch"] )
	TukuiDB:SetTemplate( _G["ARKINV_RulesFrameViewSort"] )
	TukuiDB:SetTemplate( _G["ARKINV_RulesFrameViewTable"] )
	TukuiDB:SetTemplate( _G["ARKINV_RulesFrameViewMenu"] )
	TukuiDB:SetTemplate( _G["ARKINV_RulesFrame"] )
	TukuiDB:SetTemplate( _G["ARKINV_RulesFrameModifyTitle"] )
	TukuiDB:SetTemplate( _G["ARKINV_RulesFrameModifyMenu"] )
	TukuiDB:SetTemplate( _G["ARKINV_RulesFrameModifyData"] )
	TukuiDB:SetTemplate( _G["ARKINV_RulesFrameModifyDataScrollTextBorder"] )
	
	TukuiDB:SetTemplate( _G["ARKINV_SearchTitle"] )
	TukuiDB:SetTemplate( _G["ARKINV_SearchFrameViewSearch"] )
	TukuiDB:SetTemplate( _G["ARKINV_SearchFrameViewTable"] )
	TukuiDB:SetTemplate( _G["ARKINV_SearchFrame"] )
	
	TukuiDB:SetTemplate( _G["ARKINV_Frame4Log"] )
	
	-- hook the anchors
	ArkInventory.Frame_Main_Anchor_Set_ = ArkInventory.Frame_Main_Anchor_Set
	ArkInventory.Frame_Main_Anchor_Set = function( loc_id, rescale )
		local frame = ArkInventory.Frame_Main_Get( loc_id )
		
		local f1 = _G[frame:GetName( ) .. ArkInventory.Const.Frame.Title.Name]
		local f2 = _G[frame:GetName( ) .. ArkInventory.Const.Frame.Search.Name]
		local f3 = _G[frame:GetName( ) .. ArkInventory.Const.Frame.Container.Name]
		local f4 = _G[frame:GetName( ) .. ArkInventory.Const.Frame.Changer.Name]
		local f5 = _G[frame:GetName( ) .. ArkInventory.Const.Frame.Status.Name]
		
		frame:ClearAllPoints( )
		f1:ClearAllPoints( )
		f2:ClearAllPoints( )
		f3:ClearAllPoints( )
		f4:ClearAllPoints( )
		f5:ClearAllPoints( )
		
		if loc_id == 3 or loc_id == 4 or loc_id == 5 then
			frame:SetPoint( "BOTTOMLEFT", InfoLeft, "TOPLEFT", 0, TukuiDB:Scale( 5 ) )
			
			f5:SetPoint( "BOTTOMLEFT", frame )
			f5:SetPoint( "RIGHT", frame )
		
			f4:SetPoint( "BOTTOMLEFT", f5, "TOPLEFT", 0, -3 )
			f4:SetPoint( "RIGHT", frame )
		
			f3:SetPoint( "BOTTOMLEFT", f4, "TOPLEFT", 0, -3 )
			f3:SetPoint( "RIGHT", frame )
		
			f2:SetPoint( "BOTTOMLEFT", f3, "TOPLEFT", 0, -4 )
			f2:SetPoint( "RIGHT", frame )

			f1:SetPoint( "BOTTOMLEFT", f2, "TOPLEFT", 0, -3 )
			f1:SetPoint( "RIGHT", frame )
		else
			frame:SetPoint( "BOTTOMRIGHT", InfoRight, "TOPRIGHT", 0, TukuiDB:Scale( 5 ) )
			
			f5:SetPoint( "BOTTOMRIGHT", frame )
			f5:SetPoint( "LEFT", frame )
		
			f4:SetPoint( "BOTTOMRIGHT", f5, "TOPRIGHT", 0, -3 )
			f4:SetPoint( "LEFT", frame )
		
			f3:SetPoint( "BOTTOMRIGHT", f4, "TOPRIGHT", 0, -3 )
			f3:SetPoint( "LEFT", frame )
		
			f2:SetPoint( "BOTTOMRIGHT", f3, "TOPRIGHT", 0, -4 )
			f2:SetPoint( "LEFT", frame )

			f1:SetPoint( "BOTTOMRIGHT", f2, "TOPRIGHT", 0, -3 )
			f1:SetPoint( "LEFT", frame )
		end
		
		if ArkInventory.LocationOptionGet( loc_id, { "anchor", loc_id, "locked" } ) then
			frame:RegisterForDrag( )
		else
			frame:RegisterForDrag( "LeftButton" )
		end

		if rescale then
			ArkInventory.Frame_Main_Anchor_Save( frame )
		end
	end
	
	-- Set some settings to make it look better
	for i = 1, 9 do
		ArkInventory.LocationOptionSet( i, { "changer", "hide" }, true )
		ArkInventory.LocationOptionSet( i, { "title", "size" }, ArkInventory.Const.Window.Title.SizeThin )
	
		if TukuiDB["panels"].tinfowidth >= 405 then
			ArkInventory.LocationOptionSet( i, { "window", "width" }, 12 )
		elseif TukuiDB["panels"].tinfowidth >= 370 and TukuiDB["panels"].tinfowidth < 405 then
			ArkInventory.LocationOptionSet( i, { "window", "width" }, 11 )
		elseif TukuiDB["panels"].tinfowidth >= 335 and TukuiDB["panels"].tinfowidth < 370 then
			ArkInventory.LocationOptionSet( i, { "window", "width" }, 10 )
		else
			ArkInventory.LocationOptionSet( i, { "window", "width" }, 9 )
		end
	end
end