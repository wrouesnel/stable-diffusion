FROM rocm/rocm-terminal

USER root

ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/rocm/bin:/home/rocm-user/.local/bin

RUN sudo apt update && sudo apt install -y python3.8

RUN python3.8 -m pip install -U pip ruamel.yaml

RUN pip3.8 install \
    --extra-index-url https://download.pytorch.org/whl/rocm5.1.1 \
    torch torchvision torchaudio

COPY requirements.txt /root/requirements.txt

RUN pip3.8 install -r requirements.txt

ENV PYTHONUNBUFFERED=1
ENV GRADIO_SERVER_NAME=0.0.0.0
ENV GRADIO_SERVER_PORT=7860
EXPOSE 7860

ENV PYTHONPATH=/usr/lib/python3.8/site-packages

# For some reason taming-transformers doesn't play nicely without an editable install done manually
RUN git clone https://github.com/CompVis/taming-transformers.git && \
    cd taming-transformers && \
    pip3.8 install -e .

# Install and check stable-diffusion is installed
COPY . /root/stable-diffusion
WORKDIR /root/stable-diffusion
RUN pip3.8 install -e .

WORKDIR /root

RUN python3.8 -c "from ldm.util import instantiate_from_config"

RUN ln -sf /data/models/ldm/stable-diffusion-v1 /root/stable-diffusion/models/ldm/stable-diffusion-v1 \
 && mkdir -p /output /root/stable-diffusion/outputs \
 && rm -rf /root/stable-diffusion/outputs \
 && ln -sf /output/stable-diffusion/outputs /root/stable-diffusion/outputs

# Options for gfx1010 (Navi 10) cards
ENV HSA_OVERRIDE_GFX_VERSION=10.3.0

RUN pip3.8 install jupyterlab

ENTRYPOINT [ "/root/stable-diffusion/docker-bootstrap.sh" ]
