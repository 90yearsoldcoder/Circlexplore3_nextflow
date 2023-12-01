nextflow.enable.dsl=2

//run with nextflow run nextflow_test.nf -dump-channels -profile singularity --genome GRCh38

params.genome = ''
params.fasta   = params.genome  ? params.genomes[ params.genome ].fasta ?: false : false
params.gtf     = params.genome  ? params.genomes[ params.genome ].gtf ?: false : false
params.bowtie = params.genome  ? params.genomes[ params.genome ].bowtie ?: false : false

process circ3{
    label 'process_high'
    
    input:
        tuple val(meta), path(reads)
        path fasta
        path hisat_index
        path botie_index
        path gtf

    output:
        path "output_dir/*"

    container 'docker://mintylin/circexplorer3'

    script:
    """
    # Unzip reads if they are zipped
    echo "start upziping"
    
    gunzip -c ${reads[0]} > mate_1.fastq
    gunzip -c ${reads[1]} > mate_2.fastq
    
    echo "unzip done"

    # Run clear_quant with the appropriate files
    clear_quant -1 mate_1.fastq \\
                -2 mate_2.fastq \\
                -g ${fasta} \\
                -i ${hisat_index}/hisat_index \\
                -j ${botie_index}/genome  \\
                -G ${gtf} \\
                -o output_dir
    """
}
