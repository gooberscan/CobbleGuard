Copyright (c) 2025 Vincent Situ 
All rights reserved.

This work and its contents are the exclusive property of the copyright holder.
You may not copy, modify, distribute, or use this work, in whole or in part,
for any purpose, including commercial, educational, or personal use,
without explicit written permission from the copyright holder.

Unauthorized use of this work is strictly prohibited.


local small = game.ReplicatedStorage.dependencies.sHover
local big = workspace.bHover
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera
local character = player.CharacterAdded:Wait()
local on = false
mouse.TargetFilter = workspace.droppedItems

local buildOri = script.Parent.buildingPreview.orientation
local buildSize = script.Parent.buildingPreview.size


local currentOri = Vector3.new(0,0,0)
local currentSize = Vector3.new(0,0,0)

buildSize.Changed:Connect(function(val)
	currentSize = val
end)

buildOri.Changed:Connect(function(val)
	currentOri = val
end)

local partr
local highlighter

local allowedPartNames = {
	["Arms"] = true,
	["Belly"] = true,
	["Eoncharge"] = true,
	["Head"] = true,
	["HumanoidRootPart"] = true,
	["LeftArm"] = true,
	["LeftArmFour"] = true,
	["LeftArmOne"] = true,
	["LeftArmThree"] = true,
	["LeftArmTwo"] = true,
	["LeftEar"] = true,
	["LeftFoot"] = true,
	["LeftHand"] = true,
	["LeftLeg"] = true,
	["LeftLowerArm"] = true,
	["LeftLowerLeg"] = true,
	["LeftPincher"] = true,
	["LeftUpperArm"] = true,
	["LeftUpperLeg"] = true,
	["Legs"] = true,
	["LowerTorso"] = true,
	["Nose"] = true,
	["Part"] = true,
	["PrimaryPart"] = true,
	["RightArm"] = true,
	["RightArmFour"] = true,
	["RightArmOne"] = true,
	["RightArmThree"] = true,
	["RightArmTwo"] = true,
	["RightEar"] = true,
	["RightFoot"] = true,
	["RightHand"] = true,
	["RightLeg"] = true,
	["RightLowerArm"] = true,
	["RightLowerLeg"] = true,
	["RightPincher"] = true,
	["RightUpperArm"] = true,
	["RightUpperLeg"] = true,
	["Snout"] = true,
	["Tail"] = true,
	["Torso"] = true,
	["Union"] = true,
	["UpperTorso"] = true,
	["a"] = true,
	["accelerationCircle"] = true,
	["aegisCrack"] = true,
	["aegisDead"] = true,
	["aegisFull"] = true,
	["airburst"] = true,
	["aquaBomb"] = true,
	["aquaBombChecker"] = true,
	["aquaBombDamage"] = true,
	["b"] = true,
	["banefulBreath"] = true,
	["basicAttackRange"] = true,
	["big"] = true,
	["bindingRing"] = true,
	["bubbleZone"] = true,
	["bubbleZonePop"] = true,
	["center"] = true,
	["chronostrike"] = true,
	["spikeEruption"] = true,
	["corruptedHandBeam"] = true,
	["corruptedHandClose"] = true,
	["corruptedHandOpen"] = true,
	["crashingWave"] = true,
	["crumbleRing"] = true,
	["crumbleRock"] = true,
	["damageIndicator"] = true,
	["darkPulse"] = true,
	["deathParticles"] = true,
	["demonicHarvest"] = true,
	["divineGrace"] = true,
	["electroBall"] = true,
	["enlightenment"] = true,
	["enlightenmentIn"] = true,
	["entityHitbox"] = true,
	["eyeball"] = true,
	["earthquakeBox"] = true,
	["earthquakeRock"] = true,
	["flameLance"] = true,
	["flameLancePierce"] = true,
	["frostPoolWall"] = true,
	["frostPoolWallVisual"] = true,
	["frostWall"] = true,
	["gloomyLagoonRange"] = true,
	["gravitySurge"] = true,
	["gravitySurgeOut"] = true,
	["gravitySurgeRing"] = true,
	["hallowedArc"] = true,
	["haltingVineGrapple"] = true,
	["haltingVineGrappleHitbox"] = true,
	["haltingVinePulled"] = true,
	["haltingVineStart"] = true,
	["hider"] = true,
	["hitbox"] = true,
	["immolate"] = true,
	["infernoMissile"] = true,
	["iris"] = true,
	["ivoryTossBomb"] = true,
	["ivoryTossCircleAttach"] = true,
	["ivoryTossPellet"] = true,
	["kindlingBlazeInner"] = true,
	["kindlingBlazeRing"] = true,
	["knockup"] = true,
	["lead"] = true,
	["leechingRootsCheck"] = true,
	["leechingRootsRange"] = true,
	["leechingRootsSeed"] = true,
	["lightningBall"] = true,
	["lightningExplosion"] = true,
	["lightningField"] = true,
	["med"] = true,
	["mortarShot"] = true,
	["movingPartTwo"] = true,
	["nostril"] = true,
	["phaseTransition"] = true,
	["plateShift"] = true,
	["ragingTwister"] = true,
	["ragingTwisterAnchor"] = true,
	["ragingTwisterHitbox"] = true,
	["ragingTwisterWind1"] = true,
	["ragingTwisterWind10"] = true,
	["ragingTwisterWind2"] = true,
	["ragingTwisterWind3"] = true,
	["ragingTwisterWind4"] = true,
	["ragingTwisterWind5"] = true,
	["ragingTwisterWind6"] = true,
	["ragingTwisterWind7"] = true,
	["ragingTwisterWind8"] = true,
	["ragingTwisterWind9"] = true,
	["range"] = true,
	["raycastBaseBlock"] = true,
	["realityOrb"] = true,
	["realityWarp"] = true,
	["realityWarpOrbs"] = true,
	["realityWarpOrbsTop"] = true,
	["realityWarpRotator"] = true,
	["realityWarpRotatorBottom"] = true,
	["rectangle range"] = true,
	["rejuvenationPillar"] = true,
	["rejuvenationRange"] = true,
	["repulsionAura"] = true,
	["rotator"] = true,
	["rumble"] = true,
	["safeguard"] = true,
	["scorch"] = true,
	["shadowBlast"] = true,
	["shadowMain"] = true,
	["shockAbsorbanceBall"] = true,
	["small"] = true,
	["soulFour"] = true,
	["soulInner"] = true,
	["soulOne"] = true,
	["soulOrbSpin"] = true,
	["soulOuter"] = true,
	["soulThree"] = true,
	["soulTwo"] = true,
	["soulstealEnd"] = true,
	["soulstealRange"] = true,
	["spike1"] = true,
	["spike2"] = true,
	["spike3"] = true,
	["spike4"] = true,
	["spiritSplitCenter"] = true,
	["spiritSplitRange"] = true,
	["squareCheckRotYSizeXZ"] = true,
	["stasis"] = true,
	["strangleRoot"] = true,
	["stranglethornSeed"] = true,
	["takeoverInnerShell"] = true,
	["takeoverLeft"] = true,
	["takeoverRange"] = true,
	["takeoverRight"] = true,
	["takeoverShell"] = true,
	["takeoverTarget"] = true,
	["thunderbolt"] = true,
	["timelineAlterationParticle"] = true,
	["toxicGrasp"] = true,
	["toxicGraspRange"] = true,
	["triangle"] = true,
	["velocityField"] = true,
	["viciousSludge"] = true,
	["waterGeyser"] = true,
	["waterPoolBomb"] = true,
	["waterPoolBubble"] = true,
	["waterPoolBubbleVisual"] = true,
	["waterPoolGeyser"] = true,
	["waterPoolGeyserVisual"] = true,
	["waterPoolWave"] = true,
	["waterPoolWaveVisual"] = true,
	["windcutter"] = true,
	["windcutterLeft"] = true,
	["windcutterRight"] = true,
	["}entityHitbox"] = true
}

--for i,v in pairs(game.ServerStorage.StoredMobs:GetDescendants()) do
--	if v:IsA("BasePart") and not string.find(v.Name, "bP") and not allowedPartNames[v.Name] and v.CanQuery then
--		allowedPartNames[v.Name] = true
--	end
--end

--print(allowedPartNames)
--for i,v in pairs(game.ServerStorage.StoredMobs:GetDescendants()) do if v:IsA("BasePart") and  not v:FindFirstAncestor("HumanoidRootPart") and   not allowedPartNames[v.Name] then v.Name = "bP" end end
local heartbeat = game:GetService("RunService").Heartbeat

while heartbeat:Wait() do
	----7/11print("ABCD")
	local target = mouse.Target
	local position = mouse.Hit.Position
	local camPos = camera.CFrame.Position
	
	if target ~= nil then
		if (mouse.Hit.Position-character.PrimaryPart.Position).Magnitude < 20 then
			--local targSize = Vector3.new(math.round(target.Size.X * 10)/ 10,math.round(target.Size.Y * 10)/ 10,math.round(target.Size.Z * 10)/ 10)
			--if string.find(target.Name,"bP") or string.find(target.Name,"PrimaryPart") or string.find(target.Name,"hitbox") or (target.ClassName == "UnionOperation" and target.Size == Vector3.new(4,4,4)) then -- highligher if bP goes to parent or mesh blocks like stairs, maybe slab support later
			----7/11print(target)
			if string.find(target.Name,"bP") or allowedPartNames[target.Name] or (target.ClassName == "UnionOperation" and target.Size == Vector3.new(4,4,4)) then -- highligher if bP goes to parent or mesh blocks like stairs, maybe slab support later
				----7/11print("a")
				local model

				if (target.Size == Vector3.new(4,4,4) and target.ClassName == "UnionOperation") then
					model = target
				else
					model = target.Parent
				end
				if not model:FindFirstChildOfClass("Highlight") then
					if highlighter then
						highlighter:Destroy()
					end
					
					on = true
					for i,v in pairs(big:GetChildren()) do
						if v.Name ~= "a" then
							v.Transparency = 1
						end
					end
					for i,v in pairs(small:GetChildren()) do
						if v.Name ~= "a" then
							v.Transparency = 1
						end
					end
					
					
					highlighter = Instance.new("Highlight")
					highlighter.FillTransparency = 1
					highlighter.FillColor = Color3.new()
					highlighter.OutlineColor = Color3.new()
					highlighter.DepthMode = Enum.HighlightDepthMode.Occluded
					highlighter.Parent = model
					
				end
				
			
			
			elseif target.Name == "holder" then
				----7/11print("b")
				if highlighter then
					highlighter:Destroy()
					on = false
				end
				
				----7/11print(target)
				for i,v in pairs(big:GetChildren()) do
					if v.Name ~= "a" then
						v.Transparency = 1
					end
				end
				if not on then
					for i,v in pairs(small:GetChildren()) do
						if v.Name ~= "a" then
							v.Transparency = 0
						end
					end
					on = true
				end
				local pos
				local x,cx,dx = position.X,camPos.X,0
				local y,cy,dy = position.Y,camPos.Y,0
				local z,cz,dz = position.Z,camPos.Z,0
				local bx,by,bz -- block chosen position
				if math.abs(math.round(x) - x) < 0.001 then
					if cx - x > 0  then
						dx = -2
					else
						dx = 2
					end
				else
					if x > math.round(x/4)*4  then
						dx = 2
					else
						dx = -2
					end
				end
				if math.abs(math.round(y) - y) < 0.001  then
					if cy - y > 0 then
						dy = -2
					else
						dy = 2
					end
				else
					if y > math.round(y/4)*4  then
						dy = 2
					else
						dy = -2
					end
				end
				if math.abs(math.round(z) - z) < 0.001  then
					if cz - z > 0 then
						dz = -2 
					else
						dz = 2
					end
				else
					if z > math.round(z/4)*4  then
						dz = 2
					else
						dz = -2
					end
				end

				pos = Vector3.new(math.round(x/4)*4+dx,math.round(y/2)*2+dy,math.round(z/4)*4+dz)

				small:MoveTo(pos)
			else
				----7/11print("c")
				if highlighter then
					highlighter:Destroy()
					on = false
				end
				for i,v in pairs(small:GetChildren()) do
					if v.Name ~= "a" then
						v.Transparency = 1
					end
				end
				if not on then
					for i,v in pairs(big:GetChildren()) do
						if v.Name ~= "a" then
							v.Transparency = 0
						end
					end
					on = true
				end
				local pos
				local x,cx,dx = position.X,camPos.X,0
				local y,cy,dy = position.Y,camPos.Y,0
				local z,cz,dz = position.Z,camPos.Z,0
				local bx,by,bz -- block chosen position
				
				
				if math.abs(math.round(x) - x) < 0.001 then
					if cx - x > 0  then
						dx = -2
					else
						dx = 2
					end
				else
					if x > math.round(x/4)*4  then
						dx = 2
					else
						dx = -2
					end
				end
				if math.abs(math.round(y) - y) < 0.001  then
					if cy - y > 0 then
						dy = -2
					else
						dy = 2
					end
				else
					if y > math.round(y/4)*4  then
						dy = 2
					else
						dy = -2
					end
				end
				if math.abs(math.round(z) - z) < 0.001  then
					if cz - z > 0 then
						dz = -2 
					else
						dz = 2
					end
				else
					if z > math.round(z/4)*4  then
						dz = 2
					else
						dz = -2
					end
				end

				pos = Vector3.new(math.round(x/4)*4+dx,math.round(y/4)*4+dy,math.round(z/4)*4+dz)

				big:MoveTo(pos)
			end
		else
			
			if highlighter then
				highlighter:Destroy()
			end
			
			on = false
			for i,v in pairs(big:GetChildren()) do
				if v.Name ~= "a" then
					v.Transparency = 1
				end
			end
			for i,v in pairs(small:GetChildren()) do
				if v.Name ~= "a" then
					v.Transparency = 1
				end
			end
		end
	end
end