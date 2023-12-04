#!/bin/bash
########################################################################################################################
# File      : SearchCar.sh
# Purpose   : provide basic info based on a license plate
#
# requires  : internet connection
#           : basename, dirname, sed, tr, curl, bc
#           : jq (Jason Query)
#######################################################################################################################

# Check dependicies

# Check for input
zoek=""
if [ $# -eq 0 ]; then
    # No input provided
    base=$(basename $0)
    echo ""
    echo "${base##*/} <nl license plate>"
    echo ""
    exit 1
else
    zoek="$1"
    zoek=$(echo $zoek | sed 's/ //g' | sed 's/-//g' | tr '[:lower:]' '[:upper:]')
fi

#######################################################################################################################
# api url
urlBase="https://opendata.rdw.nl/resource/m9d7-ebf2.json?kenteken="
urlFule="https://opendata.rdw.nl/resource/8ys7-d773.json?kenteken="

# add licencePlate to url
urlSearchBase=$urlBase$zoek
urlSearchFule=$urlFule$zoek

#######################################################################################################################
# Get info from url
echo ""
echo "Searching for: $zoek "
echo

#######################################################################################################################
# Get base info, save in tmp files
# if file exists, then skip download, refresh once per month
datum=$(date +%Y%m)

realScript="$(readlink "$0")"
realPath=$(dirname "$realScript")
tmpFile1="$realPath/$zoek.$datum.1.json"
tmpFile2="$realPath/$zoek.$datum.2.json"

#echo "dirname : `dirname "$0"`"
#echo "realScript : $realScript"
#echo "realPath : $realPath"
#echo "tmpFile1 : $tmpFile1"
#echo "tmpFile2 : $tmpFile2"
#exit 255
#######################################################################################################################
# Lets gets the required data
if [ ! -f "$tmpFile1" ]; then
    # new files of current year/month not found, remove the old files, just in case
    if [ -f "$realPath/$zoek"*.json ]; then
        rm "$realPath/$zoek"*.json
    fi
    curl -s -N -o "$tmpFile1" "$urlSearchBase"
    if [ ! $? -eq 0 ]; then
        echo "Something went wrong fetching base info from..."
        echo $urlSearchBase
        exit 2
    fi
fi
if [ ! -f "$tmpFile2" ]; then
    curl -s -N -o "$tmpFile2" "$urlSearchFule"
    if [ ! $? -eq 0 ]; then
        echo "Something went wrong fetching fule info from..."
        echo $urlSearchFule
        exit 3
    fi
fi

#######################################################################################################################
# tmpFile exists, lets process it -  | sed 's/\"//g'
inhoud=$(jq ".[0].cilinderinhoud" "$tmpFile1" | sed 's/\"//g')
merk=$(jq ".[0].merk" "$tmpFile1" | sed 's/\"//g')
model=$(jq ".[0].handelsbenaming" "$tmpFile1" | sed 's/\"//g')
soort=$(jq ".[0].inrichting" "$tmpFile1" | sed 's/\"//g')
toelating1=$(jq ".[0].datum_eerste_toelating" "$tmpFile1" | sed 's/\"//g')
apk=$(jq ".[0].vervaldatum_apk" "$tmpFile1" | sed 's/\"//g')
kleur=$(jq ".[0].eerste_kleur" "$tmpFile1" | sed 's/\"//g')
tenaamstelling=$(jq ".[0].datum_tenaamstelling" "$tmpFile1" | sed 's/\"//g')
cilinders=$(jq ".[0].aantal_cilinders" "$tmpFile1" | sed 's/\"//g')
power=$(jq ".[1].nettomaximumvermogen" "$tmpFile2" | sed 's/\"//g' | sed 's/\.00//g')
brandstof=$(jq ".[0].brandstof_omschrijving" "$tmpFile2" | sed 's/\"//g')
voertuigsoort=$(jq ".[0].voertuigsoort" "$tmpFile1" | sed 's/\"//g')
# calculate HP from kW
hp=$(bc <<<$power*1.34 | sed 's/\..*//g')

if [ "$soort" == "Niet geregistreerd" ]; then
    soort=", "
else
    soort=" $soort, "
fi
if [ "$apk" == "null" ]; then apk="n.v.t."; fi

#######################################################################################################################
echo "Voertuig       : $voertuigsoort, $merk $model$soort $kleur, $cilinders cilinders, $brandstof $inhoud cc, $power kW ($hp pk)"
echo "Toegelaten     : $toelating1"
echo "Tenaam steling : $tenaamstelling"
echo "APK datum      : $apk"
#######################################################################################################################
echo ""
echo "Done..."
echo ""
