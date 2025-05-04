#!/bin/bash
set -xe

echo "🔧 Setting up Deep-Live-Cam (GPU CUDA Mode)..."

# 1. Install system dependencies
apt-get update && apt-get install -y \
    libgl1 \
    wget \
    git \
    ffmpeg \
    python3-pip

# 2. Upgrade pip
pip install --upgrade pip

# 3. Install general Python packages from default PyPI index
pip install \
    opencv-python-headless \
    pillow \
    numpy \
    onnxruntime-gpu==1.16.3 \
    realesrgan \
    gfpgan \
    gradio

# 4. Install PyTorch-related packages from CUDA-compatible NVIDIA index
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# 5. Clone Deep-Live-Cam repo
cd /deeplivecam
git clone https://github.com/hacksider/Deep-Live-Cam.git || true
cd Deep-Live-Cam

# 6. Download YOLOv8 model (optional)
pip install ultralytics
yolo task=detect mode=predict model=yolov8n.pt || echo "✅ YOLOv8 already cached"

# 7. Download face-swap models
mkdir -p models
wget -nc -O models/GFPGANv1.4.pth https://github.com/TencentARC/GFPGAN/releases/download/v1.3.8/GFPGANv1.4.pth
wget -nc -O models/inswapper_128_fp16.onnx https://github.com/hacksider/Deep-Live-Cam/releases/download/v1.0/inswapper_128_fp16.onnx

# 8. Launch Deep-Live-Cam
echo "🚀 Launching Deep-Live-Cam with CUDA acceleration..."
python run.py --execution-provider cuda
