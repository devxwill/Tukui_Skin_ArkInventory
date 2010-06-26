--[[
    ArkInventory skin for TukUI by Mankar - Runetotem
	Special thanks to Darth Android / Telroth-Black Dragonflight for their Editless Skins
    Skins ArkInventory windows to fit TukUI

    New Options in config.lua
	TukuiDB["skins"] {
		ArkInventory {
			Right = {1, 2, 6, 7, 8, 9},
			Left = {3, 4, 5},
		},
	}

	The above tells which windows will lock to which side of the screen
	Bag = 1,
	Key = 2,
	Bank = 3,
	Vault = 4,
	Mail = 5,
	Wearing = 6,
	Pet = 7,
	Mount = 8,
	Token = 9

]]
if not TukuiDB then return end
local ArkInventory = ArkInventory
local r = TukuiDB.skins.ArkInventory.Right or { 1, 2, 6, 7, 8, 9 }
local l = TukuiDB.skins.ArkInventory.Left or { 3, 4, 5 }
local _G = _G

if ArkInventory == nil then return end

-- Update the GameToolTip to appear above then AI frames when visible
local function gtUpdate( self, ... )
	local af = TukuiInfoRight
	local scale = 4
	
	for _, value in pairs( r ) do
		local mf = ArkInventory.Frame_Main_Get( value )
		if mf:IsShown( ) then
			af = mf
			scale = 30
			break
		end
	end
	
	if self:GetAnchorType( ) == "ANCHOR_NONE" then
		if self:GetAlpha( ) == 1 then
			self:ClearAllPoints( )
			self:SetPoint( "BOTTOMRIGHT", af, "TOPRIGHT", 0, TukuiDB:Scale( scale ) )
		end
	end
end
GameTooltip:HookScript( "OnUpdate", gtUpdate )

-- Need this to determine if a table contains an item
local function tblContains( table, loc_id )
	for _, value in pairs( table ) do
		if value == loc_id then
			return true
		end
	end
	
	return false
end

-- Hook Container_Draw
-- Need to copy ALL the code here to modify the size to 30x30 to fit Tukui Bags
ArkInventory.Frame_Container_Draw_ = ArkInventory.Frame_Container_Draw
ArkInventory.Frame_Container_Draw = function( frame )
	local loc_id = frame.ARK_Data.loc_id
	local cp = ArkInventory.LocationPlayerInfoGet( loc_id )
	
	--ArkInventory.Output( "draw frame=", frame:GetName( ), ", loc=", loc_id, ", state=", ArkInventory.Global.Location[loc_id].drawState )
	
	if ArkInventory.Global.Location[loc_id].drawState <= ArkInventory.Const.Window.Draw.Recalculate then

		-- calculate what the container should look like
		ArkInventory.Frame_Container_Calculate( frame )

		local name

		-- create (if required) the bar frames, and hide any that are no longer required
		local placeframename = frame:GetName( ) .. "Bar"
		local placeframe = _G[placeframename]
		assert( placeframe, "xml element '" .. placeframename .. "' could not be found" )
		
		local baselevel = placeframe:GetFrameLevel( )
		
		for j = 1, ArkInventory.Global.Location[loc_id].maxBar do
			local barframename = placeframename .. j
			local barframe = _G[barframename]
			if not barframe then
				--ArkInventory.Output( "creating bar [", barframename, "]" )
				barframe = CreateFrame( "Frame", barframename, placeframe, "ARKINV_TemplateFrameBar" )
			end
			
			ArkInventory.Frame_Bar_Paint( barframe )
			barframe:Hide( )
		end
		
		-- create (if required) the bags and their item buttons, and hide any that are not currently needed
		local placeframename = frame:GetName( ) .. "Bag"
		local placeframe = _G[placeframename]
		assert( placeframe, "xml element '" .. placeframename .. "' could not be found" )
		
		--~~~~ need to fix this for when the cache is reset
		for bag_id in pairs( ArkInventory.Global.Location[loc_id].Bags ) do
		
			local bagframename = placeframename .. bag_id
			local bagframe = _G[bagframename]
			if not bagframe then
				--ArkInventory.Output( "creating bag frame [", bagframename, "]" )
				bagframe = CreateFrame( "Frame", bagframename, placeframe, "ARKINV_TemplateFrameBag" )
			end

			-- remember the maximum number of slots used for each bag
			local b = cp.location[loc_id].bag[bag_id]
			
			if not ArkInventory.Global.Location[loc_id].maxSlot[bag_id] then
				ArkInventory.Global.Location[loc_id].maxSlot[bag_id] = 0
			end
			
			if b.count > ArkInventory.Global.Location[loc_id].maxSlot[bag_id] then
				ArkInventory.Global.Location[loc_id].maxSlot[bag_id] = b.count
			end
			
			-- create the item frames for the bag
			for j = 1, ArkInventory.Global.Location[loc_id].maxSlot[bag_id] do
				
				local itemframename = ArkInventory.ContainerItemNameGet( loc_id, bag_id, j )
				local itemframe = _G[itemframename]
				if not itemframe then
					--ArkInventory.Output( "creating item frame [", itemframename, "]" )
					if loc_id == ArkInventory.Const.Location.Vault then
						itemframe = CreateFrame( "Button", itemframename, bagframe, "ARKINV_TemplateButtonVaultItem" )
					elseif loc_id == ArkInventory.Const.Location.Pet or loc_id == ArkInventory.Const.Location.Mount then
						itemframe = CreateFrame( "Button", itemframename, bagframe, "ARKINV_TemplateButtonPetItem" )
					elseif loc_id == ArkInventory.Const.Location.Wearing or loc_id == ArkInventory.Const.Location.Mail or loc_id == ArkInventory.Const.Location.Token then
						itemframe = CreateFrame( "Button", itemframename, bagframe, "ARKINV_TemplateButtonViewOnlyItem" )
					else
						itemframe = CreateFrame( "Button", itemframename, bagframe, "ARKINV_TemplateButtonItem" )
					end
				end
				-- Modify the itemframe height to match Tukui Bags
				itemframe:SetHeight(30)
				itemframe:SetWidth(30)
				
				if j == 1 then
					ArkInventory.Global.BAG_SLOT_SIZE = itemframe:GetWidth( )
				end
				
				ArkInventory.Frame_Item_Update_Clickable( itemframe )
				itemframe:Hide( )
			end
		end
	end

	-- build the bar frames
	
	local name = frame:GetName( )
		
	local pad_slot = ArkInventory.LocationOptionGet( loc_id, { "slot", "pad" } )
	local pad_bar_int = ArkInventory.LocationOptionGet( loc_id, { "bar", "pad", "internal" } )
	local pad_bar_ext = ArkInventory.LocationOptionGet( loc_id, { "bar", "pad", "external" } )
	local pad_window = ArkInventory.LocationOptionGet( loc_id, { "window", "pad" } )
	local pad_label = ( ArkInventory.LocationOptionGet( loc_id, { "bar", "name", "show" } ) and ArkInventory.LocationOptionGet( loc_id, { "bar", "name", "height" } ) ) or 0
	local anchor = ArkInventory.LocationOptionGet( loc_id, { "bar", "anchor" } )

	--ArkInventory.Output( "Layout=[", ArkInventory.Global.Location[loc_id].Layout, "]" )
	
	for rownum, row in ipairs( ArkInventory.Global.Location[loc_id].Layout.container.row ) do

		row["width"] = pad_window * 2 + pad_bar_ext
		
		for bar_index, bar_id in ipairs( row.bar ) do

			local bar = ArkInventory.Global.Location[loc_id].Layout.bar[bar_id]
			
			local barframename = name .. "Bar" .. bar.frame
			local obj = _G[barframename]
			assert( obj, "xml element '" .. barframename .. "' could not be found" )

			-- assign the bar number used to the bar frame
			obj.ARK_Data.bar_id = bar_id
			
			if ArkInventory.Global.Location[loc_id].drawState <= ArkInventory.Const.Window.Draw.Recalculate then

				local obj_width = bar.width * ArkInventory.Global.BAG_SLOT_SIZE + ( bar.width - 1 ) * pad_slot + pad_bar_int * 2
				obj:SetWidth( obj_width )
				row.width = row.width + obj_width
				
				row.width = row.width + pad_bar_ext

				row["height"] = bar.height * ArkInventory.Global.BAG_SLOT_SIZE + ( bar.height - 1 ) * pad_slot + pad_bar_int * 2 + pad_label
				obj:SetHeight( row.height )
				
				obj:ClearAllPoints( )
				
				--ArkInventory.Output( "row=" .. rownum .. ", bar=" .. bar_index .. ", obj=" .. obj:GetName( ) .. ", frame=" .. bar.frame )
				-- anchor first bar to frame
				if bar.frame == 1 then
					
					if anchor == ArkInventory.Const.Anchor.BottomLeft then
						obj:SetPoint( "BOTTOMLEFT", frame, "BOTTOMLEFT", pad_window + pad_bar_ext, pad_window + pad_bar_ext )
					elseif anchor == ArkInventory.Const.Anchor.TopLeft then
						obj:SetPoint( "TOPLEFT", frame, "TOPLEFT", pad_window + pad_bar_ext, 0 - pad_window - pad_bar_ext )
					elseif anchor == ArkInventory.Const.Anchor.TopRight then
						obj:SetPoint( "TOPRIGHT", frame, "TOPRIGHT", 0 - pad_window - pad_bar_ext, 0 - pad_window - pad_bar_ext )
					else -- if anchor == ArkInventory.Const.Anchor.BottomRight then
						obj:SetPoint( "BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0 - pad_window - pad_bar_ext, pad_window + pad_bar_ext )
					end
					
				else
				
					if bar_index == 1 then
						-- next row, place under previous row
						--ArkInventory.Output( "anchor=" .. name .. "Bar" .. ArkInventory.Global.Location[loc_id].Layout.container.row[rownum-1].bar[1].frame )
						
						local prev = ArkInventory.Global.Location[loc_id].Layout.container.row[rownum-1].bar[1]
						local parent = name .. "Bar" .. ArkInventory.Global.Location[loc_id].Layout.bar[prev].frame
						
						if anchor == ArkInventory.Const.Anchor.BottomLeft then
							obj:SetPoint( "BOTTOMLEFT", parent, "TOPLEFT", 0, pad_bar_ext )
						elseif anchor == ArkInventory.Const.Anchor.TopLeft then
							obj:SetPoint( "TOPLEFT", parent, "BOTTOMLEFT", 0, 0 - pad_bar_ext )
						elseif anchor == ArkInventory.Const.Anchor.TopRight then
							obj:SetPoint( "TOPRIGHT", parent, "BOTTOMRIGHT", 0, 0 - pad_bar_ext )
						else -- if anchor == ArkInventory.Const.Anchor.BottomRight then
							obj:SetPoint( "BOTTOMRIGHT", parent, "TOPRIGHT", 0, pad_bar_ext )
						end

					else
					
						-- next slot, place bar next to last one
						
						local parent = name .. "Bar" .. ( bar.frame - 1 )
						
						if anchor == ArkInventory.Const.Anchor.BottomLeft then
							obj:SetPoint( "BOTTOMLEFT", parent, "BOTTOMRIGHT", pad_bar_ext, 0 )
						elseif anchor == ArkInventory.Const.Anchor.TopLeft then
							obj:SetPoint( "TOPLEFT", parent, "TOPRIGHT", pad_bar_ext, 0 )
						elseif anchor == ArkInventory.Const.Anchor.TopRight then
							obj:SetPoint( "TOPRIGHT", parent, "TOPLEFT", 0 - pad_bar_ext, 0 )
						else -- if anchor == ArkInventory.Const.Anchor.BottomRight then
							obj:SetPoint( "BOTTOMRIGHT", parent, "BOTTOMLEFT", 0 - pad_bar_ext, 0 )
						end
					end
				end
				
				obj:Show( )
			end
			
			if ArkInventory.Global.Location[loc_id].drawState <= ArkInventory.Const.Window.Draw.Refresh then
				ArkInventory.Frame_Bar_Label( obj )
				ArkInventory.Frame_Bar_DrawItems( obj )
			end
		end
	end

	if ArkInventory.Global.Location[loc_id].drawState <= ArkInventory.Const.Window.Draw.Recalculate then

		-- set container height and width
		
		local c = ArkInventory.Global.Location[loc_id].Layout.container
		
		c.width = ArkInventory.Const.Window.Min.Width
		
		c.height = pad_window * 2 + pad_bar_ext

		for row_index, row in ipairs( c.row ) do
		
			if row.width > c.width then
				c.width = row.width
			end
			
			c.height = c.height + row.height + pad_bar_ext
		
		end
		
		if c.height < ArkInventory.Const.Window.Min.Height then
			c.height = ArkInventory.Const.Window.Min.Height
		end
		
		frame:SetWidth( c.width )
		frame:SetHeight( c.height )
	end
end

-- Hook Main_Draw
ArkInventory.Frame_Main_Draw_ = ArkInventory.Frame_Main_Draw
ArkInventory.Frame_Main_Draw = function( frame )
	ArkInventory.Frame_Main_Draw_( frame )
	local af = frame:GetName( )
	
	for _, v in pairs{ "Title", "Search", "Container", "Changer", "Status" } do
		TukuiDB:SetTemplate( _G[af..v] )
	end
end

-- Hook Anchor_Set
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
		
	if tblContains(l, loc_id) then
		frame:SetPoint( "BOTTOMLEFT", TukuiInfoLeft, "TOPLEFT", 0, TukuiDB:Scale( 5 ) )
			
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
		frame:SetPoint( "BOTTOMRIGHT", TukuiInfoRight, "TOPRIGHT", 0, TukuiDB:Scale( 5 ) )
			
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

do
	-- Set the Template on windows that are not drawn as often as the main frames are
	-- Rules Frame
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
	
	-- Search Frame
	TukuiDB:SetTemplate( _G["ARKINV_SearchTitle"] )
	TukuiDB:SetTemplate( _G["ARKINV_SearchFrameViewSearch"] )
	TukuiDB:SetTemplate( _G["ARKINV_SearchFrameViewTable"] )
	TukuiDB:SetTemplate( _G["ARKINV_SearchFrame"] )
	
	-- Guild Log Frame
	TukuiDB:SetTemplate( _G["ARKINV_Frame4Log"] )
	
	-- Adjust Default Settings to fit Tukui Bags
	for i = 1, 9 do
		ArkInventory.LocationOptionSet( i, { "changer", "hide" }, true )
		ArkInventory.LocationOptionSet( i, { "title", "size" }, ArkInventory.Const.Window.Title.SizeThin )
		ArkInventory.LocationOptionSet( i, { "bar", "per" }, 2 )
		ArkInventory.LocationOptionSet( i, { "slot", "border", "scale" }, scale )
		ArkInventory.LocationOptionSet( i, { "bar", "pad", "internal" }, 4 )
		ArkInventory.LocationOptionSet( i, { "bar", "pad", "external" }, 2 )
		ArkInventory.Const.Window.Min.Width = TukuiDB["panels"].tinfowidth
	
		if TukuiDB["panels"].tinfowidth >= 405 then
			ArkInventory.LocationOptionSet( i, { "window", "width" }, 11 )
		elseif TukuiDB["panels"].tinfowidth >= 370 and TukuiDB["panels"].tinfowidth < 405 then
			ArkInventory.LocationOptionSet( i, { "window", "width" }, 10 )
		elseif TukuiDB["panels"].tinfowidth >= 335 and TukuiDB["panels"].tinfowidth < 370 then
			ArkInventory.LocationOptionSet( i, { "window", "width" }, 9 )
		else
			ArkInventory.LocationOptionSet( i, { "window", "width" }, 8 )
		end
	end
end
