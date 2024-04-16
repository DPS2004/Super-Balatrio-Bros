--- STEAMODDED HEADER
--- MOD_NAME: Super Balatrio Bros.
--- MOD_ID: superbalatriobros
--- MOD_AUTHOR: [DPS2004]
--- MOD_DESCRIPTION: So Retro!
--- DISPLAY_NAME: Super Balatrio
--- BADGE_COLOUR: F8451C


local jokerInfoDefault = {
	name = 'NONE',
	config = nil,
	text = {'text'},
	baseEffect = nil,
	rarity = 1,
	cost = 1,
	canBlueprint = true,
	canEternal = true,
	--functions
	locDef = nil,
	init = nil,
	calculate = nil,
	update = nil
}

local function fillInDefaults(t,d)
	for k,v in pairs(d) do
		if t[k] == nil then t[k] = v end
	end
end


function SMODS.INIT.superbalatriobros()
	local mod = SMODS.findModByID('superbalatriobros')
	
	
	------------------------------Set up emulator
	local oldRequire = require
	require = function(path)
		return love.filesystem.load(mod.path .. 'LuaNES/'..path..'.lua')()
	end
	
	require('nes')
	mod.nesData = {}
	mod.nesData.width = 256
	mod.nesData.height = 240
	mod.nesData.imageData = love.image.newImageData(mod.nesData.width + 1, mod.nesData.height + 1)
    mod.nesData.image = love.graphics.newImage(mod.nesData.imageData)
	local samplerate = 44100
	local bits = 16
	local channels = 1
	mod.nesData.sound = love.sound.newSoundData(samplerate / 60 + 1, samplerate, bits, channels)
	mod.nesData.QS = love.audio.newQueueableSource(samplerate, bits, channels)
	
	mod.nesData.framesToUpdate = 0
	mod.nesData.fps = 59.94
	
	
	mod.nes = NES:new({
		file = love.filesystem.getSaveDirectory() ..'/' .. mod.path .. 'LuaNES/roms/Super Mario Bros (E).nes',
		loglevel = 0,
		pc = nil,
		palette = UTILS.map(
			PALETTE:defacto_palette(),
			function(c)
				return {c[1] / 256, c[2] / 256, c[3] / 256}
			end
		)
	})
	mod.nes:reset()
	
	
	--start binding to love

	mod.nesData.keyEvents = {}
	local keyButtons = {
		["w"] = Pad.UP,
		["a"] = Pad.LEFT,
		["s"] = Pad.DOWN,
		["d"] = Pad.RIGHT,
		["o"] = Pad.A,
		["p"] = Pad.B,
		["i"] = Pad.SELECT,
		["return"] = Pad.START
	}	
	
	
	local loveKeyPressedRef = love.keypressed
	local loveKeyReleasedRef = love.keyreleased
	local loveUpdateRef = love.update
	local loveDrawRef = love.draw
	
	function love.keypressed(key)
		for k, v in pairs(keyButtons) do
			if k == key then
				mod.nesData.keyEvents[#mod.nesData.keyEvents + 1] = {"keydown", v}
			end
		end
		loveKeyPressedRef(key)
	end
	
	function love.keyreleased(key)
		for k, v in pairs(keyButtons) do
			if k == key then
				mod.nesData.keyEvents[#mod.nesData.keyEvents + 1] = {"keyup", v}
			end
		end
		loveKeyReleasedRef(key)
	end
	
	function love.update(dt)
		mod.nesData.framesToUpdate = mod.nesData.framesToUpdate + (dt * mod.nesData.fps)
		
		while mod.nesData.framesToUpdate > 1 do
			
			for i, v in ipairs(mod.nesData.keyEvents) do
				mod.nes.pads[v[1]](mod.nes.pads, 1, v[2])
			end
			
			mod.nesData.keyEvents = {}
			mod.nes:run_once()
			
			local samples = mod.nes.cpu.apu.output
			for i = 1, #samples do
				mod.nesData.sound:setSample(i, samples[i])
			end
			mod.nesData.QS:queue(mod.nesData.sound)
			mod.nesData.QS:play()
			
			mod.nesData.framesToUpdate = mod.nesData.framesToUpdate - 1
		end
		
		loveUpdateRef(dt)
	end
	
	function love.draw()
		loveDrawRef()
		
		love.graphics.setColor(1,1,1,1)
		local pxs = mod.nes.cpu.ppu.output_pixels
		
		for i=1,PPU.SCREEN_HEIGHT * PPU.SCREEN_WIDTH do
			local x = (i - 1) % mod.nesData.width
			local y = math.floor((i - 1) / mod.nesData.width) % mod.nesData.height
			local px = pxs[i]
			mod.nesData.imageData:setPixel(x + 1, y + 1, px[1], px[2], px[3], 1)
		end
		mod.nesData.image:replacePixels(mod.nesData.imageData)
		love.graphics.draw(mod.nesData.image)
		
	end
	
	
	-----------------------------Joker handling
	--local jokerInfo = love.filesystem.load(mod.path .. 'jokers/'..v..'.lua')()
	--fillInDefaults(jokerInfo,jokerInfoDefault)
	
	local joker = SMODS.Joker:new(
		"Super Balatrio Bros.",
		'supermariobros', {},
		{x=0,y=0},
		{name = "Super Balatrio Bros.",text = {'So Retro!'}},
		3,
		5,
		true,
		true,
		false,
		true
	)
	
	joker:register()
	
	local jself = SMODS.Jokers['j_supermariobros']
	
	
	
	--jself.loc_def = jokerInfo.locDef
	
	--jself.set_ability = jokerInfo.init
	
	--jself.calculate = jokerInfo.calculate
	
	
	--load sprite
	SMODS.Sprite:new('j_supermariobros',mod.path,'supermariobros.png',71,95,'asset_atli'):register()
		

	
	
	--updates
	local card_updateRef = Card.update
	function Card.update(self, dt)
		if self.ability.name == "Super Balatrio Bros." then
			if G.STAGE == G.STAGES.RUN then
				--do the Mario
				--swing your arms from side to side
			end
		end
		card_updateRef(self,dt)
	end
	
	--[[
	for k,v in pairs(localizations) do
		G.localization.misc.dictionary[k] = v
	end
    init_localization()
	]]
	
	--Debug deck, for easy testing.
	local Backapply_to_runRef = Back.apply_to_run
	-- Function used to apply new Deck effects
	function Back.apply_to_run(arg_56_0)
		
		if arg_56_0.effect.config.mariodeck then
			G.E_MANAGER:add_event(Event({
				func = function()
					local card = create_card('Joker', G.jokers, nil, nil, nil, nil, 'j_supermariobros', nil)
					card:add_to_deck()
					G.jokers:emplace(card)
					card:start_materialize()
					G.GAME.joker_buffer = 0

					return true
				end
			
			}))
		
		end
		Backapply_to_runRef(arg_56_0)
	end

	local debugDeckLoc = {
		name="Super Balatrio Bros testing deck",
		text={
			"If Mario, then only Bros!",
		},
	}
	
	local debugDeckSprite = SMODS.Sprite:new('centers', mod.path, 'Enhancers.png', 71, 95, "asset_atli")
	debugDeckSprite:register()

	local debugDeck = SMODS.Deck:new("Super Balatrio Bros testing deck", "mariodeck", {mariodeck = true}, {x = 0, y = 5}, debugDeckLoc)
	debugDeck:register()

	




	--undo require hack
	
	require = oldRequire
end


