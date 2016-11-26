#!/bin/bash

download_video()
{
	echo "Enter the link of the video"
	read vidlink 
	echo "What would you like to name the file?"
	read songname
	youtube-dl -o $songname $vidlink
	clear
	echo -n "Your file has been downloaded at "
	echo "`pwd`"
	ls | grep "$songname" 

}

 

convert_video()
{
	clear
	display_files
	echo "Enter the file name (with file extension)"
	read name
	echo "Enter required file format (mp3/mp4/wav/avi/wma)"
	read form
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
	read ans
	if [ $ans = 'i' ]
		then
			echo "Enter the name of the file that you wish to play "
			echo
			display_files	
			read nameoffile 
			ffplay "$nameoffile"
		else
			echo "Enter the name of the playlist"
	
			ls ./Playlists
			read name
			cd Playlists
			n=`awk '{}END{print NR}' "$name".txt`
			cat "$name".txt >> temp.txt
			mv temp.txt ..

			cd ..
			
			echo "Shuffle or normal? (s/n)"
			read ans_shuff
			if  [ $ans_shuff = 'n' ]
				then
		
					for i in `seq 1 $n` 
					do
						echo `pwd`
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
		 
	fi
}

combine_mp3()
{ 
	clear
	echo "Enter the number of songs you wish to combine"
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
					echo "Enter the song"
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
		echo "Enter the song"
		read song_1
		echo
		echo "Enter the song"
		read song_name1
		echo "Enter the song"
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
						echo "Enter the song"
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

	ffmpeg -i tmp_MP3WRAP.mp3 -acodec copy all.mp3 && rm tmp_MP3WRAP.mp3
    id3cp "$song_1" all.mp3
    

}

playlist_ops()
{
	
	echo "Do you wish to create a new playlist or access an existing playlist? (c/m)"
	read answer 
	file="Playlists"

	if [ ! -e "$file" ] ; then
    	mkdir "$file"
	fi
	if [ $answer = 'c' ]
		then
			echo "What would you like to name your playlist as?"
			read play_name
			clear
			flag1=0
			
			while [ $flag1 -eq 0 ]
			do
				echo "Displaying all songs in the present folder, please enter the name of the song you wish to add to the playlist (with extension)"
				echo
				display_files

				read add_play
				cd Playlists
				echo "$add_play" >> "$play_name".txt
				cd ..
				clear
				echo "Song added! Do you wish to add another song? (y/n)"
				read ans
				if [ $ans = 'y' ]
					then continue
				else
					flag1=`expr $flag1 + 1`
				fi
			done
		else
			ls Playlists
			echo
			echo "Enter the name of the playlist you wish to modify"
			read play_mod
			echo "This is the present playlist"
			cd Playlists
			cat -n "$play_mod".txt
			flag2=0
			while [ $flag2 -eq 0 ]
			do 
				echo "Do you wish to delete or add a song? (d/a)"
				read ans_mod
				if [ $ans_mod = 'd' ]
					then
						clear
						echo "Enter the song you wish to delete"
			
						cat "$play_mod".txt
						read song_del
						sed -i "/$song_del/d" "$play_mod.txt"
						
						echo "Do you wish to perform another operation? (y/n)"
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
                        
                        read song_add
                        cd Playlists
                        echo "$song_add" >> "$play_mod".txt
 
                        echo "Do you wish to perform another operation? (y/n)"
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
	ls | grep ".mkv" 
	ls | grep ".mp3" 
	ls | grep ".mp4" 
	ls | grep ".wav"
	ls | grep ".webm" 
	ls | grep ".avi"
}


clear
echo "ABCDE Music player"
echo "What do you wish to do?"
a=1
while [ $a -eq 1 ]
do

echo "(a) Download a video"
echo "(b) Convert file formats"
echo "(c) Play music and videos"
echo "(d) Combine"
echo "(e) Create and modify Playlists"
read n

case $n in 
	a) download_video ;; 
	b) convert_video ;;
	c) play_video ;;
	d) combine_mp3 ;;
	e) playlist_ops ;;
esac
sleep 4
clear
echo "Do you wish to do anything else?(y/n)"
read ans
if [ $ans = 'n' ]
	then 
	a=`expr $a + 1`
fi
done
