/// Bodyparts and organs which inherit the colour of their host
/datum/element/inherit_body_colour

/datum/element/inherit_body_colour/Attach(datum/target)
	. = ..()
	if (!isorgan(target) && !isbodypart(target))
		return ELEMENT_INCOMPATIBLE
	if (isbodypart(target))
		RegisterSignal(target, COMSIG_BODYPART_ATTACHED, PROC_REF(on_part_attached))
	else if (isorgan(target))
		RegisterSignal(target, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))

/datum/element/inherit_body_colour/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_BODYPART_ATTACHED, COMSIG_ORGAN_REMOVED))
	return ..()

/// When we are attached to a mob, grab their mutant colour.
/datum/element/inherit_body_colour/proc/on_part_attached(obj/item/bodypart/part, mob/living/carbon/new_owner)
	SIGNAL_HANDLER
	part.skin_tone = ""
	part.species_color = get_colour(new_owner)
	part.update_draw_color()

/// When we are removed from a mob, grab their mutant colour. You can't normally see organs before they're removed.
/datum/element/inherit_body_colour/proc/on_organ_removed(obj/item/organ/organ, mob/living/carbon/old_owner)
	SIGNAL_HANDLER
	if (!HAS_TRAIT(old_owner, TRAIT_MUTANT_COLORS) || !old_owner.has_dna())
		return
	organ.color = rgb2num(get_colour(old_owner))

/// Get appropriate colour from mob
/datum/element/inherit_body_colour/proc/get_colour(mob/living/carbon/owner)
	var/mob/living/carbon/human/human_owner = owner
	if (istype(human_owner) && HAS_TRAIT(human_owner, TRAIT_USES_SKINTONES) && human_owner.skin_tone)
		return skintone2hex(human_owner.skin_tone)

	if (HAS_TRAIT(owner, TRAIT_MUTANT_COLORS))
		var/datum/species/owner_species = owner.dna?.species
		if(owner_species?.fixed_mut_color)
			return owner_species.fixed_mut_color
		if (owner.dna.features[FEATURE_MUTANT_COLOR])
			return owner.dna.features[FEATURE_MUTANT_COLOR]

	return COLOR_GREEN
