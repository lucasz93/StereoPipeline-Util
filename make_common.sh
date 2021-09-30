#===============================================================================
#===============================================================================
rootDir=`pwd`/..
installDir=$rootDir/install

source $HOME/miniconda3/etc/profile.d/conda.sh

#===============================================================================
#===============================================================================
clear_remote_conda_package_cache()
{
	# Clear any packages cached from the real sources. We want to use the local ones.
	conda activate base
	rm -rf $CONDA_PREFIX/pkgs/ale*
	rm -rf $CONDA_PREFIX/pkgs/spiceypy*
	rm -rf $CONDA_PREFIX/pkgs/cspice*
	conda deactivate
}

#===============================================================================
#===============================================================================
make_visionworkbench()
{
	pushd $rootDir/visionworkbench/build

	ninja $1 -j `distcc -j`

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
	ninja $1 -j `distcc -j`
	conda deactivate

	# ISIS installs its headers to /include/isis3, but the conda package is
	# distributed in /include/isis. Add a symbolic link so our packages don't break.
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

	ninja $1 -j `distcc -j`

	popd
}

#===============================================================================
#===============================================================================
make_f2c()
{
	pushd $rootDir/f2c/src

	make -j `nproc`
	
	if [ "$1" = "install" ]; then
		mkdir -p $installDir/bin
		
		cp f2c $installDir/bin
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
		["spicelib"]="cspice"
		["spkdiff"]="spkdif_c"
		["spkmerge"]="spkmrg_c"
		["support"]="csupport"
		["tobin"]="tobin_c"
		["toxfr"]="toxfr_c"
		["version"]="versn_c"
	)

	fsrc="$rootDir/naif-toolkit/src"
	csrc="$rootDir/cspice/src"

	# Files that w're not converting, because they were completely rewritten.
	blacklist='byebye.f|dpmax.f|dpmin.f|intmax.f|intmin.f|moved.f|zzcputim.f|zzgfdsps.f|getcml.f'

	# Get the name of each source subdirectory.
	# Iterate through the CSPICE src dirs, so we know which Toolkit dirs to parse.
	for in in "${!dirs[@]}"; do
		pushd "$fsrc/$in"
			# Rename blacklisted files.
			ignore=`find . -maxdepth 1 -mindepth 1 -printf '%f\n' | egrep "$blacklist" | sort`
			for i in $ignore; do
				mv "$i" "$i.no"
			done
			
			# Create a copy of all PGM source files with a Fortran extension.
			# f2c doesn't want to touch PGM files, and the original CSPICE
			# source code seems to indicate NAIF just renamed them as well.
			pgms=`find . -maxdepth 1 -mindepth 1 -printf '%f\n' | grep "pgm" | sort`
			for pgm in $pgms; do
				cp "$pgm" "${pgm%.pgm}.f"
			done

			out_dir="${dirs[$in]}"

			# Only the support libraries need the global state object.
			# Plus, my f2c mod doesn't handle variable name clashes, which happens in the other programs.
			# So instead of spending the time to fix clashes, YAGNI.
			if [ "$out_dir" = "cspice" ]; then
				wrap="-wrap -wrap-name$out_dir"
			else
				wrap=""
			fi

			# Convert all the files.
			out_path="$csrc/$out_dir"
			f2c -u -C -a -A -!bs $wrap -d$out_path  *.f
			
			# Delete the PGM copies, and rename their C files to PGM as well.
			# No idea why, NAIF just did that.
			for pgm in $pgms; do
				extensionless_pgm="${pgm%.pgm}"
				rm "$extensionless_pgm.f"
				mv "$out_path/$extensionless_pgm.c" "$out_path/$pgm"
			done
			
			# Undo the blacklist.
			for i in $ignore; do
				mv "$i.no" "$i"
			done
		popd
	done
}

#===============================================================================
#===============================================================================
make_cspice()
{
	pushd $rootDir/cspice

	#
	# Build using dev environment.
	#
	conda activate dev

	rm $CONDA_PREFIX/lib/cspice.a
	rm $CONDA_PREFIX/lib/csupport.a
	rm $CONDA_PREFIX/lib/libcspice.so
	conda build ../cspice-feedstock

	BUILD_CACHE_DIR=$CONDA_PREFIX/conda-bld/

	conda deactivate

	#
	# Install into isis_deps
	#
	if [ "$1" = "install" ]; then
		clear_remote_conda_package_cache

		conda activate isis_dep
		conda install --override-channels --force-reinstall --no-deps -c $BUILD_CACHE_DIR -c local cspice
		conda deactivate

		#conda install --no-deps /home/mechsoft/miniconda3/envs/dev/conda-bld/linux-64/ale-0.8.5-py39h2bc3f7f_3.tar.bz2
	fi

	popd
}

#===============================================================================
#===============================================================================
make_deps()
{
	pushd $rootDir/isis3_dependencies

	conda activate dev
	export CPU_COUNT=`nproc`
	python bin/build_package.py qt -y --user mechsoft
	conda deactivate
	
	popd
}

#===============================================================================
#===============================================================================
make_ale()
{
	pushd $rootDir/ale

	#
	# Build using dev environment.
	#
	conda activate dev
	conda build --python=3.6 ../ale-feedstock
	BUILD_CACHE_DIR=$CONDA_PREFIX/conda-bld/
	conda deactivate

	#
	# Install into isis_deps
	#
	if [ "$1" = "install" ]; then
		clear_remote_conda_package_cache

		conda activate isis_deps
		conda install --override-channels --force-reinstall --no-deps -c $BUILD_CACHE_DIR -c local ale
		conda deactivate
	fi

	popd
}


#===============================================================================
#===============================================================================
make_spiceypy()
{
	pushd $rootDir/SpiceyPy

	#
	# Build using dev environment.
	#
	conda activate dev
	conda build --python=3.9 ../spiceypy-feedstock
	BUILD_CACHE_DIR=$CONDA_PREFIX/conda-bld
	conda deactivate

	#
	# Install into isis_deps
	#
	if [ "$1" = "install" ]; then
		clear_remote_conda_package_cache

		conda activate isis_deps
		conda install --override-channels --force-reinstall --no-deps -c $BUILD_CACHE_DIR -c local spiceypy
		conda deactivate
	fi

	popd
}

#===============================================================================
# $1 = script name
# $2 = target
# $3 = directive
#===============================================================================
make_project()
{
	case "$2" in
		"f2c" ) make_f2c "$3" ;;
		"cspice_src" ) make_cspice_src "$3" ;;
		"cspice" ) make_cspice "$3" ;;
		"vw" ) make_visionworkbench "$3" ;;
		"isis" ) make_isis3 "$3" ;;
		"asp" ) make_stereopipeline "$3" ;;
		"deps" ) make_deps "$3" ;;
		"ale" ) make_ale "$3" ;;
		"spiceypy" ) make_spiceypy "$3" ;;
		"all" )
			make_f2c "$3"
			make_cspice "$3"
		
			# Order of these is significant.
			# Each relies on the predecessor.
			make_visionworkbench "$3"
			make_isis3 "$3"
			make_stereopipeline "$3"
			;;
		* ) 
			echo "$1: Unknown target '$2'"
			echo "./$1.sh [f2c|vw|isis|asp|cspice_src|cspice|deps|ale|spiceypy|all]"
			exit 1
			;;
	esac
	
	echo ""
	echo "Remember to './deploy.sh all' if necessary"
}

