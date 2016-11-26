#!/bin/bash

: '
Shell script that acts as a music player and performs various operations such as playing songs, 
downloading youtube videos, combining mp3 files, creating and managing playlists and conversions
between various file formats
Uses youtube-dl, ffmpeg, mp3wrap and libid3
 '

download_video()
{
	echo "Enter the link of the video"
	echo
	echo -n "-> "
	read vidlink 
	echo "What would you like to name the file?"
	read songname
	youtube-dl -o $songname $vidlink
	clear
	echo -n "Your file has been downloaded at "
	echo -n "`pwd`"
	echo -n " as "
	ls | grep "$songname" 
}

 

convert_video()
{
	clear
	display_files
	echo
	echo "Enter the file name (with file extension)"
	echo
	echo -n "-> "
	read name
	echo
	echo "Enter required file format (mp3/mp4/wav/avi/wma)"
	echo
	echo -n "-> "
	read format
	namelen=`expr lenth $name`
	b=${name::namelen-4}
	avconv -i "$name" -c:a libmp3lame "$b"."$form"
	clear
	echo "File converted"
}
		
play_video()
{
	clear
	echo "Do you wish to play from a playlist, or individual songs? (p/i)"
	echo
	echo -n "-> "
	read ans
	if [ $ans = 'i' ]
		then
			echo "Enter the name of the file that you wish to play "
			echo
			display_files
			echo
			echo -n "-> "	
			read nameoffile 
			ffplay "$nameoffile"
			sleep 50
	elif [ $ans = 'p' ]
		then
			echo "Enter the name of the playlist"
	
			ls ./Playlists
			echo
			echo -n "-> "
			read name
			cd Playlists
			n=`awk '{}END{print NR}' "$name".txt`
			cat "$name".txt >> temp.txt
			mv temp.txt ..

			cd ..
			echo
			echo "Shuffle or normal? (s/n)"
			echo
			echo -n "-> "
			read ans_shuff
			if  [ $ans_shuff = 'n' ]
				then
		
					for i in `seq 1 $n` 
					do
						
						ffplay -autoexit `sed "$i!d" temp.txt`
					done
					rm temp.txt
				else
				
					clear
					for j in `seq 1 $n`
						do
							i=$((( RANDOM % $n) + 1 ))
							ffplay -autoexit `sed "$i!d" temp.txt`
							clear
						done
						rm temp.txt
			


			fi	
		
	else
		 echo "invalid option"
		 sleep 4
		 play_video		 
	
	fi
}

combine_mp3()
{ 
	echo "What would you like to name the combined file?"
	echo
	echo -n "-> "
	read com_name
	echo
	echo "Enter the number of songs you wish to combine:"
	echo
	echo -n "-> "
	read num_of_songs
	assert=`expr $num_of_songs % 2`
	counter=0
	first_song=1
	flag1=0
	if [ $assert -eq 0 ]
		then
			while [ $counter -lt $num_of_songs ]
			do
				flag=0
				counter2=0
				while [ $counter2 -lt 2 ]
				do
					clear
					display_files
					echo
					echo "Enter the song name: "
					echo
					echo -n "-> "
					if [ $first_song -eq 1 ]
						then
						read song_1
						first_song=`expr $first_song + 1`
					elif [ $flag -eq 0 -a $first_song -gt 2 ]
						then
						read song_name1
						flag=`expr $flag + 1`
					else
						read song_name
						first_song=`expr $first_song + 1`
					fi
					counter2=`expr $counter2 + 1`
				done 
			if [ $counter -eq 0 ]
				then
					mp3wrap tmp.mp3 "$song_1" "$song_name"
					clear
				else
					mp3wrap -a tmp_MP3WRAP.mp3 "$song_name1" "$song_name"
					clear

			fi
			counter=`expr $counter + 2`
			done
	else
		clear
		display_files
		echo
		echo "Enter the song: "
		echo
		echo -n "-> "
		read song_1
		echo
		echo "Enter the song:"
		echo
		echo -n "-> "
		read song_name1
		echo
		echo "Enter the song:"
		echo
		echo -n "-> "
		read song_name
		mp3wrap tmp.mp3 "$song_1" "$song_name1" "$song_name"
		clear
		counter3=3
		if [ $num_of_songs > 3 ]			
			then
				while [ $counter3 -lt $num_of_songs ]
				do
					counter2=0
					while [ $counter2 -lt 2 ]
					do
						echo
						echo "Enter the song:"
						echo
						echo -n "-> "
						if [ $first_song -eq 1 ]
							then
							read song_name1
							first_song=`expr $first_song + 1`
					
						else
							read song_name
							first_song=`expr $first_song + 1`
						fi
					counter2=`expr $counter2 + 1`
					done 
			
				mp3wrap -a tmp_MP3WRAP.mp3 "$song_name1" "$song_name"
				clear
				counter3=`expr $counter3 + 2`
				done
        fi
    fi

	ffmpeg -i tmp_MP3WRAP.mp3 -acodec copy "$com_name".mp3 && rm tmp_MP3WRAP.mp3
    id3cp "$song_1" all.mp3
}

playlist_ops()
{
	clear
	echo "Do you wish to create a new playlist or access an existing playlist? (c/m)"
	echo
	echo -n "-> "
	read answer 
	file="Playlists"

	if [ ! -e "$file" ] ; then
    	mkdir "$file"
	fi
	if [ $answer = 'c' ]
		then
			echo "What would you like to name your playlist as?"
			echo
			echo -n "-> "
			read play_name
			clear
			flag1=0
			
			while [ $flag1 -eq 0 ]
			do
				echo "Displaying all songs in the present folder, please enter the name of the song you wish to add to the playlist (with extension)"
				echo
				display_files
				echo
				echo -n "-> "
				read add_play
				cd Playlists
				echo "$add_play" >> "$play_name".txt
				cd ..
				clear
				echo "Song added! Do you wish to add another song? (y/n)"
				echo
				echo -n "-> "
				read ans
				if [ $ans = 'y' ]
					then continue
				else
					flag1=`expr $flag1 + 1`
				fi
			done
		else
			echo "Available Playlists: "
			echo
			ls Playlists
			echo
			echo "Enter the name of the playlist you wish to modify"
			echo
			echo -n "-> "
			read play_mod
			clear
			echo "This is the present playlist: "
			echo
			cd Playlists
			cat "$play_mod".txt
			flag2=0
			while [ $flag2 -eq 0 ]
			do 
				echo
				echo "Do you wish to delete or add a song? (d/a)"
				echo
				echo "-> "
				read ans_mod
				if [ $ans_mod = 'd' ]
					then
						clear
						echo "Enter the song you wish to delete"
						echo
						echo -n "-> "
			
						cat "$play_mod".txt
						read song_del
						sed -i "/$song_del/d" "$play_mod.txt"
						echo	
						echo "Do you wish to add or delete a song? (y/n)"
						echo
						echo -n "-> "
                        read ans_repeat
                        if [ $ans_repeat = 'y' ]
							then continue
						else
							flag2=`expr $flag2 + 1`
							cd ..
						fi
				
				else
						clear
						echo "Enter the name of the song you wish to add (with extension)"
						echo
						cd ..
						display_files
                        echo
                        echo -n "-> "
                        read song_add
                        cd Playlists
                        echo "$song_add" >> "$play_mod".txt
 
                        echo "Do you wish to perform another operation? (y/n)"
                        echo
                        echo -n "-> "
                        read ans_repeat
                        if [ $ans_repeat = 'y' ]
							then continue
						else
							flag2=`expr $flag2 + 1`
							cd ..
						fi
				fi
						
			done
	fi		
}

display_files()
{
	echo "Available files: "
	echo
	ls | grep -n ".mkv\|.mp3\|.mp4\|.wav\|.webm\|.avi" 
#	ls | grep ".mp3" 
#	ls | grep ".mp4" 
#	ls | grep ".wav"
#	ls | grep ".webm" 
#	ls | grep ".avi"   
}


clear
echo "/\/\ /-\ |)"
echo
echo "What do you wish to do?"

echo
a=1
while [ $a -eq 1 ]
do

echo "(a) Download a youtube video"
echo "(b) Convert file formats"
echo "(c) Play music and videos"
echo "(d) Combine mp3 files"
echo "(e) Create and modify Playlists"
echo "(f) Exit"
echo
echo -n "-> "
read n

case $n in 
	a) download_video ;;
	b) convert_video ;;
	c) play_video ;;
	d) combine_mp3 ;;
	e) playlist_ops ;;
	f) exit ;;
	*) echo "Invalid option. Please choose again"
		continue ;;
esac

clear
echo "Do you wish to return to the mainmenu?(y/n)"
echo
echo -n "-> "
read ans
if [ $ans = 'n' ]
	then 
	a=`expr $a + 1`
fi
done
