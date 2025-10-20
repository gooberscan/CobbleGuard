Copyright (c) 2025 Vincent Situ 
All rights reserved.

This work and its contents are the exclusive property of the copyright holder.
You may not copy, modify, distribute, or use this work, in whole or in part,
for any purpose, including commercial, educational, or personal use,
without explicit written permission from the copyright holder.

Unauthorized use of this work is strictly prohibited.


local TS = game:GetService("TweenService")
local event1 = game.ReplicatedStorage.tweenClient
local event2 = game.ReplicatedStorage.delete
local event3 = game.ReplicatedStorage.tweenObjectSequence
local tweenArray = game.ReplicatedStorage.tweenArray


local remote1 = game.ReplicatedStorage.magicEvents.soul.magicActive.demonicHarvest
local remote2 = game.ReplicatedStorage.magicEvents.soul.cooldown.demonicHarvest


local baseAnimationTween = game.ReplicatedStorage.regularTween

event1.OnClientEvent:Connect(function(all)
	--part,info,goals
	----7/11print(all)
	
	for i = 2, #all do
		local copy
		if all[1][5] or #all[1] == 3  then
			copy = all[i][1]
			
			if all[1][5] and i ~= 3 then
				copy.Parent = all[1][5]
			end
			------7/11print("FOUND")
		else
			copy = game.ReplicatedStorage.magicParts[all[1][1]]:Clone()
			copy.CFrame = all[i][4]
			copy.Parent = workspace.effectBlocks
		end
		
		if all[1][6] then
			copy.Transparency = all[1][6]
		end
		------7/11print(all)
		------7/11print(copy)
		----7/11print(all)
		------7/11print(all[i][1].Name,all[i][2])
		
		TS:Create(copy,TweenInfo.new(table.unpack(all[i][2])),all[i][3]):Play()


		delay(all[i][2][1] + all[i][2][6],function()
			if all[1][4] then
				wait(all[1][4] )
			end
			------7/11print("DESTROYED")
			pcall(function()
				if all[i][5] then
					TS:Create(copy,TweenInfo.new(table.unpack(all[i][5])),all[i][6]):Play()
					if copy:FindFirstChildOfClass("ParticleEmitter") then
						for i,v in pairs(copy:GetChildren()) do
							if v.ClassName == "ParticleEmitter" then
								v.Enabled = false
							end
						end
					end
					
					delay(all[i][7],function()
						
					end)
				end
				
			end)

				
			copy:Destroy()
			
		end)
	end
end)

event3.OnClientEvent:Connect(function(object,info)
	----7/11print("TWEENING")
	
	----7/11print("TWEENING")
	for i,v in info do
		local tween = TS:Create(object,TweenInfo.new(table.unpack(v[1])),v[2])
		tween:Play()
		
		tween.Completed:Wait()

	end
	
	

end)

remote1.OnClientEvent:Connect(function(player)
	local character = player.Character
	local clone = game.ReplicatedStorage.magicParts.demonicHarvest:Clone()
	clone.Parent = game.Workspace.visualEffects
	clone.Position = character.PrimaryPart.Position
	local part = Instance.new("Part",game.Workspace.visualEffects)
	part.Transparency = 1
	
	part.Position = character.PrimaryPart.Position
	part.Orientation = Vector3.new(0,0,0)
	local attachment Instance.new("Attachment",part)

	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false

	local attachment = Instance.new("Attachment",character.PrimaryPart)
	attachment.Name = "demonicHarvestPart" .. player.Name

	local alignPos = Instance.new("AlignPosition",part)
	alignPos.MaxForce = math.huge
	alignPos.Responsiveness = 200
	alignPos.RigidityEnabled = true
	alignPos.Attachment0 = part.Attachment
	alignPos.Attachment1 = character.PrimaryPart["demonicHarvestPart" .. player.Name]

	local motor6D = Instance.new("Motor6D",character.PrimaryPart)
		
	
	motor6D.Part0 = clone
	motor6D.Part1 = part
	motor6D.C0 = CFrame.new(Vector3.new(-2,0,0))
	
	
	local online = true
	clone.AssemblyAngularVelocity = Vector3.new(0,4,0)

	delay(0,function()

		while online do
			clone.AssemblyAngularVelocity = Vector3.new(0,4,0)
			clone.AngularVelocity.AngularVelocity = clone.AngularVelocity.AngularVelocity * 0.9
			wait(0.5)
			
		end
		
	end)
	
	local connection1 = nil
	connection1 = remote2.OnClientEvent:Connect(function(player2)
		
		if player == player2 then
			connection1:Disconnect()
			online = false
			clone.ParticleEmitter.Enabled = false
			TS:Create(clone,TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.Out,0,false,0),{Transparency = 1}):Play()
			wait(7)
			part:Destroy()
			clone:Destroy()
		end
	end)
	
	
	
end)



event2.OnClientEvent:Connect(function(parts)
	for i,v in pairs(parts) do
		pcall(function()
			v:Destroy()
			----7/11print(v)
		end)
		if typeof(v) ~= "Instance" then
			v = nil
		end
	end
end)


baseAnimationTween.OnClientEvent:Connect(function(object, infoArray, goals)
	--** make option
	wait(1)
	TS:Create(object,TweenInfo.new(table.unpack(infoArray)),goals):Play()
end)

tweenArray.OnClientEvent:Connect(function(array)
	for i,v in pairs(array) do
		TS:Create(v[1],TweenInfo.new(table.unpack(v[2])),v[3]):Play()
	end
	
end)