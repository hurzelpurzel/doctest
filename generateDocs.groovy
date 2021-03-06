node(){

    properties([
        parameters([
            string(name: 'url', defaultValue: ''),
            string(name: 'indir', defaultValue: ''),
        ])
    ])

    cleanWs()
    def indir = params.indir
    def url = params.url
    def outdir = "output"
    def outdir1 = "output1"
    def outdir2 = "output2"
    def files = [];
   
    stage('fetch git') { //
        // Get some code from a GitHub repository
        git  url: "${url}", branch: "main"
        
        
    }
  

    stage('Preparation') { //
     
        files = sh (script: "ls -1 ${indir}" , returnStdout: true).split()     
        println "found ${files}"
        sh "mkdir -p ${outdir}"
    
        
    }

    stage("generate html"){
         sh "mkdir -p ${outdir1}"
         files.each {
             //println "${it}"
             sh "asciidoctor  -D ${outdir1} -b html5 ${indir}/${it}"
         }
         sh "tar -zcvf ${outdir}/html.tar.gz ${outdir1}"
    }    
    
    stage("generate docx"){
          sh "mkdir -p ${outdir2}"
         files.each {
             //println "${it}"
             def fp= sh script:"basename  -s .adoc ${it}", returnStdout: true
             fp = fp.trim()
             //print fp
             
             sh "asciidoctor  -D ${outdir} -b docbook5 ${indir}/${it}"
             sh "pandoc --from=docbook ${outdir}/${fp}.xml -o ${outdir2}/${fp}.docx"
         }
         sh "tar -zcvf ${outdir}/docx.tar.gz ${outdir2}"
    }    

    stage("provide"){
        
        archiveArtifacts artifacts: "${outdir}/*.gz"
    
    }
}