function GM:PlayerCanHearPlayersVoice(ply, rec)   
	if ( !ply:Alive() ) and ( !rec:Alive() ) then -- If they are both dead they can hear each other.
		return true
	elseif ( ply:Alive() ) and ( rec:Alive() ) then	-- If they are both alive they can hear each other.
		return true
	else -- If they are not either both alive or dead then they can't hear each other.
		return false
	end
end