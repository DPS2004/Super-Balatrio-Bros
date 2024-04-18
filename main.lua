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
	mod.nesData.QS:setVolume(0.5)
	
	mod.nesData.framesToUpdate = 0
	mod.nesData.fps = 59.94
	
	mod.nesData.isActive = false
	mod.nesData.showFullView = false
	
	mod.nesData.marioScore = 0
	
	function mod.resetMario()
		print("RESETTING NES")
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
		mod.nesData.isActive = true
	end
	
	
	--start binding to love

	mod.nesData.keyEvents = {}
	local keyButtons = {
		["up"] = Pad.UP,
		["left"] = Pad.LEFT,
		["down"] = Pad.DOWN,
		["right"] = Pad.RIGHT,
		["x"] = Pad.A,
		["z"] = Pad.B,
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
		
		
		loveUpdateRef(dt)
	
		if mod.nesData.isActive then
			
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
			local score = ''
			for i=0x07DD,0x07E2 do
				score = score .. mod.nes.cpu.ram[i]
			end
			mod.nesData.marioScore = tonumber(score)
			if mod.nes.cpu.ram[0x0776] ~= 0 then
				--no pausing allowed!
				for i=0x07DD,0x07E2 do
					mod.nes.cpu.ram[i] = 0
				end
				
				for i=0x07F8,0x07FA do
					mod.nes.cpu.ram[i] = 0
				end
			end
			
			if mod.nes.cpu.ram[0x0770] == 3 then -- game over
				for i=0x07DD,0x07E2 do
					mod.nes.cpu.ram[i] = 0
				end
			end
			
		end
		
	end
	
	function love.draw()
		
		if mod.nesData.isActive then
			love.graphics.setColor(1,1,1,1)
			local pxs = mod.nes.cpu.ppu.output_pixels
			
			for i=1,PPU.SCREEN_HEIGHT * PPU.SCREEN_WIDTH do
				local x = (i - 1) % mod.nesData.width
				local y = math.floor((i - 1) / mod.nesData.width) % mod.nesData.height
				local px = pxs[i]
				mod.nesData.imageData:setPixel(x + 1, y + 1, px[1], px[2], px[3], 1)
			end
			mod.nesData.image:replacePixels(mod.nesData.imageData)
		end
		
		loveDrawRef()
		if mod.nesData.showFullView then
			love.graphics.setColor(1,1,1,0.75)
			love.graphics.draw(mod.nesData.image,0,0,0,1.5,1.5)
		end
		
	end
	
	
	-----------------------------Joker handling
	--local jokerInfo = love.filesystem.load(mod.path .. 'jokers/'..v..'.lua')()
	--fillInDefaults(jokerInfo,jokerInfoDefault)
	
	local joker = SMODS.Joker:new(
		"Super Balatrio Bros.",
		'supermariobros', {},
		{x=0,y=0},
		{name = "Super Balatrio Bros.",text = {
			'{C:attention}Use arrow keys, Z, X, and Enter{}',
			'Gives Chips equal to SCORE/100',
			'{C:attention}Pausing is not allowed.{}',
			'{C:inactive}(Currently {C:chips}+#1#{C:inactive} Chips)'}
		},
		3,
		5,
		true,
		true,
		false,
		true
	)
	
	joker:register()
	
	local jself = SMODS.Jokers['j_supermariobros']
	
	
	
	jself.loc_def = function(self)
		return {self.ability.extra.chips}
	end
	

	local setupCanvas = function(self)
		self.children.center.video = love.graphics.newCanvas(71,95) --why does this work lmaooooooo
		self.children.center.video:renderTo(function()
			love.graphics.clear(1,1,1,0) 
			love.graphics.setColor(1,1,1,1)
			love.graphics.draw(mod.marioCardBase)
		end)
	end
	
	jself.set_ability = function(self)
		self.ability.extra = {
			chips = 0
		}
		setupCanvas(self)

	end
	jself.calculate = function(self, context)
		if SMODS.end_calculate_context(context) then
			return {
				message = localize{type='variable',key='a_chips',vars={self.ability.extra.chips}},
				chip_mod = self.ability.extra.chips, 
				colour = G.C.CHIPS
			}
		end
	end
	
	
	--load sprite
	SMODS.Sprite:new('j_supermariobros',mod.path,'supermariobros.png',71,95,'asset_atli'):register()
	
	--but this time with feeling!
	mod.marioCardBase = love.graphics.newImage(mod.path..'assets/1x/supermariobros.png')
		
	
	--updates
	local card_updateRef = Card.update
	function Card.update(self, dt)
		if self.ability.name == "Super Balatrio Bros." then
			if G.STAGE == G.STAGES.RUN then
				--do the Mario
				--swing your arms from side to side
				if mod.nesData.isActive then
					mod.nesData.framesToUpdate = mod.nesData.framesToUpdate + (dt * mod.nesData.fps) / G.SETTINGS.GAMESPEED
					self.ability.extra.chips = math.floor(mod.nesData.marioScore / 10)
					
				else
					mod.resetMario()
				end
			end
		end
		card_updateRef(self,dt)
	end
	
	local card_drawRef = Card.draw
	
	
	function Card.draw(self, layer)
		if self.ability.name == "Super Balatrio Bros." then
			love.graphics.push('all')
				love.graphics.reset()
				if not self.children.center.video then
					setupCanvas(self)
				end
				self.children.center.video:renderTo(function()
					love.graphics.draw(mod.nesData.image,5,5,0,61 / mod.nesData.width,57 / mod.nesData.height,1,1)
				end)
			love.graphics.pop()
			
		end
		card_drawRef(self,layer)
	end
	
	local cardHoverRef = Card.hover
	local cardStopHoverRef = Card.stop_hover
	
	function Card.hover(self)
		if self.ability.name == "Super Balatrio Bros." then
			mod.nesData.showFullView = true
		end
		cardHoverRef(self)
	end
	
	function Card.stop_hover(self)
		if self.ability.name == "Super Balatrio Bros." then
			mod.nesData.showFullView = false
		end
		cardStopHoverRef(self)
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


