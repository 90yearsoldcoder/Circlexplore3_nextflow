#!/usr/bin/env nextflow


process generateHisat2Index {
    label 'process_high'

    container 'docker://mintylin/circexplorer3'

    input:
    path ref_genome

    output:
    path "${ref_genome.baseName}_index_dir"

    script:
    """
    mkdir -p ${ref_genome.baseName}_index_dir
    hisat2-build -p 8 $ref_genome ${ref_genome.baseName}_index_dir/hisat_index
    """

}
