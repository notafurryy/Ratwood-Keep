/datum/subclass/performer
	name = "Performer"
	tutorial = "Your whole life has been a degrading spectacle. Whether as part of a traveling circus or lone performer, \
				you've learned how to sell your talents or your body. The depressing state of the world has driven you to \
				seek refuge in a place where entertainment is still valued, even if it's just a distraction from the catastrophe."

	allowed_sexes = list(MALE, FEMALE)
	allowed_races = RACES_ALL_KINDS
	category_tags = list(CTAG_REFUGEE)

	maximum_possible_slots = 5

	outfit = /datum/outfit/job/roguetown/refugee/performer

/datum/outfit/job/roguetown/refugee/performer
	allowed_patrons = ALL_PATRONS

/datum/outfit/job/roguetown/refugee/performer/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_blindness(-3)
	var/classes = list("Whore", "Minstrel", "Harlequin")
	var/classchoice = input("Choose your archetypes", "Available archetypes") as anything in classes

	switch(classchoice)

		if("Whore")
			H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/stealing, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/riding, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/treatment, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/sewing, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
			shoes = /obj/item/clothing/shoes/roguetown/shortboots
			neck = /obj/item/storage/belt/rogue/pouch/coins/poor
			r_hand = /obj/item/soap/bath
			if(H.gender == MALE)
				pants =	/obj/item/clothing/under/roguetown/loincloth
				belt =	/obj/item/storage/belt/rogue/leather/cloth
			else
				shirt = /obj/item/clothing/suit/roguetown/shirt/undershirt
				armor = /obj/item/clothing/suit/roguetown/shirt/dress/gen/sexy
				pants =	/obj/item/clothing/under/roguetown/tights/stockings/fishnet/random
				belt =	/obj/item/storage/belt/rogue/leather/cloth
			H.change_stat("constitution", 1)
			H.change_stat("endurance", 2)
			ADD_TRAIT(H, TRAIT_GOODLOVER, TRAIT_GENERIC)

		if("Minstrel")
			H.mind.adjust_skillrank(/datum/skill/combat/wrestling, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/unarmed, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/swimming, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/athletics, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/combat/knives, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/stealing, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/treatment, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/craft/cooking, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/music, 4, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/lockpicking, 2, TRUE)
			head = /obj/item/clothing/head/roguetown/bardhat
			pants = /obj/item/clothing/under/roguetown/tights/random
			gloves = /obj/item/clothing/gloves/roguetown/fingerless
			belt = /obj/item/storage/belt/rogue/leather
			armor = /obj/item/clothing/suit/roguetown/armor/leather/vest
			cloak = /obj/item/clothing/cloak/raincloak/blue
			backl = /obj/item/storage/backpack/rogue/satchel
			beltl = /obj/item/ammo_holder/bomb/smokebombs
			beltr = /obj/item/rogueweapon/huntingknife/idagger
			head = /obj/item/clothing/head/roguetown/bardhat //with this hat, they will get all the pussy(or dick depending on preference(or both ig))
			neck = /obj/item/storage/belt/rogue/pouch/coins/poor
			shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/noblecoat
			shoes = /obj/item/clothing/shoes/roguetown/shortboots
			backpack_contents = list(/obj/item/natural/feather = 1, /obj/item/paper = 1)
			H.change_stat("intelligence", 2)
			H.change_stat("perception", 2)
			H.change_stat("speed", 2)
			ADD_TRAIT(H, TRAIT_EMPATH, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_GOODLOVER, TRAIT_GENERIC)
			ADD_TRAIT(H, TRAIT_BARDIC_TRAINING, TRAIT_GENERIC)
			var/instruments = list(
			"Harp" = /obj/item/rogue/instrument/harp,
			"Lute" = /obj/item/rogue/instrument/lute,
			"Accordion" = /obj/item/rogue/instrument/accord,
			"Guitar" = /obj/item/rogue/instrument/guitar,
			"Flute" = /obj/item/rogue/instrument/flute,
			"Drum" = /obj/item/rogue/instrument/drum,
			"Hurdy-Gurdy" = /obj/item/rogue/instrument/hurdygurdy,
			"Viola" = /obj/item/rogue/instrument/viola)
			var/instrument_choice = input("Choose your instrument.", "XYLIX") as anything in instruments
			H.set_blindness(0)
			if(instrument_choice && instruments[instrument_choice])
				backr = instruments[instrument_choice]
			else
				backr = /obj/item/rogue/instrument/lute

		if("Harlequin")
			H.mind.adjust_skillrank(/datum/skill/combat/knives, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/reading, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/sneaking, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/stealing, 1, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/climbing, 3, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/music, 2, TRUE)
			H.mind.adjust_skillrank(/datum/skill/misc/lockpicking, 1, TRUE)
			H.cmode_music = 'sound/music/combat_jester.ogg'
			H.verbs |= /mob/living/carbon/human/proc/ventriloquate
			H.verbs |= /mob/living/carbon/human/proc/ear_trick
			// TODO: Make alternative colored versions of the jester outfit
			shoes = /obj/item/clothing/shoes/roguetown/jester
			pants = /obj/item/clothing/under/roguetown/tights
			armor = /obj/item/clothing/suit/roguetown/shirt/jester
			belt = /obj/item/storage/belt/rogue/leather
			beltr = /obj/item/ammo_holder/bomb/smokebombs
			beltl = /obj/item/storage/belt/rogue/pouch
			head = /obj/item/clothing/head/roguetown/jester
			neck = /obj/item/clothing/neck/roguetown/coif
			H.change_stat("intelligence", 2)
			H.change_stat("perception", -1)
			H.change_stat("speed", 1)
			ADD_TRAIT(H, TRAIT_NUTCRACKER, TRAIT_GENERIC)

	H.set_blindness(0)
