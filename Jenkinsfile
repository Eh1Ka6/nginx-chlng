pipeline 
{
    agent any
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
		stage ('Set Environnement')
		{
		  steps
		  {
		    script{	
				env.PCRE = sh(
						returnStdout: true, script: '''find /lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/ /usr/local/lib/x86_64-linux-gnu/ -regex ".*pcre.so.[4-8].*" -type f -print -quit '''
					     ).trim()
				env.SSL = sh (
					  returnStdout: true,
					  script: ''' find /usr/lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/ /usr/local/lib/x86_64-linux-gnu/ -regex "^openssl-1.(0.[2-9])|openssl-1.(1.0)" -type f -print -quit'''
					   ).trim()
				env.ZLIB = sh ( script : ''' find /usr/lib/x86_64-linux-gnu/ /usr/lib/x86_64-linux-gnu/ /usr/local/lib/x86_64-linux-gnu/ -regex "libz.so.1.(1.[3-9])|libz.so.1.(2.[0-11])" -type f -print -quit''',
							returnStdout: true).trim()
				env.DATE= sh ( script : '''date "+%Y-%m-%d %H:%M:%S" ''' ,  returnStdout:true ).trim()
				if(!fileExists("deps/"))
				{
		            sh ('''mkdir deps''') 
		        }
		       
		    }
		  }
		}      
        stage('Download missing lib') 
		{
		   parallel 
		   {
		     stage('check for ZLIB')
		     { 	
		         steps {
		         	script{
		         		if ( env.ZLIB  == null || env.ZLIB == "" )
		         		{
	                 	sh ('''cd deps &&  wget http://www.zlib.net/zlib-1.2.11.tar.gz && tar xzvf zlib-1.2.11.tar.gz''') 
						env.ZLIB = "deps/zlib-1.2.11/"
						}
						else {
						    env.ZLIB =""
						}

					}
			  }
		     }
		     stage('check for SSL')
		     {
	                 steps {
	                 	script{
	                 		if (env.SSL  == null || env.SSL == "" )
	                 		{
		                        sh ('''cd deps && wget https://www.openssl.org/source/openssl-1.1.0f.tar.gz && tar xzvf openssl-1.1.0f.tar.gz ''')   
		                        env.SSL= "deps/openssl-1.1.0f/"
	                        }
	                        else 
	                        {
    							env.SSL=""
							}
	                   }
	                 }
		     }
		     stage('check for PCRE')
		     {
	                 steps {
	                 	script{
	                 	if(env.PCRE  == null || env.PCRE == "")
	                 	{
	                        sh ('''cd deps && wget https://ftp.pcre.org/pub/pcre/pcre-8.40.tar.gz && tar xzvf pcre-8.40.tar.gz''')
	                        env.PCRE = "deps/pcre-8.40/"
	                    }
	                    else {
	                         env.PCRE = ""
	                    }

	                  }
	                }
		     }
		    }
		   }
	 	  
        stage('Build')
	    {
            steps {
            	script {

                sh './configure --prefix=/etc/nginx  --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx.conf --error-log-path=/var/log/nginx/error.log --user=nginx --group=nginx --builddir=nginx-1.15.0   --pid-path=/usr/local/nginx/nginx.pid  --with-http_ssl_module --with-openssl=${SSL} --with-zlib=${ZLIB}  --with-pcre=${PCRE}'
                sh 'make'
                def image = docker.build('ngx:${BUILD_NUMBER}','.')
                }
		 	}
        }      
        stage('Test') 
		{
            steps 
	    	{
			script{
				image.run()
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
 

