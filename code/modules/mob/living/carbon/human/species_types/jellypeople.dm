/// Like slime people but different
/datum/species/jelly
	name = "\improper Jelly"
	plural_form = "Jellies"
	id = SPECIES_JELLY
	examine_limb_id = SPECIES_JELLY
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID|MOB_SLIME
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_AGENDER,
		TRAIT_TOXINLOVER,
	)
	mutantbrain = /obj/item/organ/brain/jelly
	mutanttongue = /obj/item/organ/tongue/jelly
	mutantlungs = /obj/item/organ/lungs/jelly
	mutanteyes = /obj/item/organ/eyes/slime
	mutantstomach = /obj/item/organ/stomach/jelly
	mutantheart = /obj/item/organ/heart/jelly
	mutantliver = /obj/item/organ/liver/jelly
	meat = /obj/item/food/meat/slab/human/mutant/slime
	exotic_blood = BLOOD_TYPE_TOX
	heatmod = 0.5
	high_pressure_mod = 0.75 // Stacks with bodyparts being resistant to brute damage
	low_pressure_mod = 2.5 // Cancels out bodyparts being resistant to brute damage and adds a bit more
	bodytemp_heat_damage_limit = BODYTEMP_HEAT_LAVALAND_SAFE // Note that their slime will start evaporating earlier than this
	exotic_bloodtype = BLOOD_TYPE_TOX
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/jelly
	hair_color_mode = USE_MUTANT_COLOR
	hair_alpha = 150
	facial_hair_alpha = 150
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/jelly,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/jelly,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/jelly,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/jelly,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/jelly,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/jelly,
	)

/datum/species/jelly/get_physical_attributes()
	return "Jellies are made of slime, which makes them quite resistant to ordinary damage but needs to be managed carefully. \
		Notably, many things which only do stamina damage will still cause Jellies to lose slime as if they were harmed. \
		Too little slime will cause them to lose limbs and regress into a simple blob, too much will leave them bloated (but with extra arms). \
		Most sources of toxin damage are inverted for Jellies, and they are harmed by water exposure. \
		They also freeze up in cold temperatures and are particularly vulnerable to low atmospheric pressure, as it disrupts their surface tension."

/datum/species/jelly/get_species_description()
	return "The Jelid (more commonly called 'Jellies') are an amorphous species sharing many traits in common with the galactic pest known as slimes, \
		They have spread quickly throughout known space by sneaking aboard other peoples' ships, and it's not totally clear where they originated from."

/datum/species/jelly/get_species_lore()
	return list(
		"Wanderers and stowaways found all across inhabited space. \
		Rumours claim that their ancestors chose to leave (or were exiled) from a highly advanced technological utopia which has never been located, \
		although the specifics tend to be highly embellished depending on the individual storyteller.",

		"An inquisitive nature and lack of desire to set down roots drives them to spread far and wide in search of novelty. \
		Their natural adaptiveness and durability, combined with a talent for hiding in small spaces, mean that they frequently show up in unexpected locations. \
		This same habit of sneaking into the ships and habitats of other peoples undetected gives them something of a reputation as vagrants, thieves, and pirates \
		which is not exactly fairly earned.",

		"Jellies tend to be highly individualistic with little common culture, instead ingratiating themselves with their hosts wherever they happen to be. \
		With no single place to call home your average Jelly typically tries their best to be unobtrusive and make no enemies, although there are always \
		those who will instead take advantage of their unique talents for personal gain."
	)

/datum/species/jelly/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "syringe",
			SPECIES_PERK_NAME = "Toxins Lover",
			SPECIES_PERK_DESC = "Toxins damage dealt to [plural_form] are reversed - healing toxins will instead cause harm, and \
				causing toxins will instead cause healing. Be careful around purging chemicals!",
		), // This is on our liver not our species so it doesn't automatically detect it
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_SKULL,
			SPECIES_PERK_NAME = "Mind Over Matter",
			SPECIES_PERK_DESC = "Jellies shrivel into a dense core upon death, which must be splashed with toxins before it can be revived.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_GLASS_WATER,
			SPECIES_PERK_NAME = "Hydrophobia",
			SPECIES_PERK_DESC = "Water disrupts a Jelly's surface and hurts them.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_SPLOTCH,
			SPECIES_PERK_NAME = "Splash Damage",
			SPECIES_PERK_DESC = "Stamina damage, usually not harmful to anyone's health, causes Jellies to lose goo and can eventually kill them.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_BONE,
			SPECIES_PERK_NAME = "Voracious",
			SPECIES_PERK_DESC = "Jellies will begin to digest their own limbs while starving, eventually reverting into a limbless blob and then an inert core.",
		),
	)

	return to_add

/datum/species/jelly/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features[FEATURE_MUTANT_COLOR] = COLOR_PINK
	human.hairstyle = "Bob Hair 2"
	human.hair_color = COLOR_PINK
	human.update_body(is_creating = TRUE)

// Unique handling for slime blood here, it's got some unique properties that warrant a more detailed desc.
/datum/species/jelly/create_pref_blood_perks()
	var/list/to_add = list()
	var/datum/blood_type/blood_type = get_blood_type(exotic_bloodtype)

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "tint",
		SPECIES_PERK_NAME = "Jelly Blood",
		SPECIES_PERK_DESC = "[plural_form] don't have blood, but instead are composed almost entirely of [initial(blood_type.reagent_type.name)]! \
			This goo is extremely important, as losing it will cause you to lose limbs and eventually regress into the form of a simple blob. \
			Having too MUCH goo causes you to bloat up, slow down, and grow additional pseudopods that can hold things.",
	))

	return to_add

/datum/species/jelly/create_pref_temperature_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "thermometer-empty",
		SPECIES_PERK_NAME = "Liquid Surface",
		SPECIES_PERK_DESC = "Jellies are quite resistant to high temperature and pressure, although it causes their body to evaporate more quickly. \
			While they aren't rapidly harmed by low temperature it is still very dangerous to them, as it causes them to freeze and disables their limbs. \
			They must also beware low pressure, which disrupts their surface tension and causes rapid goo loss.",
	))

	return to_add
