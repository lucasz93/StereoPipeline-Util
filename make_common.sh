#===============================================================================
#===============================================================================
rootDir=`pwd`/..
installDir=$rootDir/install

#===============================================================================
#===============================================================================
make_visionworkbench()
{
	pushd $rootDir/visionworkbench/build

	ninja $1 -j `nproc`

	popd
}

#===============================================================================
#===============================================================================
make_isis3()
{
	pushd $rootDir/ISIS3/build

	export ISISROOT=$(pwd)
	export ISISDATA="$HOME/src/install/data"
	export ISISTESTDATA="$HOME/src/install/testData"

	source $HOME/miniconda3/etc/profile.d/conda.sh
	conda activate isis_deps
	ninja $1 -j `nproc`
	conda deactivate

	# ISIS installs its headers to /include/isis3, but the conda package is
	# distributed in /include/isis. Add a symbolic link so our packages don't break.
	if [ ! -f $installDir/include/isis3 ]; then
		mkdir -p $installDir/include/isis3
	fi
	if [ ! -L $installDir/include/isis ]; then
		ln -s $installDir/include/isis3 $installDir/include/isis
	fi

	popd
}

#===============================================================================
#===============================================================================
make_stereopipeline()
{
	pushd $rootDir/StereoPipeline/build

	ninja $1 -j `nproc`

	popd
}

#===============================================================================
#===============================================================================
make_f2c()
{
	pushd $rootDir/f2c/src

	make
	
	if [ "$1" = "install" ]; then
		cp f2c ../../install/bin
	fi

	popd
}

#===============================================================================
# Converts the Fortran naif-toolbox code to C using f2c.
#===============================================================================
make_cspice_src()
{
	declare -A dirs=( 
		["brief"]="brief_c"
		["chronos"]="chrnos_c"
		["ckbrief"]="ckbref_c"
		["commnt"]="commnt_c"
		#["cookbook"]="cook_c"		<<< Ignore this dir. It's full of example code that we don't want to overwrite.
		["dskbrief"]="dskbrief_c"
		["dskexp"]="dskexp_c"
		["frmdiff"]="frmdif_c"
		["inspekt"]="inspkt_c"
		["mkdsk"]="mkdsk_c"
		["mkspk"]="mkspk_c"
		["msopck"]="msopck_c"
		["spacit"]="spacit_c"
		["spkdiff"]="spkdif_c"
		["spkmerge"]="spkmrg_c"
		["tobin"]="tobin_c"
		["toxfr"]="toxfr_c"
		["version"]="versn_c"
	)

	fsrc="$rootDir/naif-toolkit/src"
	csrc="$rootDir/naif-cspice/src"

	# Get the name of each source subdirectory.
	# Iterate through the CSPICE src dirs, so we know which Toolkit dirs to parse.
	for in in "${!dirs[@]}"; do
		pushd "$fsrc/$in"
			# Create a copy of all PGM source files with a Fortran extension.
			# f2c doesn't want to touch PGM files, and the original CSPICE
			# source code seems to indicate NAIF just renamed them as well.
			pgms=`find . -maxdepth 1 -mindepth 1 -printf '%f\n' | grep "pgm" | sort`
			echo "### $pgms"
			for pgm in $pgms; do
				cp "$pgm" "${pgm%.pgm}.f"
			done

			# Convert all the files.
			out_dir="$csrc/${dirs[$in]}"
			f2c -u -C -a -A -!bs -d$out_dir *.f
			
			# Delete the PGM copies, and rename their C files to PGM as well.
			# No idea why, NAIF just did that.
			for pgm in $pgms; do
				extensionless_pgm="${pgm%.pgm}"
				rm "$extensionless_pgm.f"
				mv "$out_dir/$extensionless_pgm.c" "$out_dir/$pgm"
			done
		popd
	done
}

#===============================================================================
#===============================================================================
make_cspice()
{
	pushd $rootDir/naif-cspice
	
	csh makeall.csh
	
	popd
}

#===============================================================================
# $1 = script name
# $2 = target
# $3 = directive
#===============================================================================
make_project()
{
	if [ -z $2 ]; then
		echo "./$1.sh [f2c|vw|isis|asp|cspice_src|cspice|all]"
		exit 1
	fi

	case "$2" in
		"f2c" ) make_f2c "$3" ;;
		"cspice_src" ) make_cspice_src "$3" ;;
		"cspice" ) make_cspice "$3" ;;
		"vw" ) make_visionworkbench "$3" ;;
		"isis" ) make_isis3 "$3" ;;
		"asp" ) make_stereopipeline "$3" ;;
		"all" )
			make_f2c $3
		
			# Order of these is significant.
			# Each relies on the predecessor.
			make_visionworkbench "$3"
			make_isis3 "$3"
			make_stereopipeline "$3"
			;;
		* ) 
			echo "$1: Unknown target '$2'"
			exit 1
			;;
	esac
}

