node(){
    
    def indir = "adoc"
    def outdir = "output"
    def files = [];

  

    stage('Preparation') { //
        // Get some code from a GitHub repository
        git  url: 'https://github.com/hurzelpurzel/doctest.git', branch: "main"
        files = sh (script: "ls -1 ${indir}" , returnStdout: true).split()     
        println "found ${files}"
    }

    stage("generate html"){
        
         files.each {
             //println "${it}"
             sh "asciidoctor  -D ${outdir} -b html5 ${env.WORKSPACE}/${indir}/${it}"
         }

    }
}