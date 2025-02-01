/// Bodyparts and organs which inherit the mutantcolour of their host
/datum/element/inherit_mutantcolour

/datum/element/inherit_mutantcolour/Attach(datum/target)
	. = ..()
	if (!isorgan(target) && !isbodypart(target))
		return ELEMENT_INCOMPATIBLE
	if (isbodypart(target))
		RegisterSignal(target, COMSIG_BODYPART_ATTACHED, PROC_REF(on_part_attached))
	else if (isorgan(target))
		RegisterSignal(target, COMSIG_ORGAN_REMOVED, PROC_REF(on_organ_removed))

/datum/element/inherit_mutantcolour/Detach(datum/source)
	UnregisterSignal(source, list(COMSIG_BODYPART_ATTACHED, COMSIG_ORGAN_REMOVED))
	return ..()

/// When we are attached to a mob, grab their mutant colour.
/datum/element/inherit_mutantcolour/proc/on_part_attached(obj/item/bodypart/part, mob/living/carbon/new_owner)
	SIGNAL_HANDLER
	if (!HAS_TRAIT(new_owner, TRAIT_MUTANT_COLORS) || !new_owner.has_dna())
		return
	part.update_limb(is_creating = TRUE)
	new_owner.update_body()

/// When we are removed from a mob, grab their mutant colour. You can't normally see organs before they're removed.
/datum/element/inherit_mutantcolour/proc/on_organ_removed(obj/item/organ/organ, mob/living/carbon/old_owner)
	SIGNAL_HANDLER
	if (!HAS_TRAIT(old_owner, TRAIT_MUTANT_COLORS) || !old_owner.has_dna())
		return
	organ.color = rgb2num(old_owner.dna.features["mcolor"])
