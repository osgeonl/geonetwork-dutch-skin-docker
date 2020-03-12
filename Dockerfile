FROM tomcat:8.5-jre8

MAINTAINER pvangenuchten <paul@geocat.net>

WORKDIR $CATALINA_HOME/webapps

RUN mv $CATALINA_HOME/webapps/ROOT $CATALINA_HOME/webapps/TOMCAT

ADD ./geonetwork.war $CATALINA_HOME/webapps 

ENV GN_DIR $CATALINA_HOME/webapps/ROOT

RUN unzip -e geonetwork.war -d $CATALINA_HOME/ROOT && \
     mv $CATALINA_HOME/ROOT $GN_DIR && \
     rm geonetwork.war

# download view
RUN curl -fSL -o 3.8.x.zip \
     https://github.com/osgeonl/geonetwork-dutch-skin/archive/3.8.x.zip && \
     unzip -e 3.8.x.zip -d $CATALINA_HOME && \
     mv $CATALINA_HOME/geonetwork-dutch-skin-3.8.x $GN_DIR/catalog/views/dutch && \
     rm 3.8.x.zip

# download gmd plugin
RUN curl -fSL -o 3.8.zip \
     https://github.com/metadata101/iso19139.nl.geografie.2.0.0/archive/3.8.x.zip && \
     unzip -e 3.8.zip -d $CATALINA_HOME && \
     mv $CATALINA_HOME/iso19139.nl.geografie.2.0.0-3.8.x/src/main/plugin/iso19139.nl.geografie.2.0.0 $GN_DIR/WEB-INF/data/config/schema_plugins/iso19139.nl.geografie.2.0.0 && \
     rm 3.8.zip

# download srv plugin
RUN curl -fSL -o 3.8.zip \
     https://github.com/metadata101/iso19139.nl.services.2.0.0/archive/3.8.x.zip && \
     unzip -e 3.8.zip -d $CATALINA_HOME && \
     mv $CATALINA_HOME/iso19139.nl.services.2.0.0-3.8.x/src/main/plugin/iso19139.nl.services.2.0.0 $GN_DIR/WEB-INF/data/config/schema_plugins/iso19139.nl.services.2.0.0 && \
     rm 3.8.zip

# download dutch locations
RUN curl -fSL -o regions.rdf \
	https://www.nationaalgeoregister.nl/geonetwork/srv/dut/thesaurus.download?ref=external.place.regions && \
	mv regions.rdf $GN_DIR/WEB-INF/data/config/codelist/external/thesauri/place/regions.rdf

# set logo to osgeo
#RUN curl -fSL -o GN3.png \ 
#	https://osgeo.nl/wp-content/uploads/2017/09/osgeonl-logo-263x70.png && \
#	mv GN3.png $GN_DIR/WEB-INF/data/data/resources/images/harvesting/GN3.png

COPY ./schema-iso19139.nl.geografie.2.0.0-3.7.jar $GN_DIR/WEB-INF/lib/ 
COPY ./schema-iso19139.nl.services.2.0.0-3.6.jar $GN_DIR/WEB-INF/lib/ 

# set 'dutch' as the default view
RUN sed -i -e \
"s#VALUES ('system/ui/defaultView', 'default',#VALUES ('system/ui/defaultView', 'dutch',#g" \
$GN_DIR/WEB-INF/classes/setup/sql/data/data-db-default.sql
# add dutch translations
RUN sed -i -e \
"s#('custom')#('/../../catalog/views/dutch/locales/{{lang}}-core.json')#g" \
$GN_DIR/catalog/js/GnLocale.js
#finish

CMD ["catalina.sh", "run"]
