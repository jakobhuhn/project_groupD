#!/bin/bash

echo "###########################################################
Welcome to The Project work of Group D for MNXB01 2019

What would you like to do?

EX1: Average Temperature for a given day from 1961-2014 [1]

EX2: Hottest and coldest Temperature from 1961-2014 [2]

EX3: Compare the Weather with the moon cycle in Lund from 1961-2014 [3]

Exit: Exit the program [4]"


read Option
base=`pwd`
echo ${base}
if [ ${Option} == "1" ]; then

###Exercise 1

	#decide which city
	echo "For what city should this exercise be done?(Please enter just the city name: [City])
	OPTIONS:
	Boras Falsterbo Falun Lulea Lund Karlstad Soderarm Umea Visby"
	read city
	if [[ ${city} != "Lund" && ${city} != "Boras" && ${city} != "Falsterbo" && ${city} != "Falun" && ${city} != "Lulea"
		&& ${city} != "Karlstad" && ${city} != "Soderarm"	&& ${city} != "Umea" && ${city} != "Visby" ]];
	then
		echo "Invalid input"
		exit 1
	fi
	echo "Continuing with ${city}"
	
	#decide Quality

	echo "Do you want to only include high Quality data?[y/n]"
	read qualitychoice
	if [[ ${qualitychoice} == "y" ]];
	then 
		Quality="highQuality"
	elif [[ ${qualitychoice} == "n" ]];
	then
		Quality="allEntries"
	else 
		echo "Invalid Input"
		exit 1
	fi
	
	
	
	#cleanup/prepare data
	
	if [[ ! -f ${base}/data_files/oneDayTemp_${Quality}_${city}.txt ]];
	then
		echo "Prepare the date for ${city}: (this can take a up to 5 minutes):"
		cd ${base}/bash_scripts
		./cleanup.sh ${city} ${Quality}
		cd ${base}
	
	else
		echo "Data file exist already"
	fi
	
	#run corresponding root script
	
	cd ${base}/root_scripts/question${Option}
	echo "Please specify the month [1-12]"
	read month
	#case ${month} in 
	#[1-12]*)
		#echo "so far so good"
		#break
		#;;
	#*)
		#echo "invalid option"
		#exit 1
		#;;
	#esac
	
	#if [[ ${month} != [!1-12] ]] && [ ${month} != 1 ] && [ ${month} != 2 ] && [ ${month} != 12]; then
		#echo "invalid option"
		#exit 1
	#fi
	echo "Please specify the day [1-(30/31)]"
	read day
	#if [[ ${day} != [!1-31] ]]; then
		#echo "score"
	#fi
	#if [[ ${day} != [!1-31] ]] || ([ ${day} == 31 ] && ([ ${month} == 4 ] || [ ${month} == 6 ] || [ ${month} == 8 ] || [ ${month} == 11 ])) || ([ ${month} == 2 ] && [[ ${day} == [!30-31] ]]); then
		#echo "invalid option"
		#exit 1
	#fi
	#echo "you made it"
	#exit 1
	echo "
	#include \"tempTrender.h\"
	#include <string>
	#include <iostream>
	
	void project() {
		string pathToFile = \"../../data_files/oneDayTemp_${Quality}_${city}.txt\"; //Put the path to data file, Southern Sweden
	
	
		tempTrender t(pathToFile); //Instantiate your analysis object
		
		t.tempOnDay(${month}, ${day}); //Call implemented function
		//t.tempOnDay(235);
		//t.tempPerDay();
		//t.hotCold();
		//t.tempPerYear(2050);
		
	}" > project.cpp
	root -b -l <<-EOF
	project()
	.q
	EOF
	output=Q${Option}_${city}_${Quality}_${month}_${day}.jpg
	cd ${base}/pictures
	mv newpicture.jpg ${output}
	xdg-open ${output}
	cd ${base}

elif [ ${Option} -eq "2" ]; then


####Exercise 2

	#decide which city
	echo "For what city should this exercise be done?(Please enter just the city name: [City])
	OPTIONS:
	Boras Falsterbo Falun Lulea Lund Karlstad Soderarm Umea Visby"
	read city
	
	if [[ ${city} != "Lund" && ${city} != "Boras" && ${city} != "Falsterbo" && ${city} != "Falun" && ${city} != "Lulea"
		&& ${city} != "Karlstad" && ${city} != "Soderarm"	&& ${city} != "Umea" && ${city} != "Visby" ]];
	then
		echo "Invalid input"
		exit 1
	fi
	echo "Continuing with ${city}"
	
	#decide Quality
	
	echo "Do you want to only include high Quality data?[y/n]"
	read qualitychoice
	if [[ ${qualitychoice} == "y" ]];
	then 
		Quality="highQuality"
	elif [[ ${qualitychoice} == "n" ]];
	then
		Quality="allEntries"
	else 
		echo "Invalid Input"
		exit 1
	fi

	output=Q${Option}_${city}_${Quality}.jpg
	
	#cleanup/prepare data
	
	if [[ ! -f ${base}/data_files/oneDayTemp_${Quality}_${city}.txt ]]; then
		echo "Prepare the data for ${city}: (this can take a up to 5 minutes):"
		cd ${base}/bash_scripts
		./cleanup.sh ${city} ${Quality}
		cd ${base}
	else
		echo "Data file exist already"
	fi
	cd ${base}/bash_scripts
	./coldestday.sh ${city} ${Quality}
	./hottestday.sh ${city} ${Quality}
	cd ${base}
	#run corresponding root script
	
	cd ${base}/root_scripts/question${Option}
	echo "
	#include \"tempTrender2.h\"
	#include <string>
	#include <iostream>
	
	void project() {
		string pathToFile = \"../../data_files/coldestday_${Quality}_${city}.txt\"; //Put the path to data file, Southern Sweden
		//string pathToFile = \"../../data_files/coldestday_${Quality}_${city}.txt\";
	
		tempTrender t(pathToFile); //Instantiate your analysis object
		
		//t.tempOnDay(12, 24); //Call implemented function
		//t.tempOnDay(235);
		//t.tempPerDay();
		t.hotCold();
		//t.tempPerYear(2050);
	}" > project2.cpp
	
	echo "
	//include C++ STL headers
	#include <iostream>
	#include <fstream>
	
	#include \"TMath.h\"
	
	//own files
	#include \"tempTrender2.h\"
	
	//ROOT library objects
	#include <TH1.h>
	#include <TGraph.h>
	#include <TCanvas.h>
	#include <TMultiGraph.h>
	//using namespace std;
	tempTrender::tempTrender(string filePath) {
		//cout << \"The user supplied \" << filePath << \" as the path to the data file.\" << endl;
		fileToPath=filePath;
	}
	
	//make function to give hist with temp for each year
	void tempTrender::hotCold(){
		
		
		TCanvas *c1 = new TCanvas(\"c1\",\"Extreme temperatures per year\");
		
		//TGraph* graph = new TGraph(\"../../data_files/coldestday_Lund.txt\");
		//TGraph* graph1 = new TGraph(\"../../data_files/hottestday_Lund.txt\");
		TGraph* graph = new TGraph(\"../../data_files/coldestday_${Quality}_${city}.txt\");
		TGraph* graph1 = new TGraph(\"../../data_files/hottestday_${Quality}_${city}.txt\");
		TMultiGraph *mg = new TMultiGraph(); 
		
		graph->SetFillColor(4); //blue
		graph->SetTitle(\"Coldest days\");
		
		graph1->SetFillColor(2); //red
		graph1->SetTitle(\"Hottest days\");
	
		mg -> Add(graph);
		mg -> Add(graph1);
		mg->Draw(\"AB\");
		mg->GetXaxis()->SetTitle(\"Years\");
		mg->GetYaxis()->SetTitle(\"Temperature [#circC]\");
		c1->BuildLegend();
		c1->SaveAs(\"../../pictures/newpicture.jpg\");
		
	}" > tempTrender2.cpp
	
	root -b -l <<-EOF
	project()
	.q
	EOF

	cd ${base}/pictures
	mv newpicture.jpg ${output}
	xdg-open ${output} 
	cd ${base}

elif [ ${Option} == "3" ]; then 

	###Exercise 3
	city="Lund"
	
	#decide Quality
	
	echo "Do you want to only include high Quality data?[y/n]"
	read qualitychoice
	if [[ ${qualitychoice} == "y" ]];
	then 
		Quality="highQuality"
	elif [[ ${qualitychoice} == "n" ]];
	then
		Quality="allEntries"
	else 
		echo "Invalid Input"
		exit 1
	fi
	
	output=Q${Option}_${city}_${Quality}.jpg
	
	#cleanup/prepare data
	
	if [[ ! -f ${base}/data_files/oneDayTemp_${Quality}_${city}.txt ]]; then
		echo "Prepare the date for ${city} (this can take a up to 5 minutes):"
		cd ${base}/bash_scripts
		./cleanup.sh ${city} ${Quality}
		cd ${base}
	else
		echo "Data file exist already"
	fi
	
	#run corresponding root script
	if [[ ! -f ${base}/data_files/moonTemp_${Quality}_${city}.txt ]]; then
		echo "Prepare the file for ${city}: "
		cd ${base}/bash_scripts
		./moonTemp.sh ${city} ${Quality}
		cd ${base}
	else
		echo "Data file exist already"
	fi
	
	cd ${base}/root_scripts/question${Option}
	echo "
	#include \"tempTrender_moon.h\"
	#include <string>
	#include <iostream>
	
	void project() {
		string pathToFile = \"../../data_files/moonTemp_${Quality}_${city}.txt\"; //Put the path to data file, Southern Sweden
		
	
		tempTrender t(pathToFile); //Instantiate your analysis object
		
		//t.tempOnDay(12, 24); //Call implemented function
		t.moonTemp();
		
	}" > project_moon.cpp

	root -b -l <<-EOF
	project()
	.q
	EOF
	
	cd ${base}/pictures
	mv newpicture.jpg ${output}
	xdg-open ${output}
	cd ${base} 
else 
	echo "Invalid Option"
	exit 1
fi
