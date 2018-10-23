if [ "$2" == "" ]; then
	export TEMPFILE=$1
else
	export TEMPFILE=_temp_.png
	convert $1 -background $2 -flatten $TEMPFILE
fi

convert $TEMPFILE -resize 180X180 Icon-60@3x.png
convert $TEMPFILE -resize 120X120 Icon-60@2x.png
convert $TEMPFILE -resize 60X60 Icon-60.png
convert  $TEMPFILE -resize 152X152 Icon-152.png
convert $TEMPFILE -resize 76X76 Icon-76.png
convert $TEMPFILE -resize 120X120 Icon-120.png
convert $TEMPFILE -resize 114x114 Icon@2x.png
convert $TEMPFILE -resize 57x57 Icon.png
convert $TEMPFILE -resize 144X144 IPadIcon@2x.png
convert $TEMPFILE -resize 72x72 IPadIcon.png
convert $TEMPFILE -resize 512x512 Icon-512.png
convert $TEMPFILE -resize 28X28 Icon-28.png
convert $TEMPFILE -resize 108X108 Icon-108.png
convert $TEMPFILE -resize 16X16 Icon-16.png
convert $1 -resize 48x48 mochat@2x.png
convert $1 -resize 24x24 mochat.png
