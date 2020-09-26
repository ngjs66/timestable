#!/usr/bin/env bash

create_file()
{
	if [ ! -f "$1" ]; then
		touch $1
	fi
	> $1 # clear the contents of the file
}

write_to_array() {
  MYARRAY[${1},${2}]=$3
}

write_to_file() {
  for ((i=0; i<$2; i++))
  do
    for((j=0; j<6; j++))
    do
      echo -ne "${MYARRAY[${i},${j}]}\t" >> $1
    done
    echo >> $1
  done
}

# Core logic
operation () {
  local in=true

	while [ "$in" = true ]
	do
		echo "Please enter a number between 1 and 20"
		read number

		if [[ "$number" -lt 1 || "$number" -gt 20 ]]
		then
			echo "Oops! Please enter a number between 1 and 20"
		else # Core logic inside this else
			echo "You selected: $number"

			if [ "$2" = "quiz" ]
			then
				life=3
				score=0
				consecutive=0
				declare -A MYARRAY # The -A option requires bash 4.0 and above

				date=$(date '+%Y-%m-%d-%T')
				file_rand=$((1 + $RANDOM % 999))
				filename=$user_name-$date-$file_rand.txt
				echo "Creating results file: $filename"
				create_file $filename

				echo -e "\nHello $user_name! Remaining lives: $life. Goodluck!\n"
			fi

			for i in {0..12}
			do
				case $1 in
					add)
						question=""$number" + "$i""
						echo "What is "$question"?"
						read user_ans
						real_ans=$((number + i))
						;;
					subt)
						question="$(($number + $i)) - $number"
						echo "What is "$question"?"
						read user_ans
						real_ans=$(((number + i) - number))
						;;
					mult)
						question=""$number" x "$i""
						echo "What is "$question"?"
						read user_ans
						real_ans=$((number * i))
						;;
					div)
						if [[ "$i" == 0 ]]; then continue; fi
						question="$(($number * $i)) / $number"
						echo "What is "$question"?"
						read user_ans
						real_ans=$(((number * i) / $number))
						;;
				esac

				if [[ "$user_ans" -lt "$real_ans" ]]
				then
				  echo "Wrong answer!"
					if [ "$2" = "quiz" ]
					then
						((life--))
						consecutive=0
						echo "The correct answer is $real_ans. Remaining lives: $life"
					else
						echo "The correct answer is higher than $user_ans"
					fi
				elif [[ "$user_ans" -gt "$real_ans" ]]
				then
				  echo "Wrong answer!"
					if [ "$2" = "quiz" ]
					then
						((life--))
						consecutive=0
						echo "The correct answer is $real_ans. Remaining lives: $life"
					else
						echo "The correct answer is lower than $user_ans"
					fi
				else
					if [ "$2" = "quiz" ]
					then
						((score++))
						((consecutive++))
					else
						echo "Congratulations! Your answer is correct"
					fi
				fi
				
				if [ "$2" = "quiz" ]
				then
					if [[ $((consecutive % 3)) == 0 && "$consecutive" -gt 0 ]]
					then
						((life++))
						echo "Awarded 1 life! Remaining lives: $life"
					elif [ "$life" == 0 ]
					then
						echo -e "\nRemaining lives: $life. Quiz over! :(\n"
						break
					fi
					tokens=( $question )
					write_to_array $i 0 ${tokens[0]}
					write_to_array $i 1 ${tokens[1]}
					write_to_array $i 2 ${tokens[2]}
					write_to_array $i 3 $real_ans
					write_to_array $i 4 $user_ans
					write_to_array $i 5 $score
				fi

			done # loop through 0..12 numbers

      # If quiz, print results and write array to file
			if [ "$2" = "quiz" ]
			then
				echo -e "**** Quiz Results ****\n"
				echo "$user_name, you got $score correct answers out of 12"
				echo "See $filename for your tab delimited results, organised as such:"
				echo -e "\nn|operand|n|correct_answer|your_answer|cumulative_score\n"
				echo -e "*********************\n"

				write_to_file $filename $i
			fi

			in=false # operation completed correctly

		fi # if..else (Chosen number between 0..12)

	done # while in == true
}

# Practice option
option_1 () {
	echo "Please select an option:"
	echo "  1) Addition"
	echo "  2) Subtraction"
	echo "  3) Multiplication"
	echo "  4) Division"
	echo ""
	echo "  0) Return to main menu"
	
	read opt1_input

	case $opt1_input in
		1)
			echo "Addition selected"
			operation add
			;;
		2)
			echo "Subtraction selected"
			operation subt
			;;
		3)
			echo "Multiplication selected"
			operation mult
			;;
		4)
			echo "Division selected"
			operation div
			;;
		0)
			echo "Returning to main menu"
			;;
		*)
			echo "Error: Invalid option selected. Please select from options displayed."
			;;
	esac
}

# Quiz option
option_2 () {
	echo "Please select an option:"
	echo "  1) Begin quiz"
	echo ""
	echo "  0) Return to main menu"
	
	read opt2_input

	case $opt2_input in
		1)
			echo "Please enter your first name:"
			read user_name
			random_quiz=$((1 + $RANDOM % 4))

			case $random_quiz in
				1)
					echo "Addition selected"
					operation add quiz
					;;
				2)
					echo "Subtraction selected"
					operation subt quiz
					;;
				3)
					echo "Multiplication selected"
					operation mult quiz
					;;
				4)
					echo "Division selected"
					operation div quiz
					;;
			esac

			;;
		0)
			echo "Returning to main menu"
			;;
		*)
			echo "Error: Invalid option selected. Please select from options displayed."
			;;
	esac
}

# Main loop
while true
do
	echo "**** Arithmetic Learning Assignment ****"
	echo "  1) Learn your 12 times tables"
	echo "  2) Take the Tables Quiz"
	echo "  3) Quit the Program"

	read main_input
	case $main_input in
		1)
			echo "**** Option 1: Learn 12 Times Tables ***"
			option_1
			;;
		2)
			echo "**** Option 2: Tables Quiz ***"
			option_2
			;;
		3)
			echo "Thank you! Program exiting..."
			exit 0
			;;
		*)
			echo "Error: Invalid option selected. Please select from options displayed."
			;;
	esac
done
