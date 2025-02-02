/// Bodypart which slowly dies if not attached to a specific kind of other part
/datum/component/bodypart_dependent
	/// Biotypes that are needed in order to avoid damage
	var/biotypes_required
	/// Body zone to check on owning mob
	var/target_zone

/datum/component/bodypart_dependent/Initialize(biotypes_required, target_zone)
	. = ..()
	if (!isbodypart(parent))
		return COMPONENT_INCOMPATIBLE
	src.biotypes_required = biotypes_required
	src.target_zone = target_zone

/datum/component/bodypart_dependent/RegisterWithParent()
	RegisterSignal(parent, COMSIG_BODYPART_ATTACHED, PROC_REF(on_parent_attached))
	RegisterSignal(parent, COMSIG_BODYPART_REMOVED, PROC_REF(on_parent_removed))

/datum/component/bodypart_dependent/UnregisterFromParent()
	var/obj/item/bodypart/part_parent = parent
	UnregisterSignal(parent, list(COMSIG_BODYPART_ATTACHED, COMSIG_BODYPART_REMOVED))
	if (part_parent.owner)
		on_parent_removed(parent, part_parent.owner)

/// When put into a mob, check our target part and register to monitor if it changes
/datum/component/bodypart_dependent/proc/on_parent_attached(obj/item/bodypart/part, mob/living/carbon/new_owner)
	SIGNAL_HANDLER
	RegisterSignal(new_owner, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(on_new_part))
	RegisterSignal(new_owner, COMSIG_CARBON_POST_REMOVE_LIMB, PROC_REF(on_removed_part))

	var/current_part = new_owner.get_bodypart(target_zone)
	if (current_part)
		on_new_part(new_owner, current_part)

/// When removed from a mob, stop listening to shit
/datum/component/bodypart_dependent/proc/on_parent_removed(obj/item/bodypart/part, mob/living/carbon/former_owner)
	SIGNAL_HANDLER
	UnregisterSignal(former_owner, list(COMSIG_CARBON_POST_ATTACH_LIMB, COMSIG_CARBON_POST_REMOVE_LIMB))

/// When a bodypart is attached, check if we hate it
/datum/component/bodypart_dependent/proc/on_new_part(mob/living/carbon/limb_haver, obj/item/bodypart/new_part, special)
	SIGNAL_HANDLER
	if (new_part.body_zone != target_zone)
		return // We don't care about this body zone
	var/obj/item/bodypart/part_parent = parent
	if (new_part.biological_state & biotypes_required)
		limb_haver.remove_status_effect(/datum/status_effect/corrode_limb/destroy, part_parent.body_zone, part_parent.plaintext_zone)
		return
	if (is_already_melting())
		return
	limb_haver.apply_status_effect(/datum/status_effect/corrode_limb/destroy, part_parent.body_zone, part_parent.plaintext_zone)

/// When a bodypart is removed, we definitely don't have the appropriate thing
/datum/component/bodypart_dependent/proc/on_removed_part(mob/living/carbon/limb_haver, obj/item/bodypart/old_part, special)
	SIGNAL_HANDLER
	if (old_part.body_zone != target_zone)
		return // We don't care about this body zone
	if (is_already_melting())
		return
	var/obj/item/bodypart/part_parent = parent
	limb_haver.apply_status_effect(/datum/status_effect/corrode_limb/destroy, part_parent.body_zone, part_parent.plaintext_zone)

/datum/component/bodypart_dependent/proc/is_already_melting()
	var/obj/item/bodypart/part_parent = parent
	if (!part_parent.owner)
		return FALSE

	var/list/existing_effects = part_parent.owner.get_all_status_effect_of_type(/datum/status_effect/corrode_limb/destroy)
	for (var/datum/status_effect/corrode_limb/destroy/existing as anything in existing_effects)
		if (existing.target_zone == part_parent.body_zone)
			return TRUE
	return FALSE

/// Damage a limb until it has no health, then kill it
/datum/status_effect/corrode_limb/destroy
	id = "dissolve_limb"
	apply_string = "tingles all over, your body cannot integrate it properly."
	harm_string = "tingles painfully."
	damage_chance = 5
	time_between_alerts = 15 SECONDS

/datum/status_effect/corrode_limb/destroy/tick(seconds_between_ticks)
	. = ..()
	var/mob/living/carbon/carbon_owner = owner
	var/obj/item/bodypart/our_part = carbon_owner.get_bodypart(target_zone)
	if (!our_part) //How?
		qdel(src)
		return
	if (our_part.brute_dam + our_part.burn_dam < our_part.max_damage)
		return
	owner.visible_message(
		span_warning("[owner]'s [plaintext_zone] shrivels to nothing!"),
		span_warning("Your [plaintext_zone] shrivels away!"))
	qdel(our_part)
	qdel(src)
