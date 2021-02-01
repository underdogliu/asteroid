#!/bin/bash

wav_dir=tmp
out_dir=tmp

. utils/parse_options.sh

## Download WHAM noises
mkdir -p $out_dir
echo "Download WHAM noises into $out_dir"
# If downloading stalls for more than 20s, relaunch from previous state.
if [ ! -d $out_dir/wham_noise ]; then
	wget -c --tries=0 --read-timeout=20 https://storage.googleapis.com/whisper-public/wham_noise.zip -P $out_dir
	mkdir -p $out_dir/logs
	unzip $out_dir/wham_noise.zip -d $out_dir >> $out_dir/logs/unzip_wham.log
fi

echo "Download WHAM scripts into $out_dir"
wget https://storage.googleapis.com/whisper-public/wham_scripts.tar.gz -P $out_dir
tar -xzvf $out_dir/wham_scripts.tar.gz -C $out_dir
mv $out_dir/wham_scripts.tar.gz $out_dir/wham_scripts

wait

echo "Run python scripts to create the WHAM mixtures"
# Requires : Numpy, Scipy, Pandas, and Pysoundfile
cd $out_dir/wham_scripts
python3 create_wham_from_scratch.py \
	--wsj0-root $wav_dir \
	--wham-noise-root $out_dir/wham_noise\
	--output-dir $out_dir
cd -
