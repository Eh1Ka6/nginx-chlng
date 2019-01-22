FROM debian:stretch-slim
LABEL maintainer="NGINX custom docker image"
RUN mkdir build
COPY . build/ 

RUN addgroup --system nginx 
RUN adduser --system --no-create-home  --disabled-login --disabled-password nginx && adduser nginx nginx

RUN apt-get update \
    && apt-get install --no-install-recommends --no-install-suggests -y  make perl gcc g++ curl bash curl tree net-tools

WORKDIR build/
RUN make install \
	&& mkdir /etc/nginx/conf.d/ \
        && mkdir /usr/websites \ 
	&& mkdir -p /usr/share/nginx/html/ \
	&& install -m644 html/index.html /usr/websites/ \
	&& install -m644 html/50x.html /usr/websites \
	&& ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
	&& strip /usr/sbin/nginx* \  

# forward request and error logs to docker log collector
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log


#cleanup
WORKDIR / 
RUN apt-get remove --purge -y make gcc g++  

#configure
COPY conf/nginx.conf /etc/nginx/nginx.conf
EXPOSE 8080
RUN sed -i -e "s/80/8080/g" /etc/nginx/nginx.conf
RUN sed -i -e "s/ html;/ \/usr\/website/g" /etc/nginx/nginx.conf

#test
RUN mkdir -p /var/lib/nginx && ls -lr /usr/sbin/  
RUN /usr/sbin/nginx -t 

#run 
CMD ["nginx","-g", "daemon off;"]

