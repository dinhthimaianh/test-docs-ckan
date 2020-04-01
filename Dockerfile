FROM ubuntu:16.04
LABEL version="1.0"
LABEL description="VNPT OPENDATA CKAN"

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update --fix-missing -y
RUN apt install -y apt-transport-https ca-certificates language-pack-en-base software-properties-common apt-utils

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
RUN add-apt-repository -y ppa:ondrej/apache2
RUN apt-get update -y --fix-missing

# Install the required packages
RUN apt-get -y install python-dev libpq-dev python-pip python-virtualenv openjdk-8-jdk redis-server supervisor

# Create a Python virtual environment (virtualenv) to install CKAN into, and activate it:
RUN mkdir -p /usr/lib/ckan/default
RUN virtualenv --no-site-packages /usr/lib/ckan/default
RUN . /usr/lib/ckan/default/bin/activate

# Install the recommended setuptools version:
RUN pip install setuptools==36.1
#Install the CKAN source code into your virtualenv
RUN mkdir -p /usr/lib/ckan/default/src
ADD . /usr/lib/ckan/default/src/
RUN pip install -e /usr/lib/ckan/default/src
RUN pip install -r /usr/lib/ckan/default/src/requirements.txt
#RUN deactivate
RUN . /usr/lib/ckan/default/bin/activate
RUN cp /usr/local/bin/paster /usr/lib/ckan/default/bin/paster
# Install Modules and Extensions
RUN pip install --upgrade pip
RUN pip install messytables
RUN pip install ckanext-xloader
RUN pip install unidecode
RUN pip install urllib3
RUN pip install pyopenssl
RUN pip install jsonschema
RUN pip install ckantoolkit
RUN pip install pika

WORKDIR /usr/lib/ckan/default/src
# Install all extension in ./ckanext
RUN find ./ckanext -name "requirements.txt" | while read line; do pip install -r $line; done
RUN pip install -e $(find ./ckanext -name "setup.py" | while read line; do dirname $line; done)

RUN apt-get -y install apache2 libapache2-mod-wsgi libapache2-mod-rpaf
RUN mkdir -p /etc/ckan/default
RUN mkdir -p /var/lib/ckan # Local Storage
ADD /build/apache.wsgi /etc/ckan/default/apache.wsgi
ADD /build/ckan_default.conf /etc/apache2/sites-enabled/ckan_default.conf
ADD /production.ini /etc/ckan/default/production.ini
ADD /who.ini /etc/ckan/default/who.ini
RUN chown -R www-data:www-data /usr/lib/ckan
RUN chown -R www-data:www-data /var/lib/ckan

# Config Supervisor
RUN cp /usr/lib/ckan/default/src/ckan/config/supervisor-ckan-worker.conf /etc/supervisor/conf.d/
#ADD ./build/supervisor-apache2-worker.conf /etc/supervisor/conf.d/
# add apache config here

RUN . /usr/lib/ckan/default/bin/activate
RUN python setup.py update_catalog --no-fuzzy-matching
RUN python setup.py compile_catalog --locale vi --use-fuzzy

EXPOSE 8080

RUN echo "#!/bin/bash" > /start.sh
RUN echo "service apache2 start" >> /start.sh
RUN echo "service redis-server start" >> /start.sh
RUN echo "/usr/bin/supervisord -nc /etc/supervisor/supervisord.conf" >> /start.sh
RUN chmod +x /start.sh

#ENTRYPOINT /usr/bin/supervisord -nc /etc/supervisor/supervisord.conf
ENTRYPOINT /start.sh
