if [ "$2" == "" ]; then
	export TEMPFILE=$1
else
	export TEMPFILE=_temp_.png
	convert $1 -background $2 -flatten $TEMPFILE
fi

convert $TEMPFILE -resize 180X180 icon-60@3x.png
convert $TEMPFILE -resize 120X120 icon-60@2x.png
convert  $TEMPFILE -resize 152X152 icon-76@2x.png
convert $TEMPFILE -resize 76X76 icon-76.png
convert $TEMPFILE -resize 120X120 icon-120.png
convert $TEMPFILE -resize 114x114 icon@2x.png
convert $TEMPFILE -resize 57x57 icon.png
convert $TEMPFILE -resize 144X144 iPadIcon@2x.png
convert $TEMPFILE -resize 72x72 iPadIcon.png
convert $TEMPFILE -resize 512x512 iTunesArtwork
convert $1 -resize 48x48 mochat@2x.png
convert $1 -resize 24x24 mochat.png
