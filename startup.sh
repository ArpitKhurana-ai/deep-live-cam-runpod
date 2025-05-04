#!/bin/bash
set -xe

echo "🔧 Setting up Deep-Live-Cam (GPU CUDA Mode)..."

apt-get update && apt-get install -y \
    libgl1 \
    wget \
    git \
    ffmpeg \
    python3-pip

pip install --upgrade pip

pip install \
    opencv-python-headless \
    pillow \
    numpy \
    torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118 \
    onnxruntime-gpu==1.16.3 \
    realesrgan \
    gfpgan

# Clone repo
cd /deeplivecam
git clone https://github.com/hacksider/Deep-Live-Cam.git || true
cd Deep-Live-Cam

# Download YOLOv8 model (optional)
pip install ultralytics
yolo task=detect mode=predict model=yolov8n.pt || echo "✅ YOLOv8 already cached"

# Download required face-swap models
mkdir -p models
wget -nc -O models/GFPGANv1.4.pth https://github.com/TencentARC/GFPGAN/releases/download/v1.3.8/GFPGANv1.4.pth
wget -nc -O models/inswapper_128_fp16.onnx https://github.com/hacksider/Deep-Live-Cam/releases/download/v1.0/inswapper_128_fp16.onnx

# Optional: auto-start face swap on video
echo "🚀 Starting Deep-Live-Cam with CUDA acceleration..."
python run.py --execution-provider cuda
