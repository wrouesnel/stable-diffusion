FROM rocm/rocm-terminal

USER root

RUN apt update && apt install -y python3.8

WORKDIR /root

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

# For some reason taming-transformers doesn't play nicely without an editable install done manually
RUN git clone https://github.com/CompVis/taming-transformers.git && \
    cd taming-transformers && \
    pip3.8 install -e .

COPY . /root/stable-diffusion

ENV PYTHONPATH=/root/taming-transformers:/root/stable-diffusion

WORKDIR /root/stable-diffusion

RUN pip3.8 install -e .

RUN ln -sf /data /root/stable-diffusion/models/ldm/stable-diffusion-v1 \
 && mkdir -p /output /root/stable-diffusion/outputs \
 && ln -sf /output /root/stable-diffusion/outputs/txt2img-samples

# Options for gfx1010 (Navi 10) cards
ENV HSA_OVERRIDE_GFX_VERSION=10.3.0

CMD python3.8 optimizedSD/txt2img_gradio.py
