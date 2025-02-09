/// What's the most amount of ooze you can have?
#define MAX_OOZE 300
/// Above this amount of ooze of ooze you mutate
#define OOZE_AMOUNT_SLUG 200
/// Above this amount of ooze you start slowing down
#define OOZE_AMOUNT_BLOATED 150
/// Under this amount of ooze you stop slowing down
#define OOZE_AMOUNT_NORMAL 125
/// Under this amount of ooze you start losing limbs
#define OOZE_AMOUNT_DISMEMBER 60
/// Under this amount of ooze you become a simple mob
#define OOZE_AMOUNT_BLOB 30
/// We gain more ooze from eating than we do from starving, just feels better
#define OOZE_NUTRITION_GAIN_MODIFIER 2
/// Gaining and losing toxins has increased effect on your ooze
#define OOZE_TOX_MODIFIER 1.5
/// All of these damage signals lead into the same proc, toxin signal has different timing so it fires even if you have no toxin damage
#define OOZE_NORMAL_DAMAGE_SIGNALS list(COMSIG_LIVING_POST_ADJUST_BRUTE_DAMAGE, COMSIG_LIVING_POST_ADJUST_BURN_DAMAGE, COMSIG_LIVING_POST_ADJUST_OXY_DAMAGE, COMSIG_LIVING_POST_ADJUST_STAMINA_DAMAGE, COMSIG_LIVING_ADJUST_TOX_DAMAGE)

/// Jelly brain handles ooze management
/obj/item/organ/brain/jelly
	name = "nucleus"
	desc = "A seemingly primitive cluster of neurons which powers a Jelly's ability to think and reason."
	icon_state = "adamantine_resonator"
	can_smoothen_out = FALSE
	organ_flags = ORGAN_ORGANIC
	/// Our current ooze level
	var/ooze_amount = 100
	/// UI displaying our ooze level
	var/atom/movable/screen/jelly_ooze/ooze_display

/obj/item/organ/brain/jelly/Initialize(mapload)
	. = ..()
	ooze_amount = rand (85, 115)

/obj/item/organ/brain/jelly/on_mob_insert(mob/living/carbon/brain_owner, special, movement_flags)
	. = ..()

	RegisterSignal(brain_owner, COMSIG_HUMAN_NUTRITION_ADJUSTED, PROC_REF(on_hunger_changed))
	RegisterSignal(brain_owner, COMSIG_CARBON_LIMB_POST_DAMAGED, PROC_REF(on_limb_damage))
	RegisterSignal(brain_owner, COMSIG_CARBON_LIMB_POST_HEALED, PROC_REF(on_limb_healed))
	RegisterSignals(brain_owner, OOZE_NORMAL_DAMAGE_SIGNALS, PROC_REF(on_adjust_damage))
	RegisterSignal(brain_owner, COMSIG_LIVING_REVIVE, PROC_REF(on_full_heal))

	if (brain_owner.hud_used)
		setup_hud()
	else
		RegisterSignal(brain_owner, COMSIG_MOB_HUD_CREATED, PROC_REF(setup_hud))

/obj/item/organ/brain/jelly/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	UnregisterSignal(organ_owner, list(COMSIG_MOB_HUD_CREATED, COMSIG_LIVING_REVIVE, COMSIG_HUMAN_NUTRITION_ADJUSTED, COMSIG_CARBON_LIMB_POST_DAMAGED, COMSIG_CARBON_LIMB_POST_HEALED) + OOZE_NORMAL_DAMAGE_SIGNALS)
	organ_owner.hud_used?.infodisplay -= ooze_display

/// Add our ooze tracker
/obj/item/organ/brain/jelly/proc/setup_hud()
	SIGNAL_HANDLER
	UnregisterSignal(owner, COMSIG_MOB_HUD_CREATED)
	var/datum/hud/hud_used = owner.hud_used

	if (ooze_display)
		hud_used.infodisplay -= ooze_display
	else
		ooze_display = new(null, owner)

	hud_used.infodisplay += ooze_display
	hud_used.show_hud(hud_used.hud_version)

	ooze_display.update_display(ooze_amount)

/// Add or subtract some ooze
/obj/item/organ/brain/jelly/proc/increment_ooze(increment_value)
	ooze_amount = clamp(ooze_amount + round(increment_value, DAMAGE_PRECISION), 0, MAX_OOZE)
	ooze_display?.update_display(ooze_amount)

/// Called when nutrition updates
/obj/item/organ/brain/jelly/proc/on_hunger_changed(mob/living/carbon/our_mob, hunger_adjustment)
	SIGNAL_HANDLER
	if (hunger_adjustment > 0)
		hunger_adjustment *= OOZE_NUTRITION_GAIN_MODIFIER
	increment_ooze(hunger_adjustment)

/// Called when we take some kind of damage
/obj/item/organ/brain/jelly/proc/on_adjust_damage(mob/living/our_mob, type, amount, forced)
	SIGNAL_HANDLER
	if (type == STAMINA && amount < 0)
		return // Stamina healing doesn't restore ooze
	if (type == TOX)
		amount *= -OOZE_TOX_MODIFIER

	increment_ooze(-amount)

/// Called when a limb takes damage
/obj/item/organ/brain/jelly/proc/on_limb_damage(mob/living/our_mob, obj/item/bodypart/limb, brute, burn)
	SIGNAL_HANDLER
	if (!(limb.biological_state & BIO_OOZE))
		return // We only care about oozey parts
	increment_ooze(-(brute + burn))

/// Called when a limb heals damage
/obj/item/organ/brain/jelly/proc/on_limb_healed(mob/living/our_mob, obj/item/bodypart/limb, brute, burn)
	SIGNAL_HANDLER
	if (!(limb.biological_state & BIO_OOZE))
		return // We only care about oozey parts
	increment_ooze(brute + burn)

/// If we get fully healed from an effect which usually resets blood level, restore ooze
/obj/item/organ/brain/jelly/proc/on_full_heal(mob/living/our_mob, full_heal_flags)
	SIGNAL_HANDLER
	if (full_heal_flags & HEAL_BLOOD)
		increment_ooze(100 - ooze_amount)



#undef MAX_OOZE
#undef OOZE_AMOUNT_SLUG
#undef OOZE_AMOUNT_BLOATED
#undef OOZE_AMOUNT_NORMAL
#undef OOZE_AMOUNT_DISMEMBER
#undef OOZE_AMOUNT_BLOB
#undef OOZE_NUTRITION_GAIN_MODIFIER
#undef OOZE_TOX_MODIFIER
#undef OOZE_NORMAL_DAMAGE_SIGNALS
