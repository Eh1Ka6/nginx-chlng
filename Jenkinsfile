pipeline 
{
    agent any
    environment {
	PCRE =""
	SSL=""
	ZLIB=""
	DATE="" 
    } 

    stages 
    {
		stage ('Set SCM')
		{
			steps {
			  script{
				def scmVars = checkout scm
			  }
			}
		 }
		stage ('Set ENV var')
		{
		  steps
		  {
		    script{	
			env.PCRE = sh(
					returnStdout: true, script: '''ls -d -1 /lib/x86_64-linux-gnu/* /usr/lib/x86_64-linux-gnu/* /usr/local/lib/x86_64-linux-gnu/* | grep   ".*pcre.so.[3-8].*"'''
				     )
			env.SSL = sh (
				  returnStdout: true,
				  script: ''' ls -d -1 /usr/lib/x86_64-linux-gnu/* /usr/lib/x86_64-linux-gnu/* /usr/local/lib/x86_64-linux-gnu/* | grep -E "^openssl-1.(0.[2-9])|openssl-1.(1.0)";'''
				   )
			env.ZLIB = sh ( script : ''' ls -d -1 /usr/lib/x86_64-linux-gnu/* /usr/lib/x86_64-linux-gnu/* /usr/local/lib/x86_64-linux-gnu/* | grep -E "libz.so.1.(1.[3-9])|libz.so.1.(2.[0-11])";''',
						returnStdout: true)
			env.DATE= sh ( script : '''date "+%Y-%m-%d %H:%M:%S" ''' ,  returnStdout:true ).trim()
		    }
		  }
		} 
        stage('Download missing lib') 
		{
		 steps 
		  {
		   parallel 
		   {
		     stage('check for ZLIB')
		     {
		        when {
				expression { env.ZLIB  == null || env.ZLIB == "" }
			 }	
		         steps {
				sh ('''if [! -d deps/  ];then mkdir deps ;fi && cd deps &&  wget http://www.zlib.net/zlib-1.2.11.tar.gz && tar xzvf zlib-1.2.11.tar.gz''') 
				env.ZLIB = "deps/zlib-1.2.11/"
			  }
		     }
		     stage('check for SSL')
		     {
		        when {
	                        expression { env.SSL  == null || env.SSL == "" }
	                 }
	                 steps {
	                        sh ('''if [! -d deps/  ];then  mkdir deps ;fi && cd deps && wget https://www.openssl.org/source/openssl-1.1.0f.tar.gz && tar xzvf openssl-1.1.0f.tar.gz ''')   
	                        env.ZLIB = "deps/openssl-1.1.0f/"
	                  }
		     }
		     stage('check for PCRE')
		     {
		        when {
	                        expression { env.PCRE  == null || env.PCRE == "" }
	                 }
	                 steps {
	                        sh ('''if [! -d deps/  ];then  mkdir deps ;fi && cd deps && wget https://ftp.pcre.org/pub/pcre/pcre-8.40.tar.gz && tar xzvf pcre-8.40.tar.gz''')
	                        env.ZLIB = "deps/pcre-8.40/"
	                  }
		     }
		    }
		  }
	 	}
        stage('Build')
	{
            steps {
                sh './configure --prefix=/etc/nginx  --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx.conf --error-log-path=/var/log/nginx/error.log --user=nginx --group=nginx --builddir=nginx-1.15.0   --pid-path=/usr/local/nginx/nginx.pid  --with-http_ssl_module --with-openssl=${SSL} --with-zlib=${ZLIB}  --with-pcre=${PCRE}'
                sh 'make'
		}
        }

      stage('Deploy') 
      {
		  steps 
		  {
	            script{
	              def image = docker.build('Ngx:${BUILD_NUMBER}','.')
		      image.run()
		    }
		  }
       }          
        stage('Test') 
	{
            steps 
	    {
		script{
                env.IP = sh ('''docker inspect $(docker ps |grep {{image.id}}|cut -d ' ' -f 1)|grep IPAddress|cut -d '"' -f 4''' , returnStdout:true ).trim()
		sh '''curl -o ${env.BUILD_ID}_${date}_nginx.out -s http://${IP}/'''		
		}            
	    }
        }
	stage('Archive') 
	{
            steps {
		archiveArtifacts artifacts: '${env.BUILD_ID}_${date}_nginx.out', onlyIfSuccessful: false
            }
        }
      }
 }
 }

