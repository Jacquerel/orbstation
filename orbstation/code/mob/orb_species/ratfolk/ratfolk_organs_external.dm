// SNOUT
/obj/item/organ/external/snout_rat
	name = "ratfolk snout"
	desc = "Take a closer look at that snout!"
	icon_state = "snout"

	zone = BODY_ZONE_HEAD
	slot = ORGAN_SLOT_EXTERNAL_SNOUT
	preference = "feature_rat_snout"
	external_bodyshapes = BODYSHAPE_SNOUTED

	bodypart_overlay = /datum/bodypart_overlay/mutant/snout_rat

/datum/bodypart_overlay/mutant/snout_rat
	layers = EXTERNAL_ADJACENT
	feature_key = "rat_snout"


/datum/bodypart_overlay/mutant/snout_rat/can_draw_on_bodypart(mob/living/carbon/human/human)
	if(!QDELETED(human) && !(human.wear_mask?.flags_inv & HIDESNOUT) && !(human.head?.flags_inv & HIDESNOUT))
		return TRUE
	return FALSE

/datum/bodypart_overlay/mutant/snout_rat/get_global_feature_list()
	return SSaccessories.rat_snouts_list

/datum/bodypart_overlay/mutant/snout_rat/colour_inner(mutable_appearance/appearance, obj/item/bodypart/limb)
	appearance.color = COLOR_WHITE // Don't know why I had to do this but it works

// TAIL

/obj/item/organ/external/tail/ratfolk
	name = "ratfolk tail"
	desc = "A severed rat tail."
	preference = "feature_rat_tail"
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/rat

/datum/bodypart_overlay/mutant/tail/rat
	feature_key = "rat_tail"

/datum/bodypart_overlay/mutant/tail/rat/get_global_feature_list()
	return SSaccessories.rat_tails_list
