/// Numerical indicator for how much jelly ooze you've got
/atom/movable/screen/jelly_ooze
	icon = 'icons/hud/screen_changeling.dmi'
	icon_state = "power_display"
	name = "nutrition"
	screen_loc = ui_jellyoozedisplay

/atom/movable/screen/jelly_ooze/proc/update_display(new_value)
	maptext = ("<div align='center' valign='middle' style='position:relative; top:0px; right:12px'><font color='#dd66dd'>[round(new_value, 1)]%</font></div>")
