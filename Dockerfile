# Stage 1: Builder/Compiler
FROM python:3.8-slim AS compile-image

# Update and install packages
RUN apt update && apt upgrade -y && \
    apt install --no-install-recommends -y gcc gcc-multilib build-essential && \
    apt clean && rm -rf /var/lib/apt/lists/*
# Install Pytorch
RUN pip3 install --no-cache-dir --user \
    torch==1.10.1+cpu torchaudio==0.10.1+cpu -f https://download.pytorch.org/whl/cpu/torch_stable.html
# Install other dependencies
COPY . /speechbrain
WORKDIR /speechbrain
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir --user -r requirements.txt && \
    pip3 install --no-cache-dir --user -e .

# Stage 2: Runtime
FROM python:3.8-slim AS runtime-image
COPY --from=compile-image /root/.local /root/.local
COPY . /speechbrain
WORKDIR /speechbrain
# Make sure scripts in .local are usable:
ENV PATH=/root/.local/bin:$PATH
# Download the pretrained model
# RUN python3 -c 'from sentence_transformers import SentenceTransformer; \
#     SentenceTransformer("distiluse-base-multilingual-cased-v1", device="cpu")'
