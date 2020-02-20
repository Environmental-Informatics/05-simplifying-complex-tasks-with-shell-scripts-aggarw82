#!/bin/bash
# Process StationData and plot the data using gmt 
# Finally convert the pot into multiple image
# formats
# Author: Varun Aggarwal
# Last Update: 02/19/20 

clear
echo "Starting ... "

### Part 1 ###

# Station Data doesn't exist
if [ ! -d StationData/ ]
then
    echo 'Station Directory not found'
    echo
    exit
fi

# copy files to HigherElevation
for file in StationData/*
do
	# check if HigherElevation exists
	if [ ! -d HigherElevation/ ]
	then
		mkdir HigherElevation
	fi

	# check altitude of each station
	alt=`awk '/Altitude/ { print $NF }' $file`
	if (( $(echo "$alt > 200" |bc -l) ))
	then
		fileName=`basename $file`
		cp $file HigherElevation/$fileName
	fi
done

echo "HigherElevation Stations selected"
echo "PART 1 - Complete"
echo

### Part 2 ###

# extract longitude and latitude from StationData
awk '/Latitude/ {print 1 * $NF}' StationData/Station_*.txt > Lat.list
awk '/Longitude/ {print -1 * $NF}' StationData/Station_*.txt > Long.list
paste Long.list Lat.list > AllStations.xy

# extract longitude and latitude from HigherElevation
awk '/Latitude/ {print 1 * $NF}' HigherElevation/Station_*.txt > Lat.list
awk '/Longitude/ {print -1 * $NF}' HigherElevation/Station_*.txt > Long.list
paste Long.list Lat.list >  HEStations.xy

# clean up
rm Lat.list Long.list

# load module
module load gmt

# draw map
gmt pscoast -JU16/4i -R-93/-86/36/43 -Dh -B2f0.5 -Ia/blue -Na/orange -Cl/blue -P -K -V -W > SoilMoistureStations.ps
gmt psxy AllStations.xy -J -R -Sc0.15 -Gblack -K -O -V >> SoilMoistureStations.ps
gmt psxy HEStations.xy -J -R -Sc0.10 -Gred -O -V >> SoilMoistureStations.ps

echo
echo "Map Generation complete"
echo "PART 2 - Complete"
echo

### Part 3 ###


echo "Start Image conversion. This may take a few minutes .... "

# convert ps to epsi
ps2epsi SoilMoistureStations.ps > SoilMoistureStations.epsi

# convert epsi to TIFF
convert -density 150 -units PixelsPerInch SoilMoistureStations.epsi SoilMoistureStations.tiff

echo "Image conversion done"
echo "PART 3 - Complete"
echo
