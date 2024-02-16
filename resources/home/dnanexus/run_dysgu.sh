#!/bin/bash

echo "--------------------"
echo "/home/dnanexus/run_dysgu.sh running..."
echo "--------------------"

# arguments
sample=$1

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

# make folders and move files
mkdir -p /home/dnanexus/work/input/bams
mkdir -p /home/dnanexus/work/input/ref
mkdir -p /home/dnanexus/work/temp
mv *bam* /home/dnanexus/work/input/bams
mv *fasta* /home/dnanexus/work/input/ref

# set input variables
bam="$(basename /home/dnanexus/work/input/bams/*.bam)"
ref="$(basename /home/dnanexus/work/input/ref/*.fasta)"

# run docker
echo "Starting docker..."
docker run -it --name dysgu -v /home/dnanexus/work:/data --workdir /data -d kcleal/dysgu:latest

# run dysgu
echo "Running dysgu"
docker exec dysgu sh -c "dysgu run -p4 \
    /data/input/ref/$ref \
    /data/temp/ \
    /data/input/bams/$bam \
    -x > /data/$sample.dysgu3.vcf"

# complete
echo "dysgu is complete..."
