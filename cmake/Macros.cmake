macro(SHOW_END_MESSAGE what value)
	string(LENGTH ${what} length_what)
	math(EXPR left_char "20 - ${length_what}")
	set(blanks)
	foreach (_i RANGE 1 ${left_char})
		set(blanks "${blanks} ")
	endforeach (_i)

	message ("  ${what}:${blanks} ${value}")
endmacro(SHOW_END_MESSAGE what value)

macro(SHOW_END_MESSAGE_YESNO what enabled)
	if (${enabled})
		set(enabled_string "yes")
	else (${enabled})
		set(enabled_string "no")
	endif (${enabled})

	show_end_message("${what}" "${enabled_string}")
endmacro(SHOW_END_MESSAGE_YESNO what enabled)