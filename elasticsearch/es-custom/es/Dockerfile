FROM elasticsearch:7.9.1

COPY ./elasticsearch-analysis-vietnamese/target/releases/elasticsearch-analysis-vietnamese-7.9.1.zip /elasticsearch-analysis-vietnamese-7.9.1.zip

# Install plugins
# RUN elasticsearch-plugin install analysis-icu && \
#     elasticsearch-plugin install analysis-kuromoji

# https://github.com/elastic/elasticsearch/blob/master/docs/plugins/plugin-script.asciidoc
RUN elasticsearch-plugin install --batch file:/elasticsearch-analysis-vietnamese-7.9.1.zip