def createConfig(){
    def adoc = [ indir : "adoc",
                 url : "https://github.com/hurzelpurzel/doctest.git"
                ]
    
    def adoc2 = [  indir : "adoc2",
                url : "https://github.com/hurzelpurzel/doctest.git"
                ]    

     def arr =[ ]
     arr << adoc
     arr << adoc2
     return arr
}


node(){
    cleanWs()
   
    def arr = createConfig() 

    def files = [];
    


  
    
    stage("process"){
        //echo  "${arr}"
        arr.each{
            //print it
            build job: 'generateDocs', parameters: [string(name: 'url', value: "${it.url}"),string(name: 'indir', value: "${it.indir}")]
        }    
    }

    
}