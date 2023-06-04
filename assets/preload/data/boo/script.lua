
--[Fraze Template]

local camSwingAmount = 0
local noteSwingAmount = 0
local cameraZoom = 1

local swingFactor = 4
local camSwingFactor = 2

local noteXSwing = false
local noteYSwing = false
local camSwing = false
local shaking = false


function start (song)
		
		strumLine2Visible = false
		strumLine1Visible = false
		showOnlyStrums = true

		
		for i = 0, 3 do -- go to the center
		tweenPosXAngle(i, _G['defaultStrum'..i..'X'] - 600,getActorAngle(i), 0.1, 'setDefault')
	end

		for i = 4, 7 do -- go to the center
		tweenPosXAngle(i, _G['defaultStrum'..i..'X'] + 600,getActorAngle(i), 0.1, 'setDefault')
	end

end


function update (elapsed)
		local currentBeat = (songPos / 1000)*(bpm/60)
	
		if camSwing == true then
		setCamPosition(camSwingAmount * math.sin((currentBeat* math.pi)/(camSwingFactor)), camSwingAmount * math.cos((currentBeat* math.pi)/(camSwingFactor)))
		end

		if shaking == true then
			for i=0,7 do
			setActorY(_G['defaultStrum'..i..'Y'] + noteSwingAmount * math.sin((currentBeat + i) * math.pi*8/swingFactor), i)
			setActorX(_G['defaultStrum'..i..'X'] + noteSwingAmount * math.cos((currentBeat + i) * math.pi*8/swingFactor), i)
			end

		else

        for i=0,7 do
			if noteXSwing == true then
			setActorX(_G['defaultStrum'..i..'X'] + noteSwingAmount * math.sin((currentBeat + i) * math.pi/(swingFactor/2)), i)
			end
			if noteYSwing == true then
			setActorY(_G['defaultStrum'..i..'Y'] + noteSwingAmount * math.cos((currentBeat + i*.25) * math.pi/(swingFactor/2)), i)
			end
		end

		end
		--tweenCameraZoom(cameraZoom,45/bpm)

end

function stepHit(step)
	
	if curStep == 96 then 
	noteXSwing = true
	end

	if curStep == 96 or curStep == 720 or curStep == 976 then
		strumLine1Visible = true
	end

	if curStep == 640 or curStep == 900 or curStep == 1376 then
		strumLine1Visible = false
	end

	if curStep == 224 or curStep == 614 or curStep == 752 or curStep == 1167 then
		strumLine2Visible = true
	end

	if curStep == 526 or curStep == 640 or curStep == 790 or curStep == 1370 then
		strumLine2Visible = false
	end

end