# Use Miniconda2 as the base image
FROM continuumio/miniconda2

# Update Conda and base environment
RUN conda update -n base -c defaults conda

# Install packages using Conda
RUN conda install -c bioconda -c bioinfo -c conda-forge -c defaults \
    python=2.7 \
    numpy \
    pysam=0.9.0 \
    hisat2=2.0.5 \
    stringtie=1.3.6 \
    ucsc-gtftogenepred \
    ucsc-genepredtogtf \
    tophat=2.0.13 \
    bowtie2 \
    bowtie=1.0.0.0 \
    bedtools \
    git \
    pybedtools=0.7.5

# Install pip dependencies
RUN pip install circexplorer2==2.3.6 docopt idna requests urllib3

# Clone and install Circlexplorer3
RUN git clone https://github.com/YangLab/CLEAR \
    && cd CLEAR \
    && python ./setup.py install

# Set the working directory
WORKDIR /data

# Command to run on container start
CMD [ "/bin/bash" ]
