nextflow.enable.dsl=2

include { circ3 } from './modules/local/circexplore3/main'
include { INPUT_CHECK       } from './subworkflows/local/input_check.nf'
include { generateHisat2Index } from './modules/local/hisat2Index/main'


params.fasta   = params.genome  ? params.genomes[ params.genome ].fasta ?: false : false
params.gtf     = params.genome  ? params.genomes[ params.genome ].gtf ?: false : false
params.bowtie = params.genome  ? params.genomes[ params.genome ].bowtie ?: false : false

ch_fasta       = 'null'
ch_gtf         = 'null'

// Check mandatory parameters
if (params.input) { ch_input = file(params.input) } else { exit 1, 'Input samplesheet not specified!' }
ch_phenotype   = Channel.empty()

'''
//This is a residual part of test block
workflow {
    // Define example file paths
    read1 = file('/restricted/projectnb/casa/mtLin/circexplore3/circlexplore3_pipeline/inputdata/1000_R1.fastq.gz')
    read2 = file('/restricted/projectnb/casa/mtLin/circexplore3/circlexplore3_pipeline/inputdata/1000_R2.fastq.gz')
    hisat_index = file('/restricted/projectnb/casa/mtLin/reference/hisat_index')
    botie_index = file(params.bowtie)
    fasta = file(params.fasta)
    gtf = file(params.gtf)

    // Channel creation for input files
    read_pairs = Channel.from([ [ 'metaData', [read1, read2] ] ])

    // Running the process
    circ3_test(read_pairs, fasta, hisat_index, botie_index, gtf)
}
'''

workflow{
    ch_versions = Channel.empty()

    //
    // 1. Pre-processing
    //

    // SUBWORKFLOW:
    // Validate input samplesheet & phenotype file
    
    INPUT_CHECK (
        ch_input,
        ch_phenotype
    )
    .reads
    .map {
        meta, fastq ->
            meta.id = meta.id.split('_')[0..-2].join('_')
            [ meta, fastq ] }
    .dump(tag: 'map')
    .groupTuple(by: [0])
    .dump(tag: 'group')
    .branch {
        meta, fastq ->
            single  : fastq.size() == 1
                return [ meta, fastq.flatten() ]
            multiple: fastq.size() > 1
                return [ meta, fastq.flatten() ]
    }
    .set { ch_fastq }
    
    //here the single/multiple refers to the number of seq the sample have. Not refers to single/double sequencing
    
    ch_versions = ch_versions.mix(INPUT_CHECK.out.versions)
    
    
    /**/
    //debug/verbose
    ch_fastq.multiple.view{"$it is multiple"}
    ch_fastq.single.view{"$it"}

    //prepare reference. change them into channel
    botie_index = file(params.bowtie)
    fasta = file(params.fasta)
    gtf = file(params.gtf)
    //Todo: find a stable way to generate hisat index
    hisat_index = generateHisat2Index(params.fasta)

    circ3(ch_fastq.single, 
                fasta, 
                hisat_index, 
                botie_index, 
                gtf)
}