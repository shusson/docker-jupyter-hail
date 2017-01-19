FROM shusson/pyhail:latest
MAINTAINER Shane Husson shane.a.husson@gmail.com

RUN apt-get install -y curl grep sed dpkg && \
    TINI_VERSION=`curl https://github.com/krallin/tini/releases/latest | grep -o "/v.*\"" | sed 's:^..\(.*\).$:\1:'` && \
    curl -L "https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini_${TINI_VERSION}.deb" > tini.deb && \
    dpkg -i tini.deb && \
    rm tini.deb && \
    apt-get clean

RUN conda install -c r r-essentials

RUN pip install genepattern-notebook jupyter-wysiwyg && \
  jupyter nbextension enable --py widgetsnbextension && \
  jupyter nbextension install --py genepattern && \
  jupyter nbextension enable --py genepattern && \
  jupyter serverextension enable --py genepattern && \
  jupyter nbextension install --py jupyter_wysiwyg && \
  jupyter nbextension enable --py jupyter_wysiwyg


WORKDIR /usr/work

ADD data/tutorial.ipynb data/plots.ipynb ./

RUN wget --quiet https://storage.googleapis.com/hail-tutorial/Hail_Tutorial_Data-v1.tgz && \
    tar -zxf Hail_Tutorial_Data-v1.tgz  --strip 1 && \
    rm -rf Hail_Tutorial_Data-v1.tgz

ENTRYPOINT ["/usr/bin/tini", "--"]

EXPOSE 8888
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--ip=0.0.0.0"]
