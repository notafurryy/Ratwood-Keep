
/obj/item/rogue/instrument
	name = ""
	desc = ""
	icon = 'icons/roguetown/items/music.dmi'
	icon_state = ""
	slot_flags = ITEM_SLOT_HIP|ITEM_SLOT_BACK_R|ITEM_SLOT_BACK_L
	can_parry = TRUE
	force = 23
	throwforce = 7
	throw_range = 4
	var/datum/looping_sound/dmusloop/soundloop
	var/list/song_list = list()
	var/playing = FALSE
	w_class = WEIGHT_CLASS_NORMAL


/obj/item/rogue/instrument/equipped(mob/living/user, slot)
	. = ..()
	if(playing && user.get_active_held_item() != src)
		playing = FALSE
		soundloop.stop()

/obj/item/rogue/instrument/getonmobprop(tag)
	. = ..()
	if(tag)
		switch(tag)
			if("gen")
				return list(
					"shrink" = 0.4,
					"sx" = 0,
					"sy" = 0,
					"nx" = 0,
					"ny" = 0,
					"wx" = -4,
					"wy" = 0,
					"ex" = 2,
					"ey" = 0,
					"northabove" = 0,
					"southabove" = 1,
					"eastabove" = 1,
					"westabove" = 1,
					"nturn" = 0,
					"sturn" = 0,
					"wturn" = 0,
					"eturn" = 0,
					"nflip" = 8,
					"sflip" = 8,
					"wflip" = 8,
					"eflip" = 0
				)
			if("onbelt")
				return list(
					"shrink" = 0.3,
					"sx" = -2,
					"sy" = -5,
					"nx" = 4,
					"ny" = -5,
					"wx" = 0,
					"wy" = -5,
					"ex" = 2,
					"ey" = -5,
					"nturn" = 0,
					"sturn" = 0,
					"wturn" = 0,
					"eturn" = 0,
					"nflip" = 0,
					"sflip" = 0,
					"wflip" = 0,
					"eflip" = 0,
					"northabove" = 0,
					"southabove" = 1,
					"eastabove" = 1,
					"westabove" = 0
				)
				
/obj/item/rogue/instrument/Initialize()
	soundloop = new(src, FALSE)
	. = ..()

/obj/item/rogue/instrument/Destroy()
	terminate_playing(loc)
	. = ..()

/obj/item/rogue/instrument/process()
	..()
	if(!playing || !ishuman(loc))
		terminate_playing(loc)
		return PROCESS_KILL

	var/mob/living/carbon/human/user = loc
	if(!user.has_status_effect(/datum/status_effect/buff/playing_music)) //someone that isnt't the musician is somehow holding it
		terminate_playing(loc)
		return PROCESS_KILL

	if(user.get_inactive_held_item() && user.mind?.get_skill_level(/datum/skill/misc/music) < 4)
		terminate_playing(loc)
		return PROCESS_KILL

	user.apply_status_effect(/datum/status_effect/buff/playing_music) // Handles regular stress event in tick()
	var/boon = user?.mind?.get_learning_boon(/datum/skill/misc/music)
	user?.mind?.adjust_experience(/datum/skill/misc/music, ceil((user.STAINT*0.2) * boon) * 0.2) // And gain exp

	if(!HAS_TRAIT(user, TRAIT_BARDIC_TRAINING))
		return

	for(var/mob/living/carbon/L in hearers(7, loc))
		if(!L.client)
			continue
		if(!L.can_hear()) // Only good people who can hear music will get buffed
			continue
		if((L.mob_biotypes & MOB_UNDEAD) && !(user.mob_biotypes & MOB_UNDEAD))
			continue
		L.add_stress(/datum/stressevent/bardicbuff)
		if(!instrument_buff)
			continue
		if(L.mind?.has_antag_datum(/datum/antagonist))
			if(!L.mind?.isactuallygood())
				continue
		L.apply_status_effect(instrument_buff)

	for(var/obj/item/reagent_containers/food/snacks/smallrat/I in view(4, user))
		if(I.loc != user)
			step_towards(I, user)

/obj/item/rogue/instrument/proc/terminate_playing(mob/living/user)
	playing = FALSE
	STOP_PROCESSING(SSprocessing, src)
	if(istype(user))
		user.remove_status_effect(/datum/status_effect/buff/playing_music)
	instrument_buff = null
	if(soundloop)
		soundloop.stop()
		soundloop.stress2give = initial(soundloop.stress2give)
	if(dynamic_icon)
		lower_from_mouth()
		update_icon()
	// Prevents an exploit
	for(var/mob/living/carbon/L in hearers(7, loc))
		var/mob/living/carbon/buffed = L
		for(var/datum/status_effect/bardicbuff/b in L.status_effects)
			buffed.remove_status_effect(b) // All applicable bard buffs stopped

/obj/item/rogue/instrument/equipped(mob/living/user, slot)
	. = ..()
	if(!playing)
		return
	if(!istype(user) || slot != SLOT_HANDS)
		terminate_playing(user)
		return

/obj/item/rogue/instrument/dropped(mob/user, silent)
	if(playing)
		terminate_playing(user)
	. = ..()

/obj/item/rogue/instrument/attack_self(mob/living/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if(playing)
		terminate_playing(user)
		return
	var/music_level = 0
	if(user.mind)
		music_level = user.mind.get_skill_level(/datum/skill/misc/music)
	if(user.get_inactive_held_item() && music_level < 4) //DUAL WIELDING BARDS
		return
	for(var/obj/item/rogue/instrument/I in user.held_items) //sorry it's too annoying
		if(I.playing)
			return

	var/curfile = input(user, "Which song do you want to play?", "Pick a song", name) as null|anything in song_list
	if(!curfile)
		return
	curfile = song_list[curfile]
	if(!curfile)
		return

	var/note_color = "#7f7f7f" // uses MMO item rarity color grading
	var/stressevent = /datum/stressevent/music
	switch(music_level)
		if(1)
			stressevent = /datum/stressevent/music
		if(2)
			note_color = "#ffffff"
			stressevent = /datum/stressevent/music/two
		if(3)
			note_color = "#1eff00"
			stressevent = /datum/stressevent/music/three
		if(4)
			note_color = "#0070dd"
			stressevent = /datum/stressevent/music/four
		if(5)
			note_color = "#a335ee"
			stressevent = /datum/stressevent/music/five
		if(6)
			note_color = "#ff8000"
			stressevent = /datum/stressevent/music/six

	playing = TRUE
	soundloop.mid_sounds = list(curfile)
	soundloop.cursound = null
	soundloop.stress2give = stressevent
	soundloop.start()
	user.apply_status_effect(/datum/status_effect/buff/playing_music, stressevent, note_color)
	if(dynamic_icon)
		lift_to_mouth()
		update_icon()
	START_PROCESSING(SSprocessing, src)


	if(playing && HAS_TRAIT(user, TRAIT_BARDIC_TRAINING)) // Non-bards will never get this prompt. Prompt doesn't show if you cancel song selection either.
		var/list/buffs2pick = list()
		switch(music_level) // There has to be a better way to do this, but so far all I've tried doesn't work as intended.
			if(1) // T1
				buffs2pick += list("Noc's Brilliance (+1 INT)" = /datum/status_effect/bardicbuff/intelligence)
			if(1 to 2) // T2
				buffs2pick += list("Noc's Brilliance (+1 INT)" = /datum/status_effect/bardicbuff/intelligence,
								"Malum's Resilience (+1 END)" = /datum/status_effect/bardicbuff/endurance)
			if(1 to 3) // T3
				buffs2pick += list("Noc's Brilliance (+1 INT)" = /datum/status_effect/bardicbuff/intelligence,
								"Malum's Resilience (+1 END)" = /datum/status_effect/bardicbuff/endurance,
								"Pestra's Blessing (+1 CON)" = /datum/status_effect/bardicbuff/constitution)
			if(1 to 4) // T4
				buffs2pick += list("Noc's Brilliance (+1 INT)" = /datum/status_effect/bardicbuff/intelligence,
								"Malum's Perseverance (+1 END)" = /datum/status_effect/bardicbuff/endurance,
								"Pestra's Blessing (+1 CON)" = /datum/status_effect/bardicbuff/constitution,
								"Xylix's Alacrity (+1 SPD)" = /datum/status_effect/bardicbuff/speed)
			if(1 to 5) // T5
				buffs2pick += list("Noc's Brilliance (+1 INT)" = /datum/status_effect/bardicbuff/intelligence,
								"Malum's Perseverance (+1 END)" = /datum/status_effect/bardicbuff/endurance,
								"Pestra's Blessing (+1 CON)" = /datum/status_effect/bardicbuff/constitution,
								"Xylix's Alacrity (+1 SPD)" = /datum/status_effect/bardicbuff/speed,
								"Ravox's Righteous Fury (+1 STR, +1 PER)" = /datum/status_effect/bardicbuff/ravox)
			if(6 to INFINITY) // Legendary onwards
				buffs2pick += list("Noc's Brilliance (+1 INT)" = /datum/status_effect/bardicbuff/intelligence,
								"Malum's Perseverance (+1 END)" = /datum/status_effect/bardicbuff/endurance,
								"Pestra's Blessing (+1 CON)" = /datum/status_effect/bardicbuff/constitution,
								"Xylix's Alacrity (+1 SPD)" = /datum/status_effect/bardicbuff/speed,
								"Ravox's Righteous Fury (+1 STR, +1 PER)" = /datum/status_effect/bardicbuff/ravox,
								"Astrata's Awakening (+energy, +stamina, +1 FOR)" = /datum/status_effect/bardicbuff/awaken) // TAKE THE LAND THAT MUST BE TAKEN
			else // debug
				message_admins("<span class='warning'>[key_name(usr)] is a bard with zero music skill and couldn't choose a buff.</span>")
		var/buff2use = input(user, "Which buff to add to your song?", "Bardic Buffs", name) as null|anything in buffs2pick
		if(buff2use) // Prevents runtime
			instrument_buff = buffs2pick[buff2use] // This is to pick the buff and disregard the name defined at list level.
		else
			to_chat(user, "I decided not to bestow any boons to my music.")

/obj/item/rogue/instrument/proc/lift_to_mouth()
	icon_state = "[icon_prefix]_play"

/obj/item/rogue/instrument/proc/lower_from_mouth()
	icon_state = "[icon_prefix]"


/obj/item/rogue/instrument/lute
	name = "lute"
	desc = "Its graceful curves were designed to weave joyful melodies."
	icon_state = "lute"
	song_list = list(
	"A Knight's Return" = 'sound/music/instruments/lute (1).ogg',
	"Amongst Fare Friends" = 'sound/music/instruments/lute (2).ogg',
	"The Road Traveled by Few" = 'sound/music/instruments/lute (3).ogg',
	"Tip Thine Tankard" = 'sound/music/instruments/lute (4).ogg',
	"A Reed On the Wind" = 'sound/music/instruments/lute (5).ogg',
	"Jests On Steel Ears" = 'sound/music/instruments/lute (6).ogg',
	"Merchant in the Mire" = 'sound/music/instruments/lute (7).ogg')

/obj/item/rogue/instrument/accord
	name = "accordion"
	desc = "A harmonious vessel of nostalgia and celebration."
	icon_state = "accordion"
	song_list = list(
	"Her Healing Tears" = 'sound/music/instruments/accord (1).ogg',
	"Peddler's Tale" = 'sound/music/instruments/accord (2).ogg',
	"We Toil Together" = 'sound/music/instruments/accord (3).ogg',
	"Just One More, Tavern Wench" = 'sound/music/instruments/accord (4).ogg',
	"Moonlight Carnival" = 'sound/music/instruments/accord (5).ogg',
	"'Ye Best Be Goin'" = 'sound/music/instruments/accord (6).ogg',
	"Beloved Blue" = 'sound/music/instruments/accord (7).ogg')

/obj/item/rogue/instrument/guitar
	name = "guitar"
	desc = "A finely crafted instrument of string and wood."
	icon_state = "guitar"
	song_list = list(
	"Fire-Cast Shadows" = 'sound/instruments/guitar (1).ogg',
	"The Forced Hand" = 'sound/instruments/guitar (2).ogg',
	"Regrets Unpaid" = 'sound/instruments/guitar (3).ogg',
	"'Took the Mammon and Ran'" = 'sound/instruments/guitar (4).ogg',
	"Poor Man's Tithe" = 'sound/instruments/guitar (5).ogg',
	"In His Arms Ye'll Find Me" = 'sound/instruments/guitar (6).ogg',
	"Sunset Ballad" = 'sound/instruments/guitar (7).ogg',
	"Romanza" = 'sound/instruments/guitar (8).ogg',
	"Malaguena" = 'sound/instruments/guitar (9).ogg',
	"Song of the Archer" = 'sound/instruments/guitar (10).ogg',
	"The Mask" = 'sound/instruments/guitar (11).ogg',
	"Evolvado" = 'sound/instruments/guitar (12).ogg',
	"Asturias" = 'sound/instruments/guitar (13).ogg',
	"The Fools Journey" = 'sound/instruments/guitar (14).ogg',
	"Prelude to Sorrow" = 'sound/instruments/guitar (15).ogg',
	"The Queen's High Seas" = 'sound/instruments/guitar (16).ogg',
	"El Odio" = 'sound/instruments/guitar (17).ogg',
	"Danza De Las Lanzas" = 'sound/instruments/guitar (18).ogg',
	"The Feline, Forever Returning" = 'sound/instruments/guitar (19).ogg',
	"El Beso Carmesí" = 'sound/instruments/guitar (20).ogg',)

/obj/item/rogue/instrument/harp
	name = "harp"
	desc = "A harp of elven craftsmanship, its strings soothe the heart."
	icon_state = "harp"
	song_list = list("Through Thine Window, He Glanced" = 'sound/music/instruments/harb (1).ogg',
	"The Lady of Red Silks" = 'sound/music/instruments/harb (2).ogg',
	"Eora Doth Watches" = 'sound/music/instruments/harb (3).ogg',
	"Her Arms Caress Me" = 'sound/music/instruments/harb (4).ogg',
	"Dance Between the Sheets" = 'sound/music/instruments/harb (5).ogg',
	"A Mother's Affection" = 'sound/music/instruments/harb (6).ogg',
	"Nightmaiden's Lullaby" = 'sound/music/instruments/harb (7).ogg',
	"On the Breeze" = 'sound/music/instruments/harb (8).ogg',
	"Never Enough" = 'sound/music/instruments/harb (9).ogg',
	"Sundered Heart" = 'sound/music/instruments/harb (10).ogg',
	"Corridors of Time" = 'sound/music/instruments/harb (11).ogg',
	"Determination" = 'sound/music/instruments/harb (12).ogg')

/obj/item/rogue/instrument/flute
	name = "flute"
	desc = "A slender flute carefully carved from a smooth wood piece."
	icon_state = "flute"
	song_list = list(
	"Half-Dragon's Ten Mammon" = 'sound/music/instruments/flute (1).ogg',
	"'The Local Favorite'" = 'sound/music/instruments/flute (2).ogg',
	"Rous in the Cellar" = 'sound/music/instruments/flute (3).ogg',
	"Her Boots, So Incandescent" = 'sound/music/instruments/flute (4).ogg',
	"Moondust Minx" = 'sound/music/instruments/flute (5).ogg',
	"Quest to the Ends" = 'sound/music/instruments/flute (6).ogg')

/obj/item/rogue/instrument/drum
	name = "drum"
	desc = "Fashioned from taut skins across a sturdy frame, pulses like a giant heartbeat."
	icon_state = "drum"
	song_list = list(
	"Barbarian's Moot" = 'sound/music/instruments/drum (1).ogg',
	"Muster the Wardens" = 'sound/music/instruments/drum (2).ogg',
	"The Earth That Quakes" = 'sound/music/instruments/drum (3).ogg')

/obj/item/rogue/instrument/hurdygurdy
	name = "hurdy-gurdy"
	desc = "A knob-driven, wooden string instrument that reminds you of the oceans far."
	icon_state = "hurdygurdy"
	song_list = list(
	"Ruler's One Ring" = 'sound/music/instruments/hurdy (1).ogg',
	"Tangled Trod" = 'sound/music/instruments/hurdy (2).ogg',
	"Motus" = 'sound/music/instruments/hurdy (3).ogg',
	"Becalmed" = 'sound/music/instruments/hurdy (4).ogg',
	"The Bloody Throne" = 'sound/music/instruments/hurdy (5).ogg')

/obj/item/rogue/instrument/viola
	name = "viola"
	desc = "The prim and proper Viola, every prince's first instrument taught."
	icon_state = "viola"
	song_list = list(
	"Far Flung Tale" = 'sound/music/instruments/viola (1).ogg',
	"G Major Cello Suite No. 1" = 'sound/music/instruments/viola (2).ogg',
	"Ursine's Home" = 'sound/music/instruments/viola (3).ogg',
	"Mead, Gold and Blood" = 'sound/music/instruments/viola (4).ogg',
	"Gasgow's Reel" = 'sound/music/instruments/viola (5).ogg')
