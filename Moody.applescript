-- Global variables
global track_name
global track_artist
global track
global old_mood
global changed
global spotify_up
global state

-- Polling interval
property polling_interval : 10

-- Function to check if an application is running
on isRunning(appName)
	tell application "System Events" to (name of processes) contains appName
end isRunning

-- Init
on run
	set changed to false
	set track_name to missing value
	set track_artist to missing value
	
	-- Check if Spotify and Skype are running
	if isRunning("Skype") then
		-- Try to get old mood message from Skype
		tell application "Skype"
			set temp_mood to send command "GET PROFILE MOOD_TEXT" script name "Moody"
			set AppleScript's text item delimiters to "TEXT "
			set old_mood to text item 2 of temp_mood
		end tell
	end if
	
	idle
end run

-- Infinite Loop One
on idle
	-- Check if Spotify and Skype are running
	if isRunning("Skype") then
		if isRunning("Spotify") then
			-- Get track from Spotify. try because sometimes Spotify returns unexpected data
			tell application "Spotify"
				-- Check if track has changed
				if player state is not stopped and class of current track is track then
					if track_name is not name of current track or track_artist is not artist of current track then
						set changed to true
						set track_name to name of current track
						set track_artist to artist of current track
					else
						set changed to false
					end if
				-- If it is stopped, put back the original mood message
				else
					tell application "Skype"
						send command "SET PROFILE MOOD_TEXT " & old_mood script name "Moody"
					end tell
				end if
			end tell
			
			-- Send new mood message to Skype if the track has changed
			if changed then
				set track to "(music) " & track_artist & " - " & track_name
				tell application "Skype"
					send command "SET PROFILE MOOD_TEXT " & track script name "Moody"
				end tell
			end if
			set spotify_up to true
			
		-- If Spotify was just quit, put back the original mood message	
		else if spotify_up then
			tell application "Skype"
				send command "SET PROFILE MOOD_TEXT " & old_mood script name "Moody"
			end tell
			set changed to false
			set spotify_up to false
		end if
	end if
	return polling_interval
end idle

-- Install exit handler
on quit
	-- Try to restore mood message upon exit
	if isRunning("Skype") then
		tell application "Skype"
			send command "SET PROFILE MOOD_TEXT " & old_mood script name "Moody"
		end tell
	end if
	continue quit
end quit