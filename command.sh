#!/bin/sh

##################################################### usage
#
# Edit+preview loop
#   $ ./command.sh
#
# Print using chrome (need to enable View > Developer > Allow Javascript from Apple events)
#   $ ./command.sh print
#
# Compile to a self contained HTML
#   $ ./command.sh compile

##################################################### conf

function check () {
    if [ -z `which $1` ]; then
        echo you need $1
        exit 1
    fi
}

check fswatch
check pandoc
check chrome-cli

# Reveal.js.  This script assumes version 4.1.0
REVEAL_JS=../reveal.js-4.1.0 

# Resouce directories symlinked under _build/
RESOURCE_DIRS="../images ../fonts"

############################################## end of conf


###################################################### arg

mode=

case $1 in
    '')
	;;
    print)
	mode=print;;
    compile)
	mode=compile;;
    *)
	echo "unknown mode $1"
	exit 1;;
esac

echo mode=$mode

############################################### end of arg

function force_exit () {
    exit 1
}

trap force_exit SIGINT

function path_check () {
  if [ -z "`which $1`" ]; then
      echo "Fatal error: $1 is not found in PATH"
      force_exit
  fi
}

path_check pandoc
path_check chrome-cli
path_check fswatch

# Assumes reveal.js has demo.html
if [ ! -f $REVEAL_JS/demo.html ]; then
    echo "Fatal error: reveal.js is not found at $REVEAL_JS"
    force_exit
fi

if [ ! -d _build ]; then
    mkdir _build
fi

# make a link from _build
function link () {
    echo "mklink _build/$2 ($1)"
    if [ -L _build/$2 ]; then
        rm -f _build/$2
    fi
    if echo $1 | grep -q ^/; then
	# abs path
	ln -s $1 _build/$2
    else
	# rel path
	ln -s ../$1 _build/$2
    fi
}

link $REVEAL_JS reveal.js

for i in $RESOURCE_DIRS; do
    base=`basename $i`
    link $i $base
done

for i in *.css; do
    link $i `basename $i`
done

TEMPLATE=
if [ -f revealjs.template ]; then
  export TEMPLATE="--template revealjs.template"
fi

while true; do
    for f in *.md
    do
	i=`echo $f | sed -e 's/\.md//'`

	if [ "$mode" = "compile" ]; then
	    opts=--self-contained
	    out=$i-self-contained.html
	else
	    opts=
	    out=$i.html
	fi
	
	slide_path=`pwd`/_build/$out

	pandoc -s \
	       $opts \
	       --resource-path _build \
	       --mathjax \
	       -t revealjs \
	       -o _build/$out \
	       $i.md \
	       --slide-level=2 \
	       --metadata pagetitle="$i" \
	       $TEMPLATE \
               -V revealjs-url=reveal.js
               # -V showNotes:true 

	echo mode=$mode
	case $mode in
	    print)
		chrome-cli open file://$slide_path?print-pdf
		chrome-cli execute 'print();'
		exit 0
		;;
	    compile)
		echo compiled to $slide_path
		chrome-cli open file://$slide_path
		exit 0
		;;
	    *)
		# Reload 
		# Assuming chrome-cli's output like: "[1362] https://hoge.hoge/hoge"
		ids=`chrome-cli list links | grep -F $slide_path | sed -e 's/\].*//' -e 's/\[//'`
		echo $ids
		if [ -z "$ids" ]; then
		    echo open $slide_path
		    chrome-cli open file://$slide_path
		else
		    for i in $ids
		    do	     
			echo "reload chrome tab $i"
			chrome-cli reload -t `echo $i | sed -e 's/.*://'`
		    done
		fi
		;;
	esac
    done

    echo "watching files"
    fswatch -1 *.md *.css $RESOURCE_DIRS
done
