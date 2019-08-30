# Centos based container with Java and Tomcat
FROM centos

# Install prepare infrastructure
RUN yum -y update \
 && yum -y install wget \
 && yum -y install tar

# Install Oracle Java8
RUN wget --no-check-certificate 'https://docs.google.com/uc?export=download&id=1z6m6g7NAoOts1QYwc1M3rXyZMT0rvlSK' -O jdk-8u221-linux-x64.rpm \
 && yum localinstall -y jdk-8u221-linux-x64.rpm

RUN yum install -y unzip && yum clean all \
 && cd /tmp \
 && curl -L -C - -b "oraclelicense=accept-securebackup-cookie" -O http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip \
 && unzip jce_policy-8.zip \
 && mv UnlimitedJCEPolicyJDK8/*.jar /usr/java/jre*/lib/security/ \
 && rm -rf jce_policy-8.zip UnlimitedJCEPolicyJDK8
 
# Install Tomcat
ENV CATALINA_HOME /opt/tomcat 
ENV TOMCAT_MAJOR 8
ENV TOMCAT_VERSION 8.5.45

RUN wget http://mirror.linux-ia64.org/apache/tomcat/tomcat-${TOMCAT_MAJOR}/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz \
 && tar -xvf apache-tomcat-${TOMCAT_VERSION}.tar.gz \
 && rm apache-tomcat*.tar.gz \
 && mv apache-tomcat* ${CATALINA_HOME}

RUN chmod +x ${CATALINA_HOME}/bin/*sh

# Create Tomcat admin user
ADD create_admin_user.sh $CATALINA_HOME/scripts/create_admin_user.sh
ADD tomcat.sh $CATALINA_HOME/scripts/tomcat.sh
RUN chmod +x $CATALINA_HOME/scripts/*.sh

# Create tomcat user
RUN groupadd -r tomcat \
 && useradd -g tomcat -d ${CATALINA_HOME} -s /sbin/nologin  -c "Tomcat user" tomcat \
 && chown -R tomcat:tomcat ${CATALINA_HOME}

WORKDIR /opt/tomcat

EXPOSE 8080
EXPOSE 8009

USER tomcat
CMD ["tomcat.sh"]
