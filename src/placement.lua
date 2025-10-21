Copyright (c) 2025 Vincent Situ 
All rights reserved.

This work and its contents are the exclusive property of the copyright holder.
You may not copy, modify, distribute, or use this work, in whole or in part,
for any purpose, including commercial, educational, or personal use,
without explicit written permission from the copyright holder.

Unauthorized use of this work is strictly prohibited.


local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local remote1 = game.ReplicatedStorage.placeEvents.placing.placingActive.place
local remote2 = game.ReplicatedStorage.placeEvents.placing.placingActive.off
local mining = false
local partr
local interact = game.ReplicatedStorage.interact

local allowedPartNames = {
	["PrimaryPart"] = true,
	["raycastBaseBlock"] = true,
	["range"] = true,
	["hitbox"] = true,
	["entityHitbox"] = true,
	["}entityHitbox"] = true,
	["damageIndicator"] = true,

}

local interactable = {
	["Furnace"] = true,

	["Mana Fountain"] = true,
	["Cannon"] = true,
	["Blaster"] = true,
	["Mortar"] = true,
	["Spikeshot"] = true,
	["Frolista"] = true,
	["Bastion"] = true,
	["Potion Tower"] = true,

	["Wall"] = true,

	["Crafting Station"] = true,
	["Builder Bed"] = true,

	["Pulverizer"] = true,
	["Compressor"] = true,
	["Cleanser"] = true,
	["Steamer"] = true,
	["Crusher"] = true,
	["Washer"] = true,
	["Cryogenizer"] = true,
	["Magma Blaster"] = true,
	["Acid Sprayer"] = true,

	["Ore Drill"] = true,
	["Core Excavator"] = true,
	["Heavy Forge"] = true,
	["Casting Forge"] = true,

	["Base Core"] = true,
	
	
	["Shadow Altar"] = true,
	["Electric Altar"] = true,
	["Soul Altar"] = true,
	["Time Altar"] = true,
	["Water Altar"] = true,
	["Wind Altar"] = true,
	["Arcane Altar"] = true,
	["Earth Altar"] = true,
	["Fire Altar"] = true,
	["Nature Altar"] = true,
	["Poison Altar"] = true,
	["Light Altar"] = true,
	
	["Oak Chest"]     = true,
	["Rose Chest"]    = true,
	["Palm Chest"]    = true,
	["Cernia Chest"]  = true,
	["Seron Chest"]   = true,
	["Grim Chest"]    = true,
	["Mura Chest"]    = true,
	["Halzea Chest"]  = true,
	["Darvian Chest"] = true,
	["Frigid Chest"]  = true,
	["Radia Chest"]   = true,
	
	["Common Gift Box"] = true,
	["Uncommon Gift Box"] = true,
	["Rare Gift Box"] = true,
	["Epic Gift Box"] = true,
	["Legendary Gift Box"] = true,
	["Mythic Gift Box"] = true,
	["Godly Gift Box"] = true,
	
	
}


mouse.Button2Down:Connect(function()
	--7/11print("BBBB")
	
	local target = mouse.Target
	
	
	if target == nil then
		return
	end
	print(
		allowedPartNames[target.Name],
		string.find(target.Name, "bP"),
		target.Parent.ClassName,
		"Model",
		interactable[string.gsub(target.Parent.Name, "^%[%d+%]%s*", "")]
	)
	
	if target.Name == "bP:rotate" then
		target = target.Parent
	end
	if (allowedPartNames[target.Name] or string.find(target.Name,"bP")) and target.Parent.ClassName == "Model" and interactable[string.gsub(target.Parent.Name, "^%[%d+%]%s*", "")] then
		interact:FireServer(target.Parent)
	elseif player.Character:FindFirstChildOfClass("Tool") then
		--7/11print("BBBBJ")
		local checkSize = nil
		
		if player.Character:FindFirstChildOfClass("Tool") and player.Character:FindFirstChildOfClass("Tool"):FindFirstChild("Handle") then
			checkSize = true
		end
		if checkSize then
		--if Vector3.new(math.round(checkSize.X * 10)/10,math.round(checkSize.Y * 10)/10,math.round(checkSize.Z * 10)/10) == Vector3.new(1.5,1.5,1.5) then
			mining = true
			--7/11print("BBBBA")
			local pos
			wait(0.05)
			local position = mouse.Hit.Position
			
			
			local camPos = camera.CFrame.Position
			local x,cx,dx = position.X,camPos.X,0
			local y,cy,dy = position.Y,camPos.Y,0
			local z,cz,dz = position.Z,camPos.Z,0
			local bx,by,bz -- block chosen position
			if math.round(x) == x then
				if cx - x > 0  then
					dx = 2
				else
					dx = -2
				end
			else
				if x > math.round(x/4)*4  then
					dx = 2
				else
					dx = -2
				end
			end
			if math.round(y) == y then
				if cy - y > 0 then
					dy = 2
				else
					dy = -2
				end
			else
				if y > math.round(y/4)*4  then
					dy = 2
				else
					dy = -2
				end
			end
			if math.round(z) == z then
				if cz - z > 0 then
					dz = 2 
				else
					dz = -2
				end
			else
				if z > math.round(z/4)*4  then
					dz = 2
				else
					dz = -2
				end
			end

			pos = Vector3.new(math.round(x/4)*4+dx,math.round(y/4)*4+dy,math.round(z/4)*4+dz)
			if (pos - player.Character.PrimaryPart.Position).Magnitude < 20 then
				--7/11print("CHECK4")
				remote1:FireServer(pos,camera.CFrame)
				print(1)
			else
				pos = Vector3.new(0,1000,0)
				print(2)
			end
			--7/11print("CHECK@")
			while wait(0.25) and mining do
				if player.Character:FindFirstChildOfClass("Tool") then
					--7/11print("CHECK@")
					if player.Character:FindFirstChildOfClass("Tool").Handle.Size --[[ == Vector3.new(1.5,1.5,1.5) ]] then
						local position = mouse.Hit.Position
						
						
						--7/11print("CHECK@")
						
						local camPos = camera.CFrame.Position
						local x,cx,dx = position.X,camPos.X,0
						local y,cy,dy = position.Y,camPos.Y,0
						local z,cz,dz = position.Z,camPos.Z,0
						local bx,by,bz -- block chosen position

						if math.round(x) == x then
							if cx - x > 0  then
								dx = 2
							else
								dx = -2
							end
						else
							if x > math.round(x/4)*4  then
								dx = 2
							else
								dx = -2
							end
						end
						if math.round(y) == y then
							if cy - y > 0 then
								dy = 2
							else
								dy = -2
							end
						else
							if y > math.round(y/4)*4  then
								dy = 2
							else
								dy = -2
							end
						end
						if math.round(z) == z then
							if cz - z > 0 then
								dz = 2 
							else
								dz = -2
							end
						else
							if z > math.round(z/4)*4  then
								dz = 2
							else
								dz = -2
							end
						end

						local newPos = Vector3.new(math.round(x/4)*4+dx,math.round(y/4)*4+dy,math.round(z/4)*4+dz)
						if (newPos - player.Character.PrimaryPart.Position).Magnitude >= 20 then
							pos = Vector3.new(0,1000,0)
							--7/11print("CHECK@")
							remote2:FireServer()
						end
						if (newPos - player.Character.PrimaryPart.Position).Magnitude < 20 then
							pos = newPos
							--7/11print("CHECK@2")
							remote1:FireServer(pos,camera.CFrame)
						end
					end
				end
			end
		end
	end
end)

mouse.Button2Up:Connect(function()
	mining = false
	remote2:FireServer()
end)
