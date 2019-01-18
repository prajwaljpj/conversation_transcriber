#! /bin/bash

set -m

# basic paths
L_CHANNEL=$PWD/channels/l_channel
R_CHANNEL=$PWD/channels/r_channel
L_TRANS=$PWD/transcribed/l_channel
R_TRANS=$PWD/transcribed/r_channel

LIST_FILES=$1

# assigning some variables from files
. batch_convert.sh

# base directories
mkdir --parents $L_CHANNEL $R_CHANNEL $L_TRANS $R_TRANS


for FIL in `cat $LIST_FILES`; do
	echo $FIL
	base=`basename $FIL`
	filename="${base%.*}"
	#filename="${FIL##*/}"
	filenamer=$R_CHANNEL/$filename.r.wav
	filenamel=$L_CHANNEL/$filename.l.wav
	sox $FIL "$R_CHANNEL/$filename.r.wav" remix 1
	sox $FIL "$L_CHANNEL/$filename.l.wav" remix 2

	# for nnet2
	if [ $decoding = "nnet2" ]; then
		online2-wav-nnet2-latgen-faster --do-endpointing=false  \
			--online=false  \
			--config=$decodeconfig   \
			--max-active=7000 \
			--beam=$beam \
			--lattice-beam=$latticebeam \
			--acoustic-scale=$accousticscale \
			--word-symbol-table=$wordstxt\
			$model \
			$graph \
			"ark:echo ${filename}_r ${filename}_r|" "scp:echo ${filename}_r $filenamer|" ark:- |\
			lattice-to-ctm-conf ark:- - | \
			int2sym.pl -f 5 $wordstxt > $R_TRANS/$filename.r.tran &

		online2-wav-nnet2-latgen-faster --do-endpointing=false  \
			--online=false  \
			--config=$decodeconfig   \
			--max-active=7000 \
			--beam=$beam \
			--lattice-beam=$latticebeam \
			--acoustic-scale=$accousticscale \
			--word-symbol-table=$wordstxt \
			$model \
			$graph \
			"ark:echo ${filename}_l ${filename}_l|" "scp:echo ${filename}_l $filenamel|" ark:- |\
			lattice-to-ctm-conf ark:- - | \
			int2sym.pl -f 5 $wordstxt > $L_TRANS/$filename.l.tran &

	# for nnet3
    elif [ $decoding = "nnet3" ]; then

		online2-wav-nnet3-latgen-faster --do-endpointing=false \
			--online=false \
			--config=$decodeconfig \
			--max-active=7000 --beam=$beam --lattice-beam=$latticebeam \
			--mfcc-config=$mfcchires \
			--feature-type=mfcc --frame-subsampling-factor=3 \
			--acoustic-scale=$accousticscale --word-symbol-table=$wordstxt \
			--ivector-extraction-config=$ivectorconf \
			$model \
			$graph \
			"ark:echo ${filename}_r ${filename}_r|" "scp:echo ${filename}_r $filenamer|"  \
			ark:| lattice-1best ark:- ark: | \
			lattice-align-words $wordboundary $model ark:- ark:- | \
			nbest-to-ctm --frame-shift=0.01 --print-silence=true ark:- - | \
			int2sym.pl -f 5 $wordstxt > $R_TRANS/$filename.r.tran &

		online2-wav-nnet3-latgen-faster --do-endpointing=false \
			--online=false \
			--config=$decodeconfig \
			--max-active=7000 --beam=$beam --lattice-beam=$latticebeam \
			--mfcc-config=$mfcchires \
			--feature-type=mfcc --frame-subsampling-factor=3 \
			--acoustic-scale=$accousticscale --word-symbol-table=$wordstxt \
			--ivector-extraction-config=$ivectorconf \
			$model \
			$graph \
			"ark:echo ${filename}_l ${filename}_l|" "scp:echo ${filename}_l $filenamel|"  \
			ark:| lattice-1best ark:- ark: | \
			lattice-align-words $wordboundary $model ark:- ark:- | \
			nbest-to-ctm --frame-shift=0.01 --print-silence=true ark:- - | \
			int2sym.pl -f 5 $wordstxt > $L_TRANS/$filename.l.tran &

	fi
	done

echo "Splitting and Transcribing channels"

wait
