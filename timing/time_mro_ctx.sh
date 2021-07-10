#!/bin/sh
#
# This is basically the example makefile (StereoPipeline/examples/CTX/Makefile), but made generic with timing information.
#

left="P02_001981_1823_XI_02N356W.IMG"
left_url="https://pds-imaging.jpl.nasa.gov/data/mro/mars_reconnaissance_orbiter/ctx/mrox_0031/data/P02_001981_1823_XI_02N356W.IMG"
left_calibrated=$left.cal.cub

right="P03_002258_1817_XI_01N356W.IMG"
right_url="https://pds-imaging.jpl.nasa.gov/data/mro/mars_reconnaissance_orbiter/ctx/mrox_0042/data/P03_002258_1817_XI_01N356W.IMG"
right_calibrated=$right.cal.cub

#
# Make parsing the time output easier.
#
prof()
{
	# Save the output file, then remove the first parameter.
	outfile=results/$1
	shift
	
	# Pass the remaining arguments for timing.
	/usr/bin/time "--format=%E	%P" --output=$outfile $@
}

rm -rf results
mkdir results

#
# We're speed limited by the PDS. 
# We could definitely benefit from a download accelerator.
#
download_dependency()
{
	if [ ! -f $1 ]; then
		# To get the best speeds, 'n' should be no more than necessary to saturate the connection.
		prof download axel -a -n 8 -o "$1" "$2"
	fi	
}

download_dependency $left $left_url
download_dependency $right $right_url

#
# Convert to an ISIS Cube.
#
convert_to_cube()
{
	temp=$1.temp.cub
	
	prof mroctx2isis mroctx2isis from=$1 to=$temp
	prof spiceinit   spiceinit from=$temp
	prof ctxcal      ctxcal from=$temp to=$2
	rm $temp
}

convert_to_cube $left $left_calibrated
convert_to_cube $right $right_calibrated

#
# Map project the data.
#
prof cam2map4stereo cam2map4stereo.py $left_calibrated $right_calibrated

#
# Run stereo steps.
#
prof pprc stereo $left_calibrated $right_calibrated tmp/out --tif-compress None -s stereo.map --entry-point 0 --stop-point 1
prof corr stereo $left_calibrated $right_calibrated tmp/out --tif-compress None -s stereo.map --entry-point 1 --stop-point 2
#prof blend stereo $left_calibrated $right_calibrated tmp/out --tif-compress None -s stereo.map --entry-point 2 --stop-point 3
prof rfne stereo $left_calibrated $right_calibrated tmp/out --tif-compress None -s stereo.map --entry-point 3 --stop-point 4
prof fltr stereo $left_calibrated $right_calibrated tmp/out --tif-compress None -s stereo.map --entry-point 4 --stop-point 5
prof tri  stereo $left_calibrated $right_calibrated tmp/out --tif-compress None -s stereo.map --entry-point 5 --stop-point 6

#
# Convert to DEM.
#
prof point2dem point2dem -r mars --nodata -32767 tmp/out-PC.tif --threads `nproc` --error --orthoimage tmp/out-L.tif

#
# Output table.
#
echo "Stage	Time	CPU"
echo "download	`cat results/download`"
echo "mroctx2isis	`cat results/mroctx2isis`"
echo "spiceinit	`cat results/spiceinit`"
echo "ctxcal	`cat results/ctxcal`"
echo "cam2map4stereo	`cat results/cam2map4stereo`"
echo "pprc	`cat results/pprc`"
echo "corr	`cat results/corr`"
echo "rfne	`cat results/rfne`"
echo "fltr	`cat results/fltr`"
echo "tri	`cat results/tri`"
echo "point2dem	`cat results/point2dem`"
