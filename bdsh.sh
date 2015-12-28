#!/bin/sh
## bdsh.sh for  in /home/single_j//projets/bdsh
## 
## Made by julien singler
## Login   <single_j@epitech.net>
## 
## Started on  Thu Jan 27 16:42:25 2011 julien singler
## Last update Sun Jan 30 12:32:01 2011 julien singler
##

LANG=C
## SELECT FUNCTION

sel()
{
    if [ $# -eq 1 ]
    then
	arg1=$(echo "$1" | sed 's@\\\\@\\\\\\\\@g' | sed 's@=@{{{{{}}}}}@g' | sed 's@-n@tiretn@g' | sed 's@-v@tiretv@g')
	if [ $aff_key -eq 1 ]
	then
	    cat $filename | grep -e "$arg1.*=" | sed 's@\\\\@\\@g' | sed 's@{{{{{}}}}}@=@g' | sed 's@tiretn@-n@g' | sed 's@tiretv@-v@g'
	else
	    cat $filename | grep -e "$arg1.*=" | sed 's@\\\\@\\@g' | sed 's@.*=@@' | sed 's@{{{{{}}}}}@=@g'| sed 's@tiretn@-n@g'| sed 's@tiretv@-v@g'
	fi
    else
	if [ $aff_key -eq 1 ]
	then
	    cat $filename | sed 's@\\\\@\\@g' | sed 's@{{{{{}}}}}@=@g'| sed 's@tiretn@-n@g'| sed 's@tiretv@-v@g'
	else
	    cat $filename | sed 's@.*=@@' | sed 's@\\\\@\\@g' | sed 's@{{{{{}}}}}@=@g'| sed 's@tiretn@-n@g'| sed 's@tiretv@-v@g'
	fi
    fi
    exit 0
}

## DEL FUNCTION

delete()
{
    res=""
    while read -r i
    do
	first=$(echo $i | cut -d = -f1)
	occur=${#first}
	last=${i:$occur+1}
    	if [ "$first" = "$1" ]
	then
	    if [ $# -eq 1 ]
	    then
		res+=$first="\n"
	    else
		if [ $last != $2 ] && [ ${#last} -ne ${#2} ]
		then
		    res+=$first=$last"\n"
		fi
	    fi
	else
	    res+=$first=$last"\n"
	fi
    done < $filename
    res=${res%'\n'}
    echo -e "$res" > $filename
    exit 0
}

## check $ ARGS : permet d'eviter la duplication de code lie au check et remplacement de $key ou $value

check_and_dispatch()
{
    arg1=$1
    arg2=$2

    ac=0
    if [ "$1" != "" ]
    then
	((ac=ac+1))
    fi

    if [ "$2" != "" ]
    then
	((ac=ac+1))
    fi

    if [ "$3" != "" ]
    then
	((ac=ac+1))
    fi

    bool=0
    if [ $ac -ge 2 ]
    then
    ## verification qu'il n'y a pas de $ pour le 2e argument
	##checkd1=$(echo $1 | cut -d $ -f2)
	if [ ${1:0:1} = "$" ]
	then 
	    while read -r i
	    do
		first=$(echo $i | cut -d = -f1)
		occur=${#first}
		last=${i:$occur+1}
		if [ ${1:1} = "$first" ]
		then
		    bool=1
		    arg1=$last
		    break
		fi
	    done < $filename
	fi
	
    ## verification que la clef a bien ete trouve et remplace .. pour l'argument 1
	if [ ${1:0:1} = "$" ]
	then
	    if [ $bool -eq 0 ]
	    then
		echo "No such key : "$1
		exit 1
	    else
		arg1=$(echo $arg1 | sed 's@\\\\@\\@g')
	    fi
	fi
    fi
    ## ici on verifie qu'on a bien 3 arguments : key/value/fonction_a_appeler sinon on check pas le 2 arguments qui se retrouve etre la fonction a appeler
    if [ $ac -eq 3 ]
    then
	bool=0
    ## verification qu'il n'y a pas de $ pour le premier argument
	if [ ${2:0:1} = "$" ]
	then 
	    while read -r i
	    do
		first=$(echo $i | cut -d = -f1)
		occur=${#first}
		last=${i:$occur+1}
		if [ ${2:1} = "$first" ]
		then
		    bool=1
		    arg2=$last
		    break
		else
		    arg2=$(echo $arg2 | sed 's@\\\\@\\@g')
		fi
	    done < $filename
	fi
	
    ## verification que la clef a bien ete trouve et remplace .. pour l'argument 2
	if [ ${2:0:1} = "$" ]
	then
	    if [ $bool -eq 0 ]
	    then
		echo "No such key : "$2
		exit 1
	    fi
	fi
    fi
## dispatch vers la bonne fonction
    if [ "$3" = "put" ] && [ $ac -eq 2 ] && [ $nb -eq 4 ]
    then
	put "$arg1" "$arg2"
    fi

    if [ "$3" = "del" ] && [ $ac -eq 2 ] && [ $nb -eq 4 ]
    then
	delete "$arg1" "$arg2"
    fi

    if [ $ac -eq 3 ]
    then
	if [ $3 = "put" ]
	then
	    put "$arg1" "$arg2"
	fi
	
	if [ $3 = "del" ]
	then
	    delete "$arg1" "$arg2"
	fi
    else
	if [ $ac -eq 2 ]
	then
	    if [ $3 = "select" ]
	    then
		sel "$arg1"
	    fi
	    
	    if [ $3 = "del" ]
	    then
		delete "$arg1"
	    fi
	else
	    if [ $ac -eq 1 ]
	    then
		if [ $3 = "select" ]
		then
		    sel
		fi
		if [ $3 = "flush" ]
		then
		    flush
		fi
	    fi
	fi
    fi
    aff_usage $0
    exit 1
}

## PUT FUNCTION
put()
{
    arg1=$(echo "$1" | sed 's@\\@\\\\@g' | sed 's@=@{{{{{}}}}}@g')
    arg2=$(echo "$2" | sed 's@\\@\\\\@g' | sed 's@=@{{{{{}}}}}@g')
    res=$(cat $filename | grep -F "$arg1=")
    res=$(echo $res | sed 's@\\@\\\\@g')
    if [ ${#res} -gt 0 ]
    then
	sed -i -u /"$res"/d $filename
    fi
    echo "$arg1"="$arg2" >> $filename
    exit 0
}


## usage affichage
aff_usage()
{
    echo "Syntax error :"
    exit 1
}

## flushing file

flush()
{
    echo -n > $filename
    exit 0
}

aff_key=0
filename="sh.db"
bool=0
pos=1
needcreate=0
nb=1
isargs=0
arg1=""
arg2=""
arg3=""

while [ $pos -le "$#" ]
do
    if [ $pos -eq 1 ]
    then
	i="$1"
    fi
    if [ $pos -eq 2 ]
    then
	i="$2"
    fi
    if [ $pos -eq 3 ]
    then
	i="$3"
    fi
    if [ $pos -eq 4 ]
    then
	i="$4"
    fi
    if [ $pos -eq 5 ]
    then
	i="$5"
    fi
    if [ $pos -eq 6 ]
    then
	i="$6"
    fi
    ((pos=pos+1))
    if [ "$i" = "-k" ] && [ $isargs -eq 0 ]
    then
	((aff_key=aff_key+1))
	continue
    fi
    if [ "$i" = "--" ] && [ $isargs -eq 0 ] && [ "$arg1" != "put" ]
    then
	isargs=1
	continue
    fi
    if [ "$i" = "-f" ] && [ $isargs -eq 0 ]
    then
	((bool=bool+2))
	continue
    fi
    if [ "$i" = "-c" ] && [ $isargs -eq 0 ]
    then
	((bool=bool+3))
	needcreate=1
	continue
    fi
    if [ $nb -eq 1 ]
    then
	arg1="$i"
	((nb=nb+1))
	continue
    fi
    if [ $nb -eq 2 ]
    then
	arg2="$i"
	((nb=nb+1))
	continue
    fi
    if [ $nb -eq 3 ]
    then
	arg3="$i"
	((nb=nb+1))
	continue
    fi
    if [ $nb -gt 3 ]
    then
	aff_usage $0
    fi
done

if [ "$arg2" = "-n" ]
then
    arg2="tiretn"
fi

if [ "$arg3" = "-n" ]
then
    arg3="tiretn"
fi

if [ "$arg2" = "-v" ]
then
    arg2="tiretv"
fi

if [ "$arg3" = "-v" ]
then
    arg3="tiretv"
fi
if [ $aff_key -gt 1 ] || [ $bool -gt 3 ]
then
    aff_usage $0
fi

if [ $bool -ge 2 ]
then
    filename=$i
    if [ $bool -eq 2 ]
    then
	if [ ! -e "$filename" ]
	then
	    echo "No base found :"
	    exit 1
	fi
    fi
    echo -n "" >> $filename
    bool=0
fi

check_and_dispatch "$arg2" "$arg3" "$arg1"
