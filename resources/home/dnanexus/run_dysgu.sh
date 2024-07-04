#!/bin/bash

echo "--------------------"
echo "/home/dnanexus/run_dysgu.sh running..."
echo "--------------------"

# arguments
sample=$1
options=$2
manta_vcf=$3

# download samplot docker tar
echo "Downloading docker tar file..."
dx download project-G729Kkj4fq4Q9X1BPy0807bK:file-GbX83384fq4f1g9XZYb1Fkg4

# load docker image
echo "Loading docker image..."
docker load -i dysgu.1.6.2.tar

# print parameters
echo "--------------------"
echo "Bash parameters..."
echo "--------------------"
echo "sample=$sample"
echo "options=$options"
echo "manta_vcf=$manta_vcf"

# make folders and move files
mkdir -p /home/dnanexus/work/input/bams
mkdir -p /home/dnanexus/work/input/ref
mkdir -p /home/dnanexus/work/temp
mkdir -p /home/dnanexus/work/input/vcf
mv *bam* /home/dnanexus/work/input/bams
mv *fasta* /home/dnanexus/work/input/ref
mv *vcf* /home/dnanexus/work/input/vcf

# set input variables
bam="$(basename /home/dnanexus/work/input/bams/*.bam)"
ref="$(basename /home/dnanexus/work/input/ref/*.fasta)"
manta="/home/dnanexus/work/input/vcf/$manta_vcf"

# run docker
echo "Starting docker..."
docker run -it --name dysgu -v /home/dnanexus/work:/data --workdir /data -d kcleal/dysgu:latest

# create additional site flag for manta_vcf
if [ $manta_vcf == "empty" ]; then
    sites_flag=""
else
    #unzip manta.vcf.gz
    gunzip $manta
    manta="$(basename /home/dnanexus/work/input/vcf/*.vcf)"
    sites_flag="--sites /data/input/vcf/$manta"
fi

# run dysgu
echo "Running dysgu"
docker exec dysgu sh -c "dysgu run -p4 \
    $sites_flag \
    /data/input/ref/$ref \
    /data/temp/ \
    /data/input/bams/$bam \
    $options \
    -x > /data/$sample.dysgu3.vcf"

# complete
echo "dysgu is complete..."
