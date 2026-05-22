/// Like a dream but bad and you don't like it
/datum/dream/nightmare
	weight = 1000000 // Not very likely without a little push
	sleep_until_finished = TRUE

/datum/dream/nightmare/GenerateDream(mob/living/carbon/dreamer)
	. = list()
	. += span_warning("you are struck by a terrible sense of [pick("apprehension", "anxiety", "dread", "nervousness", "paranoia", "trepidation", "unease")]")

	var/list/nightmares = list(
		list(
			"a siren jolts you out of bed, the emergency lights are blinking red",
			"Destruction of the station is imminent. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill.",
			"you feel a moment of searing pain as everything goes white"
		),
		list(
			"it's time to get up for work! you drag yourself out of bed, feeling oddly sluggish, and make your way to the door",
			"it's time to get up for work! you drag yourself out of bed, feeling oddly sluggish, and make your way to the door",
			"it's time to get up for work! you drag yourself out of bed, feeling oddly sluggish, and make your way to the door",
			"it's time to get up for work! you drag yourself out of bed, feeling oddly sluggish, and make your way to the door",
			"it's time to get up for work! you drag yourself out of bed, feeling oddly sluggish, and make your way to the door",
		),
		list("there is something sitting on your chest", "you strain and heave but you can't move a muscle", "slowly it begins to reach towards your face"),
		list("you are falling from a great height", "the wind screams past, there is nothing to slow you down", "you are about to hit the ground"),
		list("you are in a maze of twisting passages, all alike", "distantly, there is the sound of panting breath", "you cannot find the way out"),
		list("you are looking in the mirror", "your reflection points behind you", "you can't bring yourself to turn around"),
		list("you are tied to a bed, unable to move", "rats begin to creep out of the darkness, their teeth gleaming", "soon there will be nothing left of you"),
		list("you are walking the halls of an unfamiliar station", "it is dark, silent, and nobody responds to your calls", "you know you are not alone"),
	)

	var/obj/item/bodypart/head/head = dreamer.get_bodypart(BODY_ZONE_HEAD)
	if (head?.teeth_count > 0)
		nightmares += list(list(
			"you feel a sudden pain in your jaw",
			"you spit [dreamer.usable_hands > 0 ? "into your palm" : "onto the ground"] and a tooth falls out",
			"more and more teeth pour from your open mouth"
		))

	if (!HAS_TRAIT(dreamer, TRAIT_NODROWN) && !HAS_TRAIT(dreamer, TRAIT_NOBREATH))
		nightmares += list(list(
			"you are deep under the ocean, too far for light to reach",
			"something is dragging you deeper, you cannot pull yourself to the surface",
			"your breath slips away and the sea rushes in"
		))

	if (!HAS_TRAIT(dreamer, TRAIT_RESISTLOWPRESSURE) && !HAS_TRAIT(dreamer, TRAIT_NOBREATH) && !HAS_TRAIT(dreamer, TRAIT_RESISTCOLD))
		nightmares += list(list(
			"you are floating suitless in the void",
			"on the other side of a glass various people go about their day, ignoring you completely",
			"you open your mouth to scream, but the hungry stars swallow your breath"
		))

	var/list/species_nightmares = dreamer.dna?.species?.nightmares
	if (length(species_nightmares))
		nightmares += species_nightmares

	var/list/picked_nightmare = pick(nightmares)

	for (var/part in picked_nightmare)
		. += CALLBACK(src, PROC_REF(fret), part)

	. += span_warning("the [pick("dreadful", "haunting", "horrible")] images fade away, leaving you with a deep feeling of [pick("disquiet", "malaise", "nausea")]")
	. += span_notice("you settle back into quieter rest")

/datum/dream/nightmare/OnDreamEnd(mob/living/carbon/dreamer)
	. = ..()
	dreamer.add_mood_event("bad_dream", /datum/mood_event/bad_dream)

/// Sleep visibly badly
/datum/dream/nightmare/proc/fret(message, mob/living/carbon/dreamer)
	if (prob(40))
		dreamer.emote(pick("gaspshock", "groan", "grimace", "scream", "shiver", "tremble", "twitch", "twitch_s", "whimper"), forced = TRUE)
	return span_warning(message)

/datum/mood_event/bad_dream
	description = "I didn't sleep very well."
	mood_change = -2
	timeout = 5 MINUTES
