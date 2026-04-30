/// Actions that you can use to dash (teleport) to places in view.
/datum/action/cooldown/item_dash
	name = "Dash"
	desc = "Teleport to the target location. Click to toggle whether you teleport on click."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "jetboot"
	cooldown_time = 0.5 SECONDS
	/// How many dash charges do we have?
	var/current_charges = 1
	/// How many dash charges can we hold?
	var/max_charges = 1
	/// How long does it take to get a dash charge back?
	var/charge_rate = 25 SECONDS
	/// What sound do we play on dash?
	var/dash_sound = 'sound/effects/magic/blink.ogg'
	/// What sound do we play on recharge?
	var/recharge_sound = 'sound/effects/magic/charge.ogg'
	/// What effect does our beam use?
	var/beam_effect = "blur"
	/// How long does our beam last?
	var/beam_length = 2 SECONDS
	/// What effect should we play when we phase in (at the teleport target turf)
	var/phasein = /obj/effect/temp_visual/dir_setting/ninja/phase
	/// What effect should we play when we phase out (at the source turf)
	var/phaseout = /obj/effect/temp_visual/dir_setting/ninja/phase/out
	/// When will we get our next charge?
	var/next_charge_time

/datum/action/cooldown/item_dash/IsAvailable(feedback = FALSE)
	. = ..()
	if (!.)
		return FALSE
	if (current_charges <= 0)
		if (feedback)
			owner.balloon_alert(owner, "no charges!")
		return FALSE
	return TRUE

/datum/action/cooldown/item_dash/Trigger(mob/clicker, trigger_flags, atom/target)
	var/obj/item/dashing_item = src.target // The thing we're attached to, not to be confused with ability target
	if(istype(dashing_item))
		dashing_item.attack_self(owner) // This is kind of stupid but we actually just want to use the item in-hand when you click on the button
		return FALSE
	return ..()

/// Teleports user to target using do_teleport. Returns TRUE if teleport successful, FALSE otherwise.
/datum/action/cooldown/item_dash/proc/teleport(mob/user, atom/target)
	if(!IsAvailable(feedback = TRUE))
		return FALSE

	var/turf/current_turf = get_turf(user)
	var/turf/target_turf = get_turf(target)
	if(!(target in view(user.client.view, user)))
		user.balloon_alert(user, "out of view!")
		return FALSE
	if(target_turf.is_blocked_turf_ignore_climbable())
		user.balloon_alert(user, "destination blocked!")
		return FALSE
	if(!do_teleport(user, target_turf, no_effects = TRUE))
		user.balloon_alert(user, "dash blocked!")
		return FALSE

	// Note: It's possible do_teleport, for whatever reason,
	// caused our owner to be unassigned by this point.
	// (Such as dropping our item after landing.)

	var/obj/spot_one = new phaseout(current_turf, user.dir)
	var/obj/spot_two = new phasein(target_turf, user.dir)
	spot_one.Beam(spot_two, beam_effect, time = beam_length)
	playsound(target_turf, dash_sound, 25, TRUE)

	if (current_charges == max_charges)
		next_charge_time = world.time + charge_rate

	current_charges--
	addtimer(CALLBACK(src, PROC_REF(charge)), charge_rate)
	owner?.update_mob_action_buttons()
	SEND_SIGNAL(src, COMSIG_DASH_ACTION_DASHED)

	if (current_charges > 0)
		StartCooldown()
	else
		StartCooldown(next_charge_time - world.time)

	return TRUE

/// Callback for [/proc/teleport] to increment our charges after  use.
/datum/action/cooldown/item_dash/proc/charge()
	current_charges = clamp(current_charges + 1, 0, max_charges)
	SEND_SIGNAL(src, COMSIG_DASH_ACTION_CHARGED)
	StartCooldown(0)

	var/obj/item/dashing_item = target
	if(!istype(dashing_item))
		return

	if(recharge_sound)
		playsound(dashing_item, recharge_sound, 50, TRUE)

	if(!owner)
		return
	owner.update_mob_action_buttons()
	if (max_charges > 1)
		dashing_item.balloon_alert(owner, "[current_charges]/[max_charges] dash charges")
